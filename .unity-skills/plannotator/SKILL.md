---
name: plannotator
description: Interactive plan and diff review for AI coding agents. Visual browser UI for annotating agent plans — approve or request changes with structured feedback. Supports code review, image annotation, and auto-save to Obsidian/Bear Notes.
allowed-tools: Read Bash Write
metadata:
  tags: plannotator, planno, plan-review, diff-review, code-review, claude-code, opencode, annotation, visual-review, design-review
  platforms: Claude, OpenCode, Codex, Gemini
  keyword: plannotator
  version: 0.9.3
  source: backnotprop/plannotator
---


# plannotator — Interactive Plan & Diff Review

> Keyword: `plannotator` | Source: https://github.com/backnotprop/plannotator
>
> Annotate and review AI coding agent plans visually, share with your team, send feedback with one click.
> Works with **Claude Code**, **OpenCode**, **Gemini CLI**, and **Codex CLI**.

## When to use this skill

- You want to review an AI agent's implementation plan BEFORE it starts coding
- You want to annotate a git diff after the agent makes changes
- You need a feedback loop: visually mark up what to change, then send structured feedback back
- You want to share plan reviews with teammates via a link
- You want to auto-save approved plans to Obsidian or Bear Notes

## Do not use this skill when

- You need a simple git diff review without visual annotation (use `git diff` or standard code-review)
- The agent is running in a non-interactive CI/CD pipeline with no browser access
- You want to review code without opening a browser (use the standard code-review skill instead)

---

## Scripts (Automated Patterns)

All patterns have a corresponding script in `scripts/`. Run them directly or let the agent call them.

| Script | Pattern | Usage |
|--------|---------|-------|
| `scripts/install.sh` | CLI Install | One-command install; `--all` sets up every AI tool |
| `scripts/setup-hook.sh` | Claude Code Hook | Configure Claude Code ExitPlanMode hook |
| `scripts/setup-gemini-hook.sh` | Gemini CLI Hook | Configure Gemini CLI ExitPlanMode hook + GEMINI.md |
| `scripts/setup-codex-hook.sh` | Codex CLI Setup | Configure Codex CLI developer_instructions + prompt |
| `scripts/setup-opencode-plugin.sh` | OpenCode Plugin | Register plugin + slash commands |
| `scripts/check-status.sh` | Status Check | Verify all integrations and configuration |
| `scripts/configure-remote.sh` | Remote Mode | SSH / devcontainer / WSL configuration |
| `scripts/review.sh` | Code Review | Launch diff review UI |

---

## Pattern 1: Install

```bash
# Install CLI only (macOS / Linux / WSL)
bash scripts/install.sh

# Install CLI + configure all AI tool integrations at once
bash scripts/install.sh --all

# Targeted installs
bash scripts/install.sh --with-plugin    # Claude Code plugin commands
bash scripts/install.sh --with-gemini   # Gemini CLI
bash scripts/install.sh --with-codex    # Codex CLI
bash scripts/install.sh --with-opencode # OpenCode plugin
```

> **Tip:** On Windows, the script prints PowerShell / CMD commands to run manually.

---

## Pattern 2: Hook Setup (Plan Review trigger)

```bash
# Add hook to ~/.claude/settings.json
bash scripts/setup-hook.sh

# Preview what would change (no writes)
bash scripts/setup-hook.sh --dry-run
```

Merges `ExitPlanMode` hook into `~/.claude/settings.json` (backs up first). Skips if already configured.
**Restart Claude Code after running this.**

### Alternative: Claude Code Plugin (no manual hook needed)

```bash
/plugin marketplace add backnotprop/plannotator
/plugin install plannotator@plannotator
# IMPORTANT: Restart Claude Code after plugin install
```

---

## Pattern 3: Plan Review (Before Coding)

> Triggered automatically via hook when Claude Code exits plan mode.

When your agent finishes planning (Claude Code: `Shift+Tab×2` to enter plan mode), plannotator opens automatically:

