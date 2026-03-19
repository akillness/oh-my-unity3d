---
name: npc-ml-agents
description: >
  Train adaptive NPC agents using Unity ML-Agents Toolkit with reinforcement
  learning and imitation learning. Use when designing reward functions, configuring
  training environments, training NPC behavior via PPO/SAC, exporting trained
  models to ONNX for Sentis deployment, or implementing self-play and curriculum
  learning. Even if the user doesn't say "ML-Agents" — also triggers on: Unity
  reinforcement learning, Unity NPC training, adaptive NPC behavior, Unity agent
  training, PPO Unity, reward function Unity, NPC brain training, Unity RL,
  on-device NPC AI, behavior cloning Unity, imitation learning Unity.
allowed-tools: Bash Read Write Edit Glob Grep
compatibility: >
  Requires Unity 2022.3+ (recommended Unity 6.3 for Sentis deployment).
  Python 3.9-3.11. Install: pip install mlagents==1.1.0.
  GPU recommended for training (CUDA 11.8+). ONNX export requires opset 17.
metadata:
  tags: unity, ml-agents, reinforcement-learning, npc, onnx, ppo, sac, imitation-learning, sentis
  version: "1.0"
  source: akillness/oh-my-unity3d
---

# npc-ml-agents — Adaptive NPC Training with Unity ML-Agents

Unity ML-Agents Toolkit enables training NPC agents using reinforcement learning (PPO, SAC) and imitation learning (GAIL, BC) directly in Unity environments. Trained models export as ONNX for deployment with Unity Sentis.

## When to use this skill

- Training NPC enemies/companions to adapt to player behavior
- Designing reward functions for complex NPC goals (combat, navigation, teamwork)
- Using self-play for competitive NPC training
- Applying curriculum learning for progressive difficulty
- Exporting trained `.onnx` model for runtime use with unity-sentis
- Replacing hand-crafted state machines with learned behavior

## Setup

### Python environment

```bash
pip install mlagents==1.1.0
pip install torch==2.3.0 --index-url https://download.pytorch.org/whl/cu118
```

### Unity package

In Package Manager, install:
```
com.unity.ml-agents@3.0.0
```

Or add to `Packages/manifest.json`:
```json
{
  "dependencies": {
    "com.unity.ml-agents": "3.0.0"
  }
}
```

## Instructions

### Step 1: Implement Agent in Unity

```csharp
using Unity.MLAgents;
using Unity.MLAgents.Sensors;
using Unity.MLAgents.Actuators;

public class NPCAgent : Agent
{
    [SerializeField] private Transform target;
    private Rigidbody rb;

    public override void Initialize()
    {
        rb = GetComponent<Rigidbody>();
    }

    // Define what the agent observes
    public override void CollectObservations(VectorSensor sensor)
    {
        // Self position (normalized to environment bounds)
        sensor.AddObservation(transform.localPosition / 5f);
        // Target direction
        sensor.AddObservation((target.position - transform.position).normalized);
        // Self velocity
        sensor.AddObservation(rb.linearVelocity / 10f);
        // Total observations: 3 + 3 + 3 = 9
    }

    // Apply agent actions to the environment
    public override void OnActionReceived(ActionBuffers actions)
    {
        float moveX = actions.ContinuousActions[0];
        float moveZ = actions.ContinuousActions[1];
        rb.AddForce(new Vector3(moveX, 0, moveZ) * 10f);

        // Reward: closer to target = higher reward
        float distToTarget = Vector3.Distance(transform.position, target.position);
        AddReward(-0.001f); // time penalty (motivates speed)

        if (distToTarget < 1.5f)
        {
            AddReward(1.0f);  // goal reached
            EndEpisode();
        }

        // Fail condition: fell off platform
        if (transform.localPosition.y < -1f)
        {
            AddReward(-1.0f);
            EndEpisode();
        }
    }

    // Reset environment at episode start
    public override void OnEpisodeBegin()
    {
        rb.linearVelocity = Vector3.zero;
        transform.localPosition = new Vector3(Random.Range(-4f, 4f), 0.5f, Random.Range(-4f, 4f));
        target.localPosition = new Vector3(Random.Range(-4f, 4f), 0.5f, Random.Range(-4f, 4f));
    }

    // Optional: manual control for testing
    public override void Heuristic(in ActionBuffers actionsOut)
    {
        var ca = actionsOut.ContinuousActions;
        ca[0] = Input.GetAxis("Horizontal");
        ca[1] = Input.GetAxis("Vertical");
    }
}
```

### Step 2: Configure Behavior Parameters

Add `BehaviorParameters` component:
- **Behavior Name**: `NPCBrain`
- **Vector Observation Space Size**: `9` (matches CollectObservations total)
- **Continuous Actions**: `2` (moveX, moveZ)
- **Discrete Actions**: `0` (none for this example)
- **Behavior Type**: `Default` (training) / `Inference Only` (after export)

