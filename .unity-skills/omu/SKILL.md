---
name: omu
description: "OMU - Integrated AI agent orchestration skill. Plan with ralph+plannotator, execute with team/bmad, verify browser behavior with agent-browser, and auto-cleanup worktrees after completion. Supports Claude, Codex, Gemini CLI, and OpenCode."
compatibility: "Requires git, node>=18, bash. Optional: bun, docker."
allowed-tools: Read Write Bash Grep Glob Task
metadata:
  tags: omu, orchestration, ralph, plannotator, team, bmad, omc, omx, ohmg, agent-browser, multi-agent, workflow, worktree-cleanup, browser-verification
  platforms: Claude, Codex, Gemini, OpenCode
  keyword: omu
  version: 2.0.0
  source: akillness/oh-my-unity3d
---

# OMU - Integrated Agent Orchestration

> Keyword: `omu` | Platforms: Claude Code, Codex CLI, Gemini CLI, OpenCode
>
> Workflow: Plan (`ralph` + `plannotator`) -> Execute (`team` or `bmad`) -> Verify (`agent-browser`) -> Cleanup (`worktree-cleanup`)

OMU is the release-oriented orchestration skill package shipped in this repository. It standardizes one path through planning, implementation, browser verification, and worktree cleanup across the supported AI coding tools.

`agentation`, `annotate`, and `agentui` are intentionally removed in `v2.0.0`. UI review is handled with `agent-browser` snapshots and normal edit loops only.

---

## 0. Execution Contract

Run the phases in order. Do not skip PLAN. Do not enter EXECUTE without an approved plan.

### Unity3D 모드 (unity-mcp 감지)

unity-mcp 서버가 실행 중인 경우 (`localhost:8080` 연결 확인 시) Unity3D 검증 루프가 활성화됩니다.

### STEP 0: Bootstrap

Create the working state directories:

```bash
mkdir -p .omc/state .omc/plans .omc/logs
```

If `.omc/state/omu-state.json` does not exist, create it with:

```json
{
  "mode": "omu",
  "phase": "plan",
  "task": "<detected task>",
  "plan_approved": false,
  "plan_gate_status": "pending",
  "team_available": null,
  "retry_count": 0,
  "last_error": null,
  "checkpoint": null,
  "created_at": "<ISO 8601>",
  "updated_at": "<ISO 8601>"
}
```

User-facing activation message:

> `OMU activated. Phase: PLAN.`

### STEP 0.1: Recovery Rules

- Update `checkpoint` whenever a phase starts.
- Update `last_error` and increment `retry_count` before failing pre-flight.
- Resume from `.omc/state/omu-state.json` if a prior run already exists.
- If `retry_count >= 3`, stop and ask the user whether to continue.

---

## 1. PLAN

PLAN is mandatory in every OMU run.

### Required output

Write `plan.md` with:

- goal
- implementation steps
- risks
- completion criteria

### Required plan gate

Run the blocking plannotator loop:

```bash
bash scripts/plannotator-plan-loop.sh plan.md /tmp/plannotator_feedback.txt 3
```

Rules:

- Never use `&`.
- If `plannotator` is missing, auto-run `bash scripts/ensure-plannotator.sh` first.
- Proceed only when the result contains `approved=true`.
- If the plan is rejected, update `plan.md` and run the loop again.
- If the loop exits with `32`, use manual conversation approval and do not execute until the user explicitly approves.

When approved, update the state file:

```json
{
  "phase": "execute",
  "plan_approved": true,
  "plan_gate_status": "approved"
}
```

---

## 2. EXECUTE

OMU supports two execution paths.

### Claude Code

Use team execution:

```text
/omc:team 3:executor "<task>"
```

OMU expects `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

### Codex, Gemini CLI, OpenCode

Use BMAD as the fallback orchestration path:

```text
/workflow-init
/workflow-status
```

Execution rule:

- keep the implementation aligned to the approved plan
- update `phase` to `execute`
- return to PLAN only if the plan is invalidated by new information

---

## 3. VERIFY

Use browser verification when the task includes UI or browser behavior.

Primary command:

```bash
agent-browser snapshot http://localhost:3000
```

Useful follow-ups:

```bash
agent-browser screenshot http://localhost:3000 -o verify.png
playwriter --help
```

Verification rule:

- confirm the changed behavior, not only page load
- capture evidence before cleanup when the task is browser-facing
- keep the state file in `phase = "verify"` until verification is complete

### STEP 3: VERIFY — Unity3D 검증 루프

Unity3D 모드가 활성화된 경우 브라우저 검증 대신 아래 루프를 실행합니다.

① `unity-mcp: run_tests`     → pass/fail 집계
② `unity-mcp: read_console`  → Error/Exception 패턴 탐지
③ `unity-mcp: editor_state`  → 씬 로드 상태 확인
④ `unity-mcp: find_gameobjects` → 필수 오브젝트 확인

검증 결과:

- 모두 통과 → CLEANUP
- 실패 → Fix 루프 (code-refactoring 또는 `unity-mcp: validate_script` → 재검증, 최대 3회)
- 3회 초과 → 사용자 확인 요청

`omu-state.json` 업데이트:

```json
{ "unity_verify": { "tests_passed": true, "console_errors": 0, "retry_count": 0 } }
```

---

## 4. CLEANUP

After verification:

```bash
bash scripts/worktree-cleanup.sh || git worktree prune
```

Then set:

```json
{
  "phase": "done",
  "checkpoint": "cleanup"
}
```

Cleanup rule:

- warn before cleanup if there are uncommitted changes
- clean extra worktrees only
- never delete unrelated user work

---

## 5. Unity3D 워크플로우 예제

### Workflow 1: 게임 기획 → 씬 프로토타이핑

```
omu "씬 프로토타이핑: <게임명>"
  [PLAN]     bmad-gds-brainstorm-game → bmad-gds-gdd
  [EXECUTE]  unity-mcp: manage_scene → manage_gameobject → manage_probuilder
  [VERIFY]   unity-mcp: run_tests → read_console → editor_state → Fix 루프 (max 3)
  [CLEANUP]
