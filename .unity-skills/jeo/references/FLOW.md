# JEO Workflow Reference

This reference matches `JEO v2.0.0`.

## Primary Flow

```text
jeo "<task>"
  |
  v
[PLAN]
  write plan.md
  run plannotator-plan-loop.sh
  approved=true required
  |
  v
[EXECUTE]
  Claude Code -> /omc:team
  others      -> /workflow-init + /workflow-status
  |
  v
[VERIFY]
  agent-browser snapshot <url>
  optional screenshot evidence
  |
  v
[CLEANUP]
  worktree-cleanup.sh
  git worktree prune
  |
  v
[DONE]
```

## State Machine

```text
plan -> execute -> verify -> cleanup -> done
plan -> plan     on plan feedback
```

Persist state in `.omc/state/jeo-state.json`.

## PLAN Gate

Blocking command:

```bash
bash scripts/plannotator-plan-loop.sh plan.md /tmp/plannotator_feedback.txt 3
```

Expected outcomes:

- `0`: approved, move to `execute`
- `10`: feedback required, stay in `plan`
- `32`: local UI bind blocked, require manual conversation approval

## Execution Paths

### Claude Code

```text
/omc:team 3:executor "<task>"
```

Requirements:

- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- plannotator hook configured

### Codex CLI

```text
/prompts:jeo
/workflow-init
```

Requirements:

- `~/.codex/config.toml` contains JEO developer instructions
- `~/.codex/hooks/jeo-notify.py` exists

### Gemini CLI

```text
gemini --approval-mode plan
/workflow-init
```

Requirements:

- `~/.gemini/settings.json` contains the JEO plannotator hook
- `~/.gemini/GEMINI.md` includes the JEO section

### OpenCode

Slash commands registered by setup:

- `/jeo-plan`
- `/jeo-exec`
- `/jeo-verify`
- `/jeo-cleanup`

## Verification

Primary browser check:

```bash
agent-browser snapshot http://localhost:3000
```

Optional evidence capture:

```bash
agent-browser screenshot http://localhost:3000 -o verify.png
```

## Cleanup

```bash
bash scripts/worktree-cleanup.sh || git worktree prune
```

Rules:

- warn when uncommitted changes exist
- clean extra worktrees only
- do not remove unrelated user state