1. **View** the agent's plan in the visual UI
2. **Annotate** with clear intent:
   - `delete` — remove risky or unnecessary step
   - `insert` — add missing step
   - `replace` — revise incorrect approach
   - `comment` — clarify constraints or acceptance criteria
3. **Submit** one outcome:
   - **Approve** → agent proceeds with implementation
   - **Request changes** → annotations are sent back as structured feedback for replanning

---

## Pattern 4: Code Review (After Coding)

```bash
bash scripts/review.sh          # Review all uncommitted changes
bash scripts/review.sh HEAD~1   # Review a specific commit
bash scripts/review.sh main...HEAD  # Review branch diff
```

Launches `plannotator review` UI. Select line numbers to annotate, switch unified/split views, attach images.

---

## Pattern 5: Remote / Devcontainer Mode

```bash
bash scripts/configure-remote.sh          # Interactive setup (SSH, devcontainer, WSL)
bash scripts/configure-remote.sh --show   # View current configuration
bash scripts/configure-remote.sh --port 9999  # Set port directly
```

Manual environment variables:

```bash
export PLANNOTATOR_REMOTE=1    # No auto browser open
export PLANNOTATOR_PORT=9999   # Fixed port for forwarding
```

| Variable | Description |
|----------|-------------|
| `PLANNOTATOR_REMOTE` | Remote mode (no auto browser open) |
| `PLANNOTATOR_PORT` | Fixed local/forwarded port |
| `PLANNOTATOR_BROWSER` | Custom browser path/app |
| `PLANNOTATOR_SHARE_URL` | Custom share portal URL |

---

## Pattern 6: Status Check

```bash
bash scripts/check-status.sh
```

Checks: CLI version, Claude Code hook, Gemini CLI hook, Codex CLI config, OpenCode plugin, Obsidian installation, env vars, git repo.

---

## Pattern 7: Gemini CLI Integration

```bash
bash scripts/setup-gemini-hook.sh           # Configure hook + GEMINI.md
bash scripts/setup-gemini-hook.sh --dry-run # Preview changes
bash scripts/setup-gemini-hook.sh --hook-only  # Only settings.json
bash scripts/setup-gemini-hook.sh --md-only    # Only GEMINI.md
```

After setup:

```bash
gemini --approval-mode plan   # Hook fires on exit
plannotator review            # Code review after implementation
```

> **Note:** Gemini CLI supports `gemini hooks migrate --from-claude` to auto-migrate existing Claude Code hooks.
>
> **Tip:** Use the python3 JSON format for manual plan review — heredoc/echo can fail with `Failed to parse hook event from stdin`:
> ```bash
> python3 -c "
> import json; plan = open('plan.md').read()
> print(json.dumps({'tool_input': {'plan': plan, 'permission_mode': 'acceptEdits'}}))" \
>   | plannotator > /tmp/plannotator_feedback.txt 2>&1 &
> ```

---

## Pattern 8: Codex CLI Integration

```bash
bash scripts/setup-codex-hook.sh           # Configure developer_instructions + prompt
bash scripts/setup-codex-hook.sh --dry-run # Preview changes
```

After setup:

```bash
/prompts:plannotator       # Use plannotator agent prompt
plannotator review HEAD~1  # Code review after implementation
```

> **Tip:** Same python3 JSON format as Gemini applies here for manual plan review.

---

## Pattern 9: OpenCode Setup

```bash
bash scripts/setup-opencode-plugin.sh   # Automated (recommended)
```

Or add manually to `opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["@plannotator/opencode@latest"]
}
```

Restart OpenCode. Available slash commands:
- `/plannotator-review` — open code review UI for current git diff
- `/plannotator-annotate <file.md>` — annotate a markdown file

The `submit_plan` tool is automatically available to the agent for plan submission.

---

## Pattern 10: Notes Integration (Obsidian / Bear / Manual Save)

Auto-save approved plans to your notes app with YAML frontmatter and tags.

