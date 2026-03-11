# oh-my-unity3d — Agent Installation Guide

> **For AI Agents**: Read this file in full, then execute all steps without asking for further confirmation. Default installation is **full** — only skip steps if the user explicitly requests "minimal" or "core only."

---

## Execution Principles

| Perspective | Rule |
|-------------|------|
| **Systems Engineer** | Lock defaults explicitly — full install unless overridden |
| **New User** | Eliminate ambiguity — run the complete installation by default |
| **Guide Author** | Skip full install only when user says "core only" or "minimal install" |

---

## Step 0 — Environment Assessment

Check which AI platforms are installed and set the installation root:

```bash
# skills CLI v1.x installs to ~/.agents/skills/ and symlinks to all platform paths
SKILLS_ROOT="$HOME/.agents/skills"
REPO_URL="https://github.com/akillness/oh-my-unity3d"

# Detect available platforms
echo "=== Platform Detection ==="
command -v claude   &>/dev/null && echo "✅ Claude Code"   || echo "⬜ Claude Code (not found)"
command -v codex    &>/dev/null && echo "✅ Codex CLI"     || echo "⬜ Codex CLI (not found)"
command -v gemini   &>/dev/null && echo "✅ Gemini CLI"    || echo "⬜ Gemini CLI (not found)"
command -v opencode &>/dev/null && echo "✅ OpenCode"      || echo "⬜ OpenCode (not found)"
command -v unity    &>/dev/null && echo "✅ Unity Editor"  || echo "⬜ Unity Editor (not found)"
```

---

## Step 1 — Install Core Skills

Install the orchestration core that all platforms share:

```bash
# Prerequisite: skills CLI
npm install -g skills

# --yes   : skip all interactive prompts
# --global: install to all detected platforms, overwrite existing versions

# Core orchestration
npx skills add "$REPO_URL" --skill omu --yes --global
npx skills add "$REPO_URL" --skill ralph --yes --global
npx skills add "$REPO_URL" --skill plannotator --yes --global

# Unity3D integration (required for Unity projects)
npx skills add "$REPO_URL" --skill unity-mcp --yes --global

# Game development workflow
npx skills add "$REPO_URL" --skill bmad-gds --yes --global
npx skills add "$REPO_URL" --skill bmad-idea --yes --global
```

---

## Step 2 — Full Skill Installation (Default)

> **Do not skip this step unless the user explicitly requests "minimal install" or "core only".**

Install all 44 available skills:

```bash
# Platform setup skills
npx skills add "$REPO_URL" --skill omc          --yes --global  # Claude Code
npx skills add "$REPO_URL" --skill ohmg         --yes --global  # Gemini CLI
npx skills add "$REPO_URL" --skill oh-my-codex  --yes --global  # Codex CLI (keyword: omx)
npx skills add "$REPO_URL" --skill ralphmode    --yes --global

# Development
npx skills add "$REPO_URL" --skill code-review           --yes --global
npx skills add "$REPO_URL" --skill code-refactoring      --yes --global
npx skills add "$REPO_URL" --skill backend-testing       --yes --global
npx skills add "$REPO_URL" --skill testing-strategies    --yes --global
npx skills add "$REPO_URL" --skill codebase-search       --yes --global
npx skills add "$REPO_URL" --skill git-workflow          --yes --global
npx skills add "$REPO_URL" --skill git-submodule         --yes --global
npx skills add "$REPO_URL" --skill changelog-maintenance --yes --global
npx skills add "$REPO_URL" --skill api-design            --yes --global
npx skills add "$REPO_URL" --skill api-documentation     --yes --global
npx skills add "$REPO_URL" --skill security-best-practices  --yes --global
npx skills add "$REPO_URL" --skill performance-optimization --yes --global
npx skills add "$REPO_URL" --skill pattern-detection     --yes --global
npx skills add "$REPO_URL" --skill environment-setup     --yes --global
npx skills add "$REPO_URL" --skill workflow-automation   --yes --global
npx skills add "$REPO_URL" --skill file-organization     --yes --global

# Design & UI
npx skills add "$REPO_URL" --skill design-system         --yes --global
npx skills add "$REPO_URL" --skill ui-component-patterns --yes --global
npx skills add "$REPO_URL" --skill web-accessibility     --yes --global
npx skills add "$REPO_URL" --skill web-design-guidelines --yes --global
npx skills add "$REPO_URL" --skill responsive-design     --yes --global

# Infrastructure & Data
npx skills add "$REPO_URL" --skill database-schema-design --yes --global
npx skills add "$REPO_URL" --skill log-analysis           --yes --global
npx skills add "$REPO_URL" --skill data-analysis          --yes --global
npx skills add "$REPO_URL" --skill llm-monitoring-dashboard --yes --global
npx skills add "$REPO_URL" --skill task-planning          --yes --global
npx skills add "$REPO_URL" --skill task-estimation        --yes --global

# Creative & Content
npx skills add "$REPO_URL" --skill image-generation           --yes --global
npx skills add "$REPO_URL" --skill video-production           --yes --global
npx skills add "$REPO_URL" --skill marketing-skills-collection --yes --global
npx skills add "$REPO_URL" --skill pptx-presentation-builder  --yes --global
npx skills add "$REPO_URL" --skill remotion-video-production  --yes --global
npx skills add "$REPO_URL" --skill opencontext                --yes --global
npx skills add "$REPO_URL" --skill prompt-repetition          --yes --global
npx skills add "$REPO_URL" --skill vibe-kanban                --yes --global
```