### Step 3: Write training config

```yaml
# config/npc_trainer.yaml
behaviors:
  NPCBrain:
    trainer_type: ppo
    hyperparameters:
      batch_size: 64
      buffer_size: 2048
      learning_rate: 3.0e-4
      learning_rate_schedule: linear
      beta: 5.0e-3      # entropy bonus (exploration)
      epsilon: 0.2      # PPO clip range
      lambd: 0.95       # GAE lambda
      num_epoch: 3
    network_settings:
      normalize: true
      hidden_units: 128
      num_layers: 2
    reward_signals:
      extrinsic:
        gamma: 0.99
        strength: 1.0
    max_steps: 500000
    time_horizon: 64
    summary_freq: 10000
```

### Step 4: Run training

```bash
# Start Unity Editor in background (or build)
mlagents-learn config/npc_trainer.yaml --run-id=npc_v1

# Monitor with TensorBoard
tensorboard --logdir results --port 6006
```

Training outputs:
- `results/npc_v1/NPCBrain.onnx` — trained model (opset 17)
- `results/npc_v1/NPCBrain-*.pt` — checkpoints

### Step 5: Deploy with Unity Sentis

Copy `NPCBrain.onnx` to Unity Assets. Then use `unity-sentis` skill:

```csharp
// Replace ML-Agents inference with Sentis for runtime
// (no Python process needed at runtime)
using Unity.Sentis;

public class DeployedNPCBrain : MonoBehaviour
{
    [SerializeField] ModelAsset trainedModel;
    private Worker worker;

    void Start()
    {
        var model = ModelLoader.Load(trainedModel);
        worker = new Worker(model, BackendType.GPUCompute);
    }

    public int[] GetActions(float[] observations)
    {
        using var tensor = new Tensor<float>(
            new TensorShape(1, observations.Length), observations
        );
        worker.Schedule(tensor);
        var output = worker.PeekOutput() as Tensor<float>;
        return output?.DownloadToArray().Select(f => (int)(f * 2)).ToArray()
               ?? Array.Empty<int>();
    }

    void OnDestroy() => worker?.Dispose();
}
```

## Advanced patterns

### Self-play (competitive NPC training)

```yaml
behaviors:
  SelfPlayNPC:
    trainer_type: ppo
    self_play:
      save_steps: 20000
      team_change: 100000
      swap_steps: 2000
      window: 10
      play_against_latest_model_ratio: 0.5
      initial_elo: 1200.0
```

### Curriculum learning

```yaml
environment_parameters:
  difficulty:
    curriculum:
      - name: easy
        completion_criteria:
          measure: reward
          behavior: NPCBrain
          signal_smoothing: true
          min_lesson_length: 100
          threshold: 0.8
        value: 0.2
      - name: hard
        value: 1.0
```

## Examples

### Example 1: omu agent workflow for NPC training

```
omu "NPC ML 훈련 환경 구성"
  [PLAN]     npc-ml-agents — 환경 설계, 보상 함수 명세
  [EXECUTE]  unity-mcp: create_script (NPCAgent.cs) → validate_script
             unity-mcp: manage_scene (학습 환경 설정)
  [VERIFY]   unity-mcp: run_tests → read_console
  [CLEANUP]
```

### Example 2: Imitation learning from human demonstrations

```bash
# Record demonstrations in Unity (set BehaviorType to Heuristic Only)
# Then train with GAIL:
```

```yaml
behaviors:
  NPCBrain:
    trainer_type: ppo
    reward_signals:
      gail:
        gamma: 0.99
        strength: 0.01
        demo_path: demos/NPC.demo
```

## Best practices

1. **Normalize observations** — set `normalize: true` in config; helps convergence
2. **Shape rewards carefully** — dense (continuous) rewards train faster than sparse (goal-only)
3. **Use multiple parallel environments** — set 10-20 Unity instances for faster data collection
4. **Validate with Heuristic mode** — test your `CollectObservations` manually before training
5. **Export with opset 17** — ML-Agents default; required for Unity Sentis compatibility
6. **Profile Sentis inference** — after export, profile with Unity Profiler (target: < 1ms per NPC)

## References

- [Unity ML-Agents GitHub](https://github.com/Unity-Technologies/ml-agents)
- [ML-Agents Documentation](https://unity-technologies.github.io/ml-agents/)
- [PPO Algorithm](https://huggingface.co/learn/deep-rl-course/unit8/introduction)
- [Unity Sentis Deployment](https://docs.unity3d.com/Packages/com.unity.sentis@2.1)
- See `unity-sentis` skill for Sentis deployment details
- See `references/reward-design.md` for reward function patterns
