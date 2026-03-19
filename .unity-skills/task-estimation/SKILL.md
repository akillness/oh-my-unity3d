---
name: task-estimation
description: Estimate software development tasks accurately using various techniques. Use when planning sprints, roadmaps, or project timelines. Handles story points, t-shirt sizing, planning poker, and estimation best practices.
allowed-tools: Read Write Grep Glob
metadata:
  tags: estimation, agile, sprint-planning, story-points, planning-poker
  platforms: Claude, ChatGPT, Gemini
---


# Task Estimation


## When to use this skill

- **Sprint Planning**: Decide what work to include in the sprint
- **Roadmap creation**: Build long-term plans
- **Resource planning**: Estimate team size and schedule

## Instructions

### Step 1: Story Points (relative estimation)

**Fibonacci sequence**: 1, 2, 3, 5, 8, 13, 21

```markdown
## Story Point guidelines

### 1 Point (Very Small)
- Example: text change, constant value update
- Time: 1-2 hours
- Complexity: very low
- Risk: none

### 2 Points (Small)
- Example: simple bug fix, add logging
- Time: 2-4 hours
- Complexity: low
- Risk: low

### 3 Points (Medium)
- Example: simple CRUD API endpoint
- Time: 4-8 hours
- Complexity: medium
- Risk: low

### 5 Points (Medium-Large)
- Example: complex form implementation, auth middleware
- Time: 1-2 days
- Complexity: medium
- Risk: medium

### 8 Points (Large)
- Example: new feature (frontend + backend)
- Time: 2-3 days
- Complexity: high
- Risk: medium

### 13 Points (Very Large)
- Example: payment system integration
- Time: 1 week
- Complexity: very high
- Risk: high
- **Recommended**: Split into smaller tasks

### 21+ Points (Epic)
- **Required**: Must be split into smaller stories
```

### Step 2: Planning Poker

**Process**:
1. Product Owner explains the story
2. Team asks questions
3. Everyone picks a card (1, 2, 3, 5, 8, 13)
4. Reveal simultaneously
5. Explain highest/lowest scores
6. Re-vote
7. Reach consensus

**Example**:
```
Story: "Users can upload a profile photo"

Member A: 3 points (simple frontend)
Member B: 5 points (image resizing needed)
Member C: 8 points (S3 upload, security considerations)

Discussion:
- Use an image processing library
- S3 is already set up
- File size validation needed

Re-vote → consensus on 5 points
```

### Step 3: T-Shirt Sizing (quick estimation)

```markdown
## T-Shirt sizes

- **XS**: 1-2 Story Points (within 1 hour)
- **S**: 2-3 Story Points (half day)
- **M**: 5 Story Points (1-2 days)
- **L**: 8 Story Points (1 week)
- **XL**: 13+ Story Points (needs splitting)

**When to use**:
- Initial backlog grooming
- Rough roadmap planning
- Quick prioritization
```

### Step 4: Consider risk and uncertainty

**Estimation adjustment**:
```typescript
interface TaskEstimate {
  baseEstimate: number;      // base estimate
  risk: 'low' | 'medium' | 'high';
  uncertainty: number;        // 0-1
  finalEstimate: number;      // adjusted estimate
}

function adjustEstimate(estimate: TaskEstimate): number {
  let buffer = 1.0;

  // risk buffer
  if (estimate.risk === 'medium') buffer *= 1.3;
  if (estimate.risk === 'high') buffer *= 1.5;

  // uncertainty buffer
  buffer *= (1 + estimate.uncertainty);

  return Math.ceil(estimate.baseEstimate * buffer);
}

// Example
const task = {
  baseEstimate: 5,
  risk: 'medium',
  uncertainty: 0.2  // 20% uncertainty
};

const final = adjustEstimate(task);  // 5 * 1.3 * 1.2 = 7.8 → 8 points
```

## Output format

### Estimation document template

```markdown
## Task: [Task Name]

### Description
[work description]

### Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

### Estimation
- **Story Points**: 5
- **T-Shirt Size**: M
- **Estimated Time**: 1-2 days

### Breakdown
- Frontend UI: 2 points
- API Endpoint: 2 points
- Testing: 1 point

### Risks
- Uncertain API response time (medium risk)
- External library dependency (low risk)

### Dependencies
- User authentication must be completed first

### Notes
- Need to discuss design with UX team
```

## Constraints

### Required rules (MUST)

1. **Relative estimation**: Relative complexity instead of absolute time
2. **Team consensus**: Agreement from the whole team, not individuals
3. **Use historical data**: Plan based on velocity

### Prohibited (MUST NOT)

1. **Pressuring individuals**: Estimates are not promises
2. **Overly granular estimation**: Split anything 13+ points
3. **Turning estimates into deadlines**: estimate ≠ commitment

## Best practices

1. **Break Down**: Split big work into smaller pieces
2. **Reference Stories**: Reference similar past work
3. **Include buffer**: Prepare for the unexpected

## References

- [Scrum Guide](https://scrumguides.org/)
- [Planning Poker](https://www.planningpoker.com/)
- [Story Points](https://www.atlassian.com/agile/project-management/estimation)

## Metadata

### Version
- **Current version**: 1.0.0
- **Last updated**: 2025-01-01
- **Compatible platforms**: Claude, ChatGPT, Gemini

### Tags
`#estimation` `#agile` `#story-points` `#planning-poker` `#sprint-planning` `#project-management`

## Examples

### Example 1: Basic usage
<!-- Add example content here -->

### Example 2: Advanced usage
<!-- Add advanced example content here -->

## Quick Start

Unity3D 스프린트 스토리 추정 시나리오 (`bmad-gds` 연동):

```markdown
## Sprint 3 Story Estimation (Unity3D)

### Story: 플레이어 대시 능력 구현

bmad-gds 컨텍스트:
- GDD 참조: "대시 쿨다운 1.5초, 무적 프레임 10f"
- 기술 스택: C# MonoBehaviour, Physics2D, InputSystem

Story Point 산정:
- 기본 대시 이동 로직: 3점 (C# + Physics2D)
- 쿨다운 시스템: 2점 (TimerManager 연동)
- 무적 프레임 + 레이어 마스크: 3점 (충돌 처리 복잡)
- 이펙트 연동 (ParticleSystem): 2점
- 유닛 테스트 작성: 1점

합계: 11점 → 분리 권장 (13점 미만)

리스크:
- Physics2D 상호작용 예측 어려움 (medium risk) → x1.3
- InputSystem 레거시 충돌 가능 (low risk)

최종 추정: 8점 (분리 후 1차 구현)

→ bmad-gds-sprint-planning에 전달
```

## Workflow Context

Unity3D 스토리 복잡도를 추정하고 스프린트 용량을 계획합니다.
- **트리거**: JEO Workflow 2 PLAN 단계, bmad-gds-sprint-planning 전
- **연동**: `task-estimation` → `bmad-gds-sprint-planning` → `bmad-gds-create-story`