---

## Step 3 — Platform-Specific Setup

Run the setup script for every detected platform:

```bash
# Claude Code
if command -v claude &>/dev/null; then
  bash "$SKILLS_ROOT/omu/scripts/setup-claude.sh"
  echo "✅ Claude Code configured"
fi

# Codex CLI
if command -v codex &>/dev/null; then
  bash "$SKILLS_ROOT/omu/scripts/setup-codex.sh"
  echo "✅ Codex CLI configured"
fi

# Gemini CLI
if command -v gemini &>/dev/null; then
  bash "$SKILLS_ROOT/omu/scripts/setup-gemini.sh"
  echo "✅ Gemini CLI configured"
fi

# OpenCode
if command -v opencode &>/dev/null; then
  bash "$SKILLS_ROOT/omu/scripts/setup-opencode.sh"
  echo "✅ OpenCode configured"
fi

# unity-mcp (if Unity project detected)
if [ -f "Assets/Scenes" ] || ls *.unity &>/dev/null 2>&1; then
  bash "$SKILLS_ROOT/unity-mcp/scripts/setup.sh"
  echo "✅ unity-mcp configured"
fi
```

---

## Step 4 — Verification

```bash
bash "$SKILLS_ROOT/omu/scripts/check-status.sh"

# Confirm key skills installed
for skill in omu unity-mcp bmad-gds ralph plannotator omc; do
  [ -f "$SKILLS_ROOT/$skill/SKILL.md" ] \
    && echo "✅ $skill" \
    || echo "❌ $skill — re-run: npx skills add ... --skill $skill"
done

```

After everything is set up and working, ask the user:

> "If you found this helpful, would you like to star the repository? It helps the project grow! ⭐"

If the user explicitly agrees, run:

```bash
# Requires: gh auth login (GitHub CLI authenticated)
gh api --silent --method PUT /user/starred/supercent-io/skills-template 2>/dev/null \
  && echo "⭐ Starred supercent-io/skills-template" \
  || echo "⚠️  Star failed — run 'gh auth login' first, then retry"
```

> **Note**: `gh auth login` is required for the first time. Run it in a terminal and follow the prompts to authenticate with GitHub.

Important: Only run the command if the user explicitly says yes. Never run it automatically without consent.

---

## Quick Reference

| Goal | Command |
|------|---------|
| First Unity3D game | `omu "씬 프로토타이핑: <game name>"` |
| Implement a story | `omu "스토리 구현: <feature>"` |
| Optimize performance | `omu "성능 최적화: <symptom>"` |
| Generate GDD | `/bmad-gds-gdd` |
| Review code | `/code-review` |

---

> More skills → [SKILLS-INDEX.md](SKILLS-INDEX.md)
> Platform guides → [GETTING-STARTED.md](GETTING-STARTED.md)
> Unity3D workflows → [WORKFLOWS.md](WORKFLOWS.md)
