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
npx skills add https://github.com/akillness/oh-unity3d --skill jeo --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill ralph --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill plannotator --yes --global

# Unity3D integration (required for Unity projects)
npx skills add https://github.com/akillness/oh-unity3d --skill unity-mcp --yes --global

# Game development workflow
npx skills add https://github.com/akillness/oh-unity3d --skill bmad-gds --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill bmad-idea --yes --global
```

---

## Step 2 — Full Skill Installation (Default)

> **Do not skip this step unless the user explicitly requests "minimal install" or "core only".**

Install all 44 available skills:

```bash
# Platform setup skills
npx skills add https://github.com/akillness/oh-unity3d --skill omc          --yes --global  # Claude Code
npx skills add https://github.com/akillness/oh-unity3d --skill ohmg         --yes --global  # Gemini CLI
npx skills add https://github.com/akillness/oh-unity3d --skill oh-my-codex  --yes --global  # Codex CLI (keyword: omx)
npx skills add https://github.com/akillness/oh-unity3d --skill ralphmode     --yes --global

# Development
npx skills add https://github.com/akillness/oh-unity3d --skill code-review           --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill code-refactoring      --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill backend-testing       --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill testing-strategies    --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill codebase-search       --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill git-workflow          --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill git-submodule         --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill changelog-maintenance --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill api-design            --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill api-documentation     --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill security-best-practices  --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill performance-optimization --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill pattern-detection     --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill environment-setup     --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill workflow-automation   --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill file-organization     --yes --global

# Design & UI
npx skills add https://github.com/akillness/oh-unity3d --skill design-system         --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill ui-component-patterns --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill web-accessibility     --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill web-design-guidelines --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill responsive-design     --yes --global

# Infrastructure & Data
npx skills add https://github.com/akillness/oh-unity3d --skill database-schema-design --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill log-analysis           --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill data-analysis          --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill llm-monitoring-dashboard --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill task-planning          --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill task-estimation        --yes --global

# Creative & Content
npx skills add https://github.com/akillness/oh-unity3d --skill image-generation           --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill video-production           --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill marketing-skills-collection --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill pptx-presentation-builder  --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill remotion-video-production  --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill opencontext               --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill prompt-repetition         --yes --global
npx skills add https://github.com/akillness/oh-unity3d --skill vibe-kanban               --yes --global
```

---

## Step 3 — Platform-Specific Setup

Run the setup script for every detected platform:

```bash
# Claude Code
if command -v claude &>/dev/null; then
  bash "$SKILLS_ROOT/jeo/scripts/setup-claude.sh"
  echo "✅ Claude Code configured"
fi

# Codex CLI
if command -v codex &>/dev/null; then
  bash "$SKILLS_ROOT/jeo/scripts/setup-codex.sh"
  echo "✅ Codex CLI configured"
fi

# Gemini CLI
if command -v gemini &>/dev/null; then
  bash "$SKILLS_ROOT/jeo/scripts/setup-gemini.sh"
  echo "✅ Gemini CLI configured"
fi

# OpenCode
if command -v opencode &>/dev/null; then
  bash "$SKILLS_ROOT/jeo/scripts/setup-opencode.sh"
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
bash "$SKILLS_ROOT/jeo/scripts/check-status.sh"

# Confirm key skills installed
for skill in jeo unity-mcp bmad-gds ralph plannotator omc; do
  [ -f "$SKILLS_ROOT/$skill/SKILL.md" ] \
    && echo "✅ $skill" \
    || echo "❌ $skill — re-run: npx skills add ... --skill $skill"
done
```

---

## Quick Reference

| Goal | Command |
|------|---------|
| First Unity3D game | `jeo "씬 프로토타이핑: <game name>"` |
| Implement a story | `jeo "스토리 구현: <feature>"` |
| Optimize performance | `jeo "성능 최적화: <symptom>"` |
| Generate GDD | `/bmad-gds-gdd` |
| Review code | `/code-review` |

---

> More skills → [SKILLS-INDEX.md](SKILLS-INDEX.md)
> Platform guides → [GETTING-STARTED.md](GETTING-STARTED.md)
> Unity3D workflows → [WORKFLOWS.md](WORKFLOWS.md)
