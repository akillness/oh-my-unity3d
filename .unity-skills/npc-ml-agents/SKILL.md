---
name: npc-ml-agents
description: >
  Train adaptive NPC behaviors with Unity ML-Agents and ship them as ONNX models
  for Unity runtime inference. Use when defining observations and rewards,
  configuring PPO or self-play training, monitoring runs with TensorBoard,
  exporting ONNX checkpoints, resuming training, or handing trained brains to
  unity-sentis. Triggers on: ML-Agents, mlagents-learn, Unity RL, NPC training,
  reward shaping, self-play, curriculum learning, ONNX export, adaptive NPC AI.
allowed-tools: Bash Read Write Edit Glob Grep
compatibility: >
  Unity projects using the ML-Agents package plus the Python `mlagents-learn`
  trainer CLI. Python 3.9-3.11 remains the common training range. Use official
  ML-Agents installation guidance for the exact package versions in your project.
metadata:
  tags: unity, ml-agents, reinforcement-learning, npc, ppo, self-play, onnx, sentis
  version: "1.1"
  source: akillness/oh-my-unity3d
---

# npc-ml-agents

Use this skill when the problem is *learning behavior*, not just running inference. ML-Agents covers environment design, observation/action spaces, reward shaping, training configuration, run monitoring, and exporting a model that Unity can later consume.

## When to use this skill

- Training an NPC to navigate, fight, cooperate, or adapt
- Designing observation vectors, action spaces, and episode boundaries
- Shaping rewards without creating easy exploits
- Running PPO training and monitoring reward curves
- Exporting a trained ONNX model and deploying it via `unity-sentis`
- Resuming or extending an interrupted training run

## Instructions

### Step 1: Treat the environment as the product

The agent only learns what the environment exposes. Define:
- observation order and scale
- action shape
- success, failure, and timeout conditions
- reset logic for every episode

```csharp
using Unity.MLAgents;
using Unity.MLAgents.Actuators;
using Unity.MLAgents.Sensors;

public class NpcAgent : Agent
{
    [SerializeField] private Transform target;
    private Rigidbody rb;

    public override void Initialize()
    {
        rb = GetComponent<Rigidbody>();
    }

    public override void CollectObservations(VectorSensor sensor)
    {
        sensor.AddObservation(transform.localPosition / 5f);
        sensor.AddObservation((target.position - transform.position).normalized);
        sensor.AddObservation(rb.linearVelocity / 10f);
    }

    public override void OnActionReceived(ActionBuffers actions)
    {
        var moveX = actions.ContinuousActions[0];
        var moveZ = actions.ContinuousActions[1];
        rb.AddForce(new Vector3(moveX, 0f, moveZ) * 10f);
    }

    public override void OnEpisodeBegin()
    {
        rb.linearVelocity = Vector3.zero;
        transform.localPosition = Random.insideUnitSphere * 3f;
        target.localPosition = Random.insideUnitSphere * 3f;
    }
}
```

### Step 2: Build rewards that teach the right shortcut

Start with dense, interpretable rewards:

```csharp
float distance = Vector3.Distance(transform.position, target.position);
AddReward(-0.001f);

if (distance < 1.5f)
{
    AddReward(1.0f);
    EndEpisode();
}

if (transform.localPosition.y < -1f)
{
    AddReward(-1.0f);
    EndEpisode();
}
```

Use reward shaping to encourage progress, not accidental exploits. See `references/reward-design.md`.

### Step 3: Match Behavior Parameters to code

If `CollectObservations()` emits 9 floats, `Behavior Parameters` must reflect that exact contract. The same applies to action counts.

### Step 4: Train with `mlagents-learn`

```yaml
behaviors:
  NPCBrain:
    trainer_type: ppo
    hyperparameters:
      batch_size: 64
      buffer_size: 2048
      learning_rate: 3.0e-4
      beta: 5.0e-3
      epsilon: 0.2
      lambd: 0.95
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

Run training:

```bash
mlagents-learn config/npc.yaml --run-id=npc_v1
tensorboard --logdir results
```

The official getting started guide emphasizes watching cumulative reward rise over time and keeping the generated `results/<run-id>/<behavior>.onnx` artifact for deployment.

### Step 5: Resume or extend training deliberately

```bash
mlagents-learn config/npc.yaml --run-id=npc_v1 --resume
```

Do not change observation or action contracts mid-run unless you intend to invalidate prior checkpoints.

### Step 6: Deploy the ONNX model back into Unity

The trained ONNX model belongs in the runtime pipeline:

- drag the model into the project
- keep the training-time observation order unchanged
- deploy through Behavior Parameters inference or `unity-sentis`

This is where `npc-ml-agents` hands off to `unity-sentis`.

## Advanced patterns

### Self-play

Use when the NPC is learning against another adaptive opponent:

```yaml
self_play:
  save_steps: 20000
  team_change: 100000
  swap_steps: 2000
  window: 10
```

### Curriculum learning

Use when training fails on the hardest environment from step zero:

```yaml
environment_parameters:
  difficulty:
    curriculum:
      - name: easy
        value: 0.2
      - name: hard
        value: 1.0
```

## Examples

### Example 1: Navigation NPC

```bash
mlagents-learn config/npc.yaml --run-id=npc_nav_v1
```

Use a reward mix of time penalty, distance improvement, success bonus, and failure penalty.

### Example 2: Training to deployment handoff

```
npc-ml-agents
  -> train policy
  -> export results/NPCBrain.onnx
  -> unity-sentis loads ONNX in runtime
  -> unity-mcp validates scripts, packages, and console state
```

### Example 3: Debugging a stalled run

If cumulative reward does not trend upward:
- check observation normalization
- reduce action complexity
- simplify the success condition
- look for reward hacking before increasing model size

## Best practices

1. Keep observation and action contracts stable and documented.
2. Use multiple parallel agents in-scene when the environment supports it to speed up learning.
3. Track TensorBoard reward trends before tuning hyperparameters blindly.
4. Resume training with `--resume` instead of discarding useful checkpoints.
5. Export ONNX only after the intended checkpoint is safely written.
6. Pair this skill with `unity-sentis` for runtime deployment and `unity-mcp` for editor automation.

## References

- https://unity-technologies.github.io/ml-agents/Getting-Started/
- See `references/reward-design.md` for reward shaping patterns
