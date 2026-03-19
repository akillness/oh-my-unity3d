---
name: unity-sentis
description: >
  Integrate and run ML models directly inside Unity at runtime using Unity Sentis
  (Unity 6.3+). Use when importing ONNX models into Unity, setting up runtime
  inference for NPC behavior, animation, physics prediction, or player analysis,
  selecting GPU/CPU backend, profiling performance, and deploying on-device AI.
  Even if the user doesn't say "Sentis" — also triggers on: ONNX in Unity,
  on-device ML Unity, runtime AI inference Unity, Unity ML runtime, neural network
  Unity, Unity AI model, Unity machine learning runtime, Unity 6 AI, Sentis GPU,
  NPC AI inference, Unity brain model.
allowed-tools: Bash Read Write Edit Glob Grep
compatibility: >
  Requires Unity 6.3+ (com.unity.sentis >= 2.1.0). Supports ONNX format models.
  GPU backend requires a GPU with Compute Shader support. CPU backend available on all platforms.
metadata:
  tags: unity, sentis, onnx, ml-inference, npc, on-device-ai, runtime-ai, unity6
  version: "1.0"
  source: akillness/oh-my-unity3d
---

# unity-sentis — On-Device ML Inference in Unity

Unity Sentis is the official Unity ML runtime (Unity 6.3+). Import ONNX models directly into Unity and run inference in-game — no server required. Supports GPU and CPU backends via Compute Shaders and Burst respectively.

## When to use this skill

- Importing a pre-trained ONNX model (ML-Agents, PyTorch export, scikit-learn) into Unity
- Running NPC behavior inference at runtime without network calls
- Animating characters with physics prediction models
- Analyzing player behavior in real-time for adaptive difficulty
- Profiling ML inference cost with Unity Profiler
- Deploying AI to mobile/console with CPU backend

## Setup

### Install Unity Sentis package

In Unity Package Manager, add:

```
com.unity.sentis@2.1.0
```

Or add to `Packages/manifest.json`:

```json
{
  "dependencies": {
    "com.unity.sentis": "2.1.0"
  }
}
```

### Import an ONNX model

1. Export your model to ONNX format (see `references/onnx-export.md`)
2. Drag the `.onnx` file into your Unity `Assets/Models/` folder
3. Unity auto-converts it to a `ModelAsset`

## Instructions

### Step 1: Load model and create worker

```csharp
using Unity.Sentis;

public class NPCBrainController : MonoBehaviour
{
    [SerializeField] private ModelAsset modelAsset;
    private Worker worker;
    private Model runtimeModel;

    void Start()
    {
        runtimeModel = ModelLoader.Load(modelAsset);

        // Choose backend based on platform capability
        var backend = SystemInfo.supportsComputeShaders
            ? BackendType.GPUCompute
            : BackendType.CPU;

        worker = new Worker(runtimeModel, backend);
    }

    void OnDestroy()
    {
        worker?.Dispose();
    }
}
```

### Step 2: Prepare input tensor

```csharp
void RunInference(float[] observationData)
{
    // Create input tensor matching model's expected shape
    // e.g., [1, observationSize] for a single agent observation
    using var inputTensor = new Tensor<float>(
        new TensorShape(1, observationData.Length),
        observationData
    );

    worker.Schedule(inputTensor);
}
```

### Step 3: Read output tensor

```csharp
void ApplyInferenceResult()
{
    // Peek output without blocking (non-blocking read)
    var outputTensor = worker.PeekOutput() as Tensor<float>;

    if (outputTensor != null)
    {
        // Read values — force sync download from GPU
        var results = outputTensor.DownloadToArray();
        ApplyActionToNPC(results);
    }
}
```

### Step 4: Profile performance

In Unity Profiler, look for:
- `Sentis.Worker.Execute` — inference time per frame
- `Sentis.Tensor.DownloadToArray` — GPU→CPU readback cost

Target: inference should take ≤ 5% of frame time (< 0.8ms at 60fps).

To reduce cost:
- Use `BackendType.GPUCompute` when GPU is available
- Batch multiple agent inferences in a single call
- Run inference every N frames, not every frame

```csharp
private int inferenceInterval = 5; // run every 5 frames
private int frameCount = 0;

void Update()
{
    frameCount++;
    if (frameCount % inferenceInterval == 0)
    {
        RunInference(GetObservations());
    }
}
```

### Step 5: Deploy to target platform

| Platform | Recommended Backend |
|----------|-------------------|
| PC / Console | `GPUCompute` |
| Mobile (iOS/Android) | `CPU` (Burst) |
| WebGL | `CPU` |

```csharp
// Runtime backend selection
#if UNITY_WEBGL
    var backend = BackendType.CPU;
#else
    var backend = SystemInfo.supportsComputeShaders
        ? BackendType.GPUCompute
        : BackendType.CPU;
#endif
```

## Examples

### Example 1: NPC behavior model inference

```csharp
public class SimpleNPCBrain : MonoBehaviour
{
    [SerializeField] ModelAsset brainModel;
    private Worker worker;

    void Awake()
    {
        var model = ModelLoader.Load(brainModel);
        worker = new Worker(model, BackendType.GPUCompute);
    }

    public float[] GetAction(float[] observations)
    {
        using var input = new Tensor<float>(
            new TensorShape(1, observations.Length), observations
        );
        worker.Schedule(input);
        var output = worker.PeekOutput() as Tensor<float>;
        return output?.DownloadToArray() ?? Array.Empty<float>();
    }

    void OnDestroy() => worker?.Dispose();
}
```

### Example 2: Adaptive difficulty with player model

```csharp
// Feed normalized player stats → predict difficulty multiplier
float[] playerStats = {
    normalizedScore,
    normalizedDeathRate,
    normalizedSessionTime,
    normalizedAccuracy
};
float[] prediction = npcBrain.GetAction(playerStats);
float difficultyMultiplier = Mathf.Clamp(prediction[0], 0.5f, 2.0f);
```

### Example 3: Integrate with unity-mcp agent

When using via oh-my-unity3d agent workflow:

```
omu "NPC 행동 모델 통합"
  [PLAN]     unity-sentis 스킬 로드 → 모델 asset 확인
  [EXECUTE]  unity-mcp: create_script (NPCBrain.cs) → validate_script
  [VERIFY]   unity-mcp: run_tests → read_console (Error 확인)
  [CLEANUP]
```

## Best practices

1. **Always Dispose workers** — `worker.Dispose()` in `OnDestroy` to prevent GPU memory leaks
2. **Non-blocking reads** — use `PeekOutput()` not `TakeOutputOwnership()` to avoid stalls
3. **Batch inference** — process multiple NPC observations in one worker call when possible
4. **Profile before shipping** — check `Sentis.Worker.Execute` in Profiler for every target platform
5. **CPU fallback for mobile** — always include `BackendType.CPU` fallback for devices without Compute Shaders
6. **ONNX opset 17** — export models with opset 17 for maximum Sentis compatibility

## References

- [Unity Sentis Documentation](https://docs.unity3d.com/Packages/com.unity.sentis@2.1/manual/index.html)
- [Supported ONNX Operators](https://docs.unity3d.com/Packages/com.unity.sentis@2.1/manual/supported-operators.html)
- [Unity Sentis GitHub Samples](https://github.com/Unity-Technologies/sentis-samples)
- See `references/onnx-export.md` for model export guides (PyTorch, ML-Agents, scikit-learn)
