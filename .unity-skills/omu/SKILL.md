---
name: omu
description: "OMU - Integrated AI agent orchestration skill for Unity3D game development. Manages game lifecycle (기획→개발→QA→수익성) via .omu folder, plan with ralph+plannotator, execute with team/bmad, verify with unity-mcp, and auto-cleanup. Supports Claude, Codex, Gemini CLI, and OpenCode."
compatibility: "Requires git, node>=18, bash. Optional: bun, docker."
allowed-tools: Read Write Bash Grep Glob Task
metadata:
  tags: omu, orchestration, ralph, plannotator, team, bmad, omc, omx, ohmg, agent-browser, multi-agent, workflow, worktree-cleanup, browser-verification, game-lifecycle, planning-docs
  platforms: Claude, Codex, Gemini, OpenCode
  keyword: omu
  version: 2.1.0
  source: akillness/oh-my-unity3d
---

# OMU - Integrated Agent Orchestration

> Keyword: `omu` | Platforms: Claude Code, Codex CLI, Gemini CLI, OpenCode
>
> Workflow: Plan (`ralph` + `plannotator`) -> Execute (`team` or `bmad`) -> Verify (`unity-mcp` / `agent-browser`) -> Cleanup (`worktree-cleanup`)
>
> Game Lifecycle: 기획 (Plan) → 개발 (Execute) → QA (Verify) → 수익성 (Monetize)

OMU is the release-oriented orchestration skill package shipped in this repository. It standardizes one path through planning, implementation, Unity3D verification, and worktree cleanup across the supported AI coding tools.

The `.omu/` folder is the persistent game project management hub — long-term plans, short-term sprints, progress tracking, and history archiving are all managed here across OMU workflow runs.

`agentation`, `annotate`, and `agentui` are intentionally removed in `v2.0.0`. UI review is handled with `agent-browser` snapshots and normal edit loops only.

## Quick Start

```bash
bash scripts/install.sh --all
bash scripts/check-status.sh
```

Then activate OMU with a task statement such as `omu "ship the inventory prototype"` and follow the gated PLAN -> EXECUTE -> VERIFY -> CLEANUP flow.

## When to use this skill

- When the user wants a Unity3D-oriented orchestration flow spanning planning, execution, verification, and cleanup
- When the task should combine `ralph`, `plannotator`, `team` or `bmad`, browser verification, and optional Unity MCP verification
- When the user invokes `omu` or asks for a release-oriented, cross-platform game-development workflow

## Instructions

### Execution contract

Run the phases in order. Do not skip PLAN. Do not enter EXECUTE without an approved plan.

### Unity3D 모드 (unity-mcp 감지)

Before starting PLAN, check unity-mcp availability:

```bash
curl -sf http://localhost:8080/health >/dev/null 2>&1 && echo "unity-mcp: available" || echo "unity-mcp: not available"
```

If available (exit 0): activate Unity3D verification loop in VERIFY phase.
If unavailable: use standard agent-browser verification.

### STEP 0: Bootstrap

Create the working state directories:

```bash
mkdir -p .omc/state .omc/plans .omc/logs
```

---

### STEP 0.1: .omu Game Plan Bootstrap

Before planning, check and initialize the `.omu/` game management folder.

#### 0.1a — Create `.omu/` if it doesn't exist

```bash
if [ ! -d ".omu" ]; then
  mkdir -p .omu/history
  echo "(.omu folder created — populate long-term-plan.md and short-term-plan.md)"
fi
```

If `.omu/long-term-plan.md` does not exist, create it from the template at `.unity-skills/omu/templates/.omu/long-term-plan.md` (or use the built-in template below).

#### 0.1b — Read existing plans

Read all `.omu/` documents in parallel and build context:

| File | Purpose | Action |
|------|---------|--------|
| `.omu/long-term-plan.md` | 기획 컨셉, 규칙, 게임성 | Read → extract current concept and constraints |
| `.omu/short-term-plan.md` | 시스템, 밸런스, 배치, 연출 | Read → identify sprint scope and backlog |
| `.omu/progress.md` | 진행내용 체크리스트 | Read → find unchecked items and blockers |

