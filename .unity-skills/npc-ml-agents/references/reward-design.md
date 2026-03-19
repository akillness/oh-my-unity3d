# Reward Function Design Patterns

## Principles

1. **Dense > Sparse** — give small rewards every step, not just at goal
2. **Avoid reward hacking** — agent finds unintended ways to maximize reward
3. **Normalize magnitudes** — keep rewards in [-1, 1] range
4. **Time penalty** — small negative reward per step encourages efficiency

## Pattern 1: Distance-based reward

```csharp
void Update()
{
    float prevDist = previousDistanceToTarget;
    float currDist = Vector3.Distance(transform.position, target.position);
    float improvement = prevDist - currDist;
    AddReward(improvement * 0.1f);  // reward for getting closer
    previousDistanceToTarget = currDist;
}
```

## Pattern 2: Survival + goal

```csharp
AddReward(-0.0005f);  // time penalty: small, per step

if (reachedGoal)
{
    AddReward(1.0f);
    EndEpisode();
}

if (died)
{
    AddReward(-1.0f);
    EndEpisode();
}
```

## Pattern 3: Multi-objective reward

```csharp
// Weight multiple objectives
float goalReward = reachedGoal ? 1.0f : 0f;
float efficiencyBonus = 1.0f / (stepCount + 1);  // fewer steps = higher bonus
float collisionPenalty = hitWall ? -0.5f : 0f;

AddReward(goalReward + 0.1f * efficiencyBonus + collisionPenalty);
```

## Common reward hacking scenarios

| Behavior | Root Cause | Fix |
|---------|-----------|-----|
| NPC spins in place | Reward for facing target, not reaching it | Use distance improvement |
| NPC stays at start | Sparse reward only at goal | Add dense step rewards |
| NPC exploits collision | No penalty for hitting walls | Add `AddReward(-0.1f)` on collision |
| NPC never finishes | No time pressure | Add `AddReward(-0.001f)` per step |
