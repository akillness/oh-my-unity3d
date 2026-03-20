---
name: unity-sentis
description: >
  Run ONNX models inside Unity at runtime with Unity Sentis and the newer Unity
  AI Inference package path. Use when importing ONNX models, creating Workers,
  choosing GPU/CPU backends, warming up inference, profiling runtime cost, or
  deploying on-device NPC and gameplay models. Triggers on: Unity Sentis, Unity
  Inference Engine, ONNX in Unity, runtime inference, Unity neural network,
  BackendType.GPUCompute, Sentis Worker, on-device NPC AI, inference warmup.
allowed-tools: Bash Read Write Edit Glob Grep
compatibility: >
  Unity 2021.3+ with Sentis package support. Current Sentis docs are published as
  2.1.3 and note that Sentis is now branded as Unity AI Inference. ONNX import
  required. GPU backends need compute shader support; CPU backend remains the
  universal fallback.
metadata:
  tags: unity, sentis, inference-engine, onnx, runtime-ai, npc, unity6
  version: "1.1"
  source: akillness/oh-my-unity3d
---

# unity-sentis

Use this skill when a trained model already exists and the job is to make it run reliably inside Unity. The core problems are model import, backend selection, warmup, inference cadence, and platform-safe deployment.

## When to use this skill

- Importing an ONNX model into Unity and running inference in play mode
- Migrating from older Sentis wording to the current Unity AI Inference package path
- Choosing between `BackendType.GPUCompute`, `BackendType.CPU`, and fallback behavior
- Running NPC or gameplay inference without a Python runtime
- Profiling model cost and reducing frame spikes
- Connecting ML-Agents training output to runtime deployment

## Instructions

### Step 1: Install the package and note the rename

Current Sentis docs state that Sentis is now called *Inference Engine* and the latest guidance is moving to `com.unity.ai.inference@latest`. Existing Sentis 2.1.x projects still use the `Unity.Sentis` API surface.

`Packages/manifest.json`:

```json
{
  "dependencies": {
    "com.unity.sentis": "2.1.3"
  }
}
```

If your project is already migrating to the newer package path, keep the skill focused on runtime concepts: import model, create worker, schedule execution, and manage backend/platform constraints.

### Step 2: Load the model and create a worker

```csharp
using UnityEngine;
using Unity.Sentis;

public class NpcInferenceController : MonoBehaviour
{
    [SerializeField] private ModelAsset modelAsset;
    private Model runtimeModel;
    private Worker worker;

    private void Start()
    {
        runtimeModel = ModelLoader.Load(modelAsset);
        var backend = SystemInfo.supportsComputeShaders
            ? BackendType.GPUCompute
            : BackendType.CPU;
        worker = new Worker(runtimeModel, backend);
    }

    private void OnDestroy()
    {
        worker?.Dispose();
    }
}
```

Use `GPUPixel` only when compute shaders are unavailable and you still need a GPU path. Prefer `GPUCompute` or `CPU`.

### Step 3: Schedule inference and warm it up

Official Sentis docs note that the first scheduled run in the Unity Editor can be slow because code, shaders, and internal buffers are compiled and allocated on first use. Warm the model once during startup if user-facing latency matters.

```csharp
private bool warmedUp;

public void RunInference(float[] observations)
{
    using var inputTensor = new Tensor<float>(
        new TensorShape(1, observations.Length),
        observations
    );

    worker.Schedule(inputTensor);

    if (!warmedUp)
    {
        var _ = worker.PeekOutput() as Tensor<float>;
        warmedUp = true;
    }
}
```

### Step 4: Read outputs without stalling more than necessary

```csharp
public float[] ReadActions()
{
    var output = worker.PeekOutput() as Tensor<float>;
    return output != null ? output.DownloadToArray() : System.Array.Empty<float>();
}
```

Practical rules:
- keep tensor shapes stable where possible
- avoid GPU-to-CPU downloads every frame if you can consume results less often
- batch multiple agents when they share the same observation schema

### Step 5: Control cadence and backend by platform

```csharp
private int inferenceInterval = 4;

private void Update()
{
    if (Time.frameCount % inferenceInterval != 0)
    {
        return;
    }

    RunInference(BuildObservationVector());
    ApplyActions(ReadActions());
}
```

Guidance:
- PC / console: start with `GPUCompute`
- mobile / WebGL / weaker devices: validate `CPU` early
- profile before locking the cadence

### Step 6: Integrate ML-Agents outputs cleanly

If the model came from ML-Agents, keep the observation order and shape identical between training and runtime deployment. Treat the exported ONNX file and the runtime observation builder as a contract pair.

## Examples

### Example 1: NPC movement policy

```csharp
public void TickNpcBrain()
{
    var observations = new[]
    {
        transform.localPosition.x / 10f,
        transform.localPosition.z / 10f,
        target.localPosition.x / 10f,
        target.localPosition.z / 10f,
    };

    RunInference(observations);
    var actions = ReadActions();
    Move(actions);
}
```

### Example 2: Adaptive difficulty model

```csharp
float[] playerStats =
{
    normalizedAccuracy,
    normalizedDeaths,
    normalizedClearSpeed,
    normalizedDamageTaken,
};

RunInference(playerStats);
float multiplier = Mathf.Clamp(ReadActions()[0], 0.5f, 2.0f);
ApplyDifficulty(multiplier);
```

### Example 3: Pair Sentis with unity-mcp

```
omu "Deploy trained ONNX NPC model"
  -> unity-mcp: manage_packages / create_script / validate_script
  -> unity-sentis: worker setup, warmup, cadence selection
  -> unity-mcp: run_tests / read_console / unity_docs
```

## Best practices

1. Dispose every `Worker` in `OnDestroy`.
2. Warm up the first schedule during startup or loading screens.
3. Keep runtime observation ordering identical to training-time ordering.
4. Prefer `GPUCompute` and `CPU`; treat `GPUPixel` as a fallback path.
5. Profile both execution and readback cost before shipping.
6. When deployment is unstable, verify supported ONNX operators before debugging gameplay code.

## References

- https://docs.unity3d.com/Packages/com.unity.sentis@2.1/manual/create-an-engine.html
- https://docs.unity3d.com/Packages/com.unity.sentis@2.1/manual/run-a-model.html
- See `references/onnx-export.md` for export and compatibility guidance