#### 0.1c — Detect current game development stage

Based on `.omu/progress.md` content, detect and log the active stage:

```
기획 (Planning)  → GDD not complete, concept not finalized
개발 (Development) → Core loop implemented, systems in progress
QA (Quality Assurance) → Implementation complete, testing in progress
수익성 (Monetization) → QA passed, analytics/IAP integration in progress
```

Update `.omc/state/omu-state.json`:
```json
{
  "game_stage": "기획 | 개발 | QA | 수익성",
  "omu_docs_loaded": true
}
```

User-facing message:
> `OMU activated. Game Stage: [stage]. Phase: PLAN.`
> `Plan docs loaded from .omu/ — [N] pending items found.`

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
- Resume from `.omc/state/omu-state.json` if a prior run already exists:
  - phase=plan → re-run plannotator gate if plan_approved=false
  - phase=execute → skip PLAN, resume from last implementation checkpoint
  - phase=verify → skip PLAN+EXECUTE, re-run verification commands
  - phase=cleanup → run cleanup script, then mark done
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

Exit code handling:
- exit 0 → approved=true → proceed to EXECUTE
- exit 10 → approved=false (feedback) → update plan.md and re-run the loop
- exit 32 → plannotator unavailable (non-interactive env, port conflict, or install failure) →
  HALT: do NOT proceed to EXECUTE. Output:
  "⚠️ PLAN GATE: plannotator가 필요합니다. bash scripts/ensure-plannotator.sh 실행 후 재시도하세요."
  TUI 폴백은 비활성화되어 있습니다. plannotator 없이 plan을 승인할 수 없습니다.

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

When execution is complete, update the state file:

```json
{
  "phase": "verify",
  "checkpoint": "execute-complete"
}
```

#### .omu Progress Update (EXECUTE 단계 완료 시)

After each completed task during EXECUTE, update `.omu/progress.md`:

1. Mark completed items with `- [x]`
2. Add newly discovered tasks under the appropriate section
3. Update `short-term-plan.md` if sprint scope changes

```bash
# Example: mark a system as complete
# .omu/progress.md: "- [ ] 코어 루프 구현" → "- [x] 코어 루프 구현"
```

New short-term tasks discovered during execution should be appended to `.omu/short-term-plan.md` under **Backlog**.

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

When verification passes, update the state file:

```json
{
  "phase": "cleanup",
  "checkpoint": "verify-complete"
}
```

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

After verification, guard against uncommitted changes:

```bash
# Guard: warn if uncommitted changes exist
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "[OMU][CLEANUP] ⚠️ Uncommitted changes detected. Commit or stash before cleanup."
  git status --short
  exit 1
fi
```

Then run cleanup:

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

#### .omu Archive (CLEANUP 단계)

Archive completed work from `.omu/` to history:

```bash
# 1. Generate archive filename
ARCHIVE_DATE=$(date +%Y%m%d)
ARCHIVE_FILE=".omu/history/${ARCHIVE_DATE}-$(echo "$TASK" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | head -c 40).md"

# 2. Extract completed items from progress.md (lines with [x])
grep -E "^\s*- \[x\]" .omu/progress.md > /tmp/completed_items.txt

# 3. Write archive entry
cat > "$ARCHIVE_FILE" << EOF
# Archive: $TASK
**Date**: $ARCHIVE_DATE
**Stage**: $(jq -r '.game_stage' .omc/state/omu-state.json)
**Sprint**: (from short-term-plan.md)

## Completed Items
$(cat /tmp/completed_items.txt)

## Notes
(Add retrospective notes here)
EOF

# 4. Remove completed items from progress.md
sed -i '' '/^\s*- \[x\]/d' .omu/progress.md

# 5. Remove completed items from short-term-plan.md
sed -i '' '/^\s*- \[x\]/d' .omu/short-term-plan.md
```

`.omu/` post-cleanup state:
- `progress.md` — only unchecked (`- [ ]`) items remain
- `short-term-plan.md` — backlog updated, completed sprint items removed
- `history/YYYYMMDD-<task>.md` — permanent record of what was done

---

## Examples

### Unity3D 워크플로우 예제

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