```

### Workflow 2: 스프린트 스토리 → C# 구현

```
omu "스토리 구현: <스토리명>"
  [PLAN]     bmad-gds-sprint-planning → bmad-gds-create-story
  [EXECUTE]  bmad-gds-dev-story → unity-mcp: create_script → validate_script → script_apply_edits
  [VERIFY]   unity-mcp: run_tests → read_console → Fix 루프 → bmad-gds-code-review
  [CLEANUP]
```

### Workflow 3: 에셋 파이프라인 자동화

```
omu "에셋 파이프라인: <에셋 종류>"
  [PLAN]     file-organization
  [EXECUTE]  unity-mcp: manage_asset → manage_texture → manage_material → manage_prefabs → batch_execute
  [VERIFY]   unity-mcp: read_console → run_tests → performance-optimization → Fix 루프
  [CLEANUP]
```

### Workflow 4: Unity UI/비주얼 개발

```
design-system (Unity3D Design Guide 탐색)
  → ui-component-patterns → unity-mcp: manage_ui → manage_animation → manage_vfx
  → [VERIFY] unity-mcp: run_tests → read_console
```

### Workflow 5: 성능 최적화 & 디버깅

```
omu "성능 최적화: <증상>"
  [PLAN]     log-analysis (unity-mcp: read_console) → find_gameobjects → codebase-search
  [EXECUTE]  performance-optimization → unity-mcp: manage_components → batch_execute
  [VERIFY]   unity-mcp: run_tests → read_console → bmad-gds-performance-test → Fix 루프
  [CLEANUP]
```

---

## 6. Quick Start

### Install dependencies and helpers

```bash
bash scripts/install.sh --all
```

### Check current environment

```bash
bash scripts/check-status.sh
```

### Configure each platform

```bash
bash scripts/setup-claude.sh
bash scripts/setup-codex.sh
bash scripts/setup-gemini.sh
bash scripts/setup-opencode.sh
```

---

## 7. Installed Components

| Tool | Purpose |
|------|---------|
| `omc` | Claude Code team orchestration |
| `omx` | OpenCode orchestration |
| `ohmg` | Gemini multi-agent support |
| `bmad` | Fallback workflow orchestration |
| `ralph` | specification-first planning loop |
| `plannotator` | blocking plan review gate |
| `agent-browser` | browser verification |
| `playwriter` | optional browser automation helper |

---

## 8. Platform Notes

### Claude Code

- `setup-claude.sh` enables team mode and plannotator review hooks.
- OMU does not fall back to single-agent execution in Claude Code.

### Codex CLI

- `setup-codex.sh` writes `developer_instructions`, `/prompts:omu`, and a `PLAN_READY` notify hook.

### Gemini CLI

- `setup-gemini.sh` installs a plannotator-oriented AfterAgent helper and appends OMU guidance to `GEMINI.md`.

### OpenCode

- `setup-opencode.sh` registers plugins and slash commands for plan, execute, verify, and cleanup.

---

## 9. State File

Path:

```text
.omc/state/omu-state.json
```

Example:

```json
{
  "mode": "omu",
  "phase": "verify",
  "task": "Ship the OMU release package",
  "plan_approved": true,
  "plan_gate_status": "approved",
  "team_available": false,
  "retry_count": 0,
  "last_error": null,
  "checkpoint": "verify",
  "created_at": "2026-03-09T00:00:00Z",
  "updated_at": "2026-03-09T00:00:00Z"
}
```

---

## 10. Troubleshooting

| Problem | Action |
|---------|--------|
| `plannotator` unavailable | Run `bash scripts/ensure-plannotator.sh` or `bash scripts/install.sh --with-plannotator` |
| Claude team execution unavailable | Run `bash scripts/setup-claude.sh`, restart Claude Code, confirm `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` |
| Codex prompt not found | Re-run `bash scripts/setup-codex.sh` |
| Gemini hook missing | Re-run `bash scripts/setup-gemini.sh` |
| Browser verification unavailable | Install `agent-browser` with `bash scripts/install.sh --with-browser` |
| Worktrees remain after completion | Run `bash scripts/worktree-cleanup.sh` and then `git worktree prune` |

---

## 11. Release Notes

### `v2.0.0`

- removed `agentation` integration from the skill contract
- removed `annotate` and `agentui` workflow branches
- simplified verification around `agent-browser`
- aligned setup scripts and docs to the reduced release surface