### Setup

1. Trigger a plan review (any method), then click **⚙️ Settings → Saving** tab
2. Toggle ON **Obsidian Integration** or **Bear Notes**
3. For Obsidian: select vault from dropdown (auto-detected) or enter custom path; set folder name (default: `plannotator`)
4. Settings are stored in **cookies** (persist across restarts — requires system browser, not headless)

> **Tip (vault not detected):** Open Obsidian and create a vault first — plannotator reads `~/Library/Application Support/obsidian/obsidian.json` (macOS) / `~/.config/obsidian/obsidian.json` (Linux).

### Obsidian Configuration

| Setting | Description | Default |
|---------|-------------|---------|
| **Vault** | Path to Obsidian vault | Auto-detected |
| **Folder** | Subfolder in vault for plans | `plannotator` |
| **Custom Path** | Manual path if auto-detect fails | — |

### Saved File Format

```
Filename: {Title} - {Month} {Day}, {Year} {Hour}-{Minute}{am/pm}.md
Example:  User Authentication - Feb 22, 2026 10-45pm.md
```

```yaml
---
created: 2026-02-22T22:45:30.000Z
source: plannotator
tags: [plannotator, project-name, typescript, ...]
---
# Original plan content...
```

Tags: `plannotator` (always) + project name + first 3 H1 words + code block languages.

### Bear Notes (Alternative)

Toggle ON **Bear Notes** in Settings → Saving. Plans saved via `bear://x-callback-url/create`. Validate:

```bash
open "bear://x-callback-url/create?title=Plannotator%20Check&text=Bear%20callback%20OK"
```

| Feature | Obsidian | Bear |
|---------|----------|------|
| Storage | File system | x-callback-url |
| Frontmatter | YAML | None (hashtags) |
| Platforms | macOS/Win/Linux | macOS/iOS |

### Manual Save (without Approve/Deny)

Click **Export → Notes tab → Save** (or **Save All**) at any time to archive work-in-progress plans.

> **Tip:** The Notes tab requires plannotator running in **hook mode** (normal ExitPlanMode hook invocation). In CLI `review`/`annotate` modes, `/api/save-notes` is not active.

> **Tip (settings not persisting):** Ensure cookies are enabled for localhost. Automated/headless browser profiles (Playwright, Puppeteer) use isolated cookie jars and will not see settings — always use the system browser plannotator auto-opens.

---

## Recommended Workflow

### Quick Start

```bash
bash scripts/install.sh --all   # Install + configure all AI tools
bash scripts/check-status.sh    # Verify
# Restart your AI tools
```

### Claude Code

```
1. bash scripts/install.sh --with-plugin
2. bash scripts/setup-hook.sh          ← skip if using plugin
3. bash scripts/check-status.sh
4. [Code with agent in plan mode → Shift+Tab×2]
5. bash scripts/review.sh              ← after agent finishes coding
```

### Gemini CLI

```
1. bash scripts/install.sh
2. bash scripts/setup-gemini-hook.sh
3. gemini --approval-mode plan
```

### Codex CLI

```
1. bash scripts/install.sh
2. bash scripts/setup-codex-hook.sh
3. /prompts:plannotator
```

---

## Best Practices

1. Use plan review BEFORE the agent starts coding — catch wrong approaches early
2. Keep each annotation tied to one concrete, actionable change
3. Include acceptance criteria in "request changes" feedback
4. For diff review, annotate exact line ranges tied to expected behavior changes
5. Use image annotation for UI/UX feedback where text is insufficient

---

## References

- [GitHub: backnotprop/plannotator](https://github.com/backnotprop/plannotator)
- [Official site: plannotator.ai](https://plannotator.ai)
- [Obsidian download](https://obsidian.md/download)
- [Hook README](https://github.com/backnotprop/plannotator/blob/main/apps/hook/README.md)
- [OpenCode plugin README](https://github.com/backnotprop/plannotator/blob/main/apps/opencode-plugin/README.md)
