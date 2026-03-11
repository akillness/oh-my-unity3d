> 🌐 **English** | [한국어](README.ko.md)

# 🎮 oh-my-unity3d

<div align="center">

[![Version](https://img.shields.io/badge/version-2.3.0-blue?style=flat-square)](https://github.com/akillness/oh-my-unity3d/releases)
[![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)](LICENSE)
[![Unity](https://img.shields.io/badge/Unity-2021.3%2B-black?style=flat-square&logo=unity)](https://unity.com)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-supported-orange?style=flat-square)](https://claude.ai)
[![Codex CLI](https://img.shields.io/badge/Codex%20CLI-supported-green?style=flat-square)](https://openai.com)
[![Gemini CLI](https://img.shields.io/badge/Gemini%20CLI-supported-blue?style=flat-square)](https://gemini.google.com)
[![OpenCode](https://img.shields.io/badge/OpenCode-supported-purple?style=flat-square)](https://opencode.ai)
[![Skills](https://img.shields.io/badge/skills-45-yellow?style=flat-square)](#-skills-index)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-orange?logo=buy-me-a-coffee)](https://www.buymeacoffee.com/akillness3q)

**AI-driven Unity3D game development orchestration — Plan → Execute → Verify → Cleanup**

[Quick Start](#-quick-start) · [Workflows](#-unity3d-workflows) · [Skills](#-skills-index) · [Docs](#-documentation)

</div>

---

## 📦 Overview

`oh-my-unity3d` is a release-ready distribution for the **OMU** orchestration skill package, extended for Unity3D game development with **unity-mcp** integration.

```
Plan ──► Execute ──► Verify ──► Cleanup
 │          │           │
 │      unity-mcp    run_tests
 │      bmad-gds     read_console
 └──   omc / bmad    editor_state
```

| Layer | Component | Role |
|-------|-----------|------|
| **Orchestration** | `omu` | Plan → Execute → Verify → Cleanup pipeline |
| **Game Dev** | `bmad-gds` | Brainstorm → GDD → Architecture → Sprint → Dev → Review |
| **Unity Editor** | `unity-mcp` | 37 MCP tools for direct Unity Editor control |
| **Planning Gate** | `ralph` + `plannotator` | Mandatory plan review before execution |
| **Verification** | `agent-browser` + unity-mcp | Browser + Unity runtime verification loop |

---

## ✨ What's New in v2.3.0

| # | Change | Details |
|---|--------|---------|
| 🆕 | **AI auto-configure MCP** | `unity-mcp` SKILL.md now instructs the AI agent to automatically write correct MCP config to `settings.json` when invoked |
| 🔄 | **Step-by-step setup flow** | SKILL.md rewritten with explicit Step 1–4 guide (Package → Start → Config → Verify) |
| 🐛 | **Compatibility note fix** | Removed incorrect Python 3.10+/uv requirement from skill metadata |

<details>
<summary>v2.1.0</summary>

| # | Change | Details |
|---|--------|---------|
| 🆕 | **unity-mcp skill** | New skill — configures and calls all 37 Unity Editor MCP tools |
| 🆕 | **Unity3D verify loop** | OMU VERIFY now runs `run_tests → read_console → editor_state` auto-fix loop |
| 🆕 | **5 Unity3D workflows** | Scene prototyping, C# dev, asset pipeline, UI/visual, perf optimization |
| 🆕 | **SKILLS-INDEX.md** | Full 44-skill directory with categories and quick-select guide |
| 🆕 | **WORKFLOWS.md** | End-to-end Unity3D workflow documentation |
| 🔄 | **oh-my-codex → omx** | Codex CLI setup skill renamed to `omx` |
| 🔄 | **OpenCode support** | All platform tables updated with 4th platform |
| 🔄 | **design-system** | Unity3D Design Guide section added (color palette, typography, sprite naming) |

</details>

---

## 🚀 Quick Start (For LLM Agents)

> Prerequisite: Install the `skills` CLI before running any `npx skills add` commands.

```bash
npm install -g skills
```

Send this to your LLM agent to begin the full installation:

```bash
# Read the full installation guide and proceed automatically
curl -s https://raw.githubusercontent.com/akillness/oh-my-unity3d/main/setup-all-skills-prompt.md
```

More skill installs → [GETTING-STARTED.md](GETTING-STARTED.md) · Platform-specific guides → [GETTING-STARTED.md#platform](GETTING-STARTED.md)

---

## 🛠 Manual Quick Start

### 1. Install

```bash
# Clone
git clone https://github.com/akillness/oh-my-unity3d.git
cd oh-my-unity3d

# Install all skills
bash .unity-skills/omu/scripts/install.sh --all
```

### 2. Set Up Your AI Platform

```bash
bash .unity-skills/omu/scripts/setup-claude.sh    # Claude Code
bash .unity-skills/omu/scripts/setup-codex.sh     # Codex CLI
bash .unity-skills/omu/scripts/setup-gemini.sh    # Gemini CLI
bash .unity-skills/omu/scripts/setup-opencode.sh  # OpenCode
```

### 3. Connect Unity Editor (unity-mcp)

```bash
# Auto-configure MCP for your platform
bash .unity-skills/unity-mcp/scripts/setup.sh

# In Unity Editor: Window → MCP → Start
curl http://localhost:8080/health  # Verify connection
```

> **How it works**: Unity Editor manages the `mcp-for-unity` HTTP server automatically.
> AI clients connect via `"url": "http://localhost:8080/mcp"` — no Python subprocess needed.

### 4. Run Your First Workflow

```bash
omu "씬 프로토타이핑: 내 첫 번째 게임"
```

---

## 🎯 Unity3D Workflows

All workflows are orchestrated by `omu` with an automatic Unity3D verification loop in the VERIFY phase.

### Verification Loop (auto-runs in every VERIFY phase)

```
① run_tests     →  Unity Test Runner pass/fail
② read_console  →  Error / Exception detection
③ editor_state  →  Scene load state check
④ Fix loop      →  Auto-retry up to 3× on failure
```

### Workflow Summary

| # | Workflow | Roles | Key Tools |
|---|----------|-------|-----------|
| 1 | **Scene Prototyping** | PM + Designer | `bmad-gds-gdd` → `manage_scene` → `manage_probuilder` |
| 2 | **Story → C# Dev** | PM + Dev | `bmad-gds-dev-story` → `create_script` → `validate_script` |
| 3 | **Asset Pipeline** | Designer + Dev | `manage_asset` → `manage_texture` → `batch_execute` |
| 4 | **UI / Visual** | Designer | `design-system` → `manage_ui` → `manage_animation` |
| 5 | **Perf & Debug** | Dev + QA | `read_console` → `find_gameobjects` → `batch_execute` |

> Full workflow details → [WORKFLOWS.md](WORKFLOWS.md)

---

## 🛠 unity-mcp Tools

37 MCP tools for AI-driven Unity Editor control, mapped by role:

<details>
<summary><strong>PM Context</strong> — Sprint planning, story tracking</summary>

| Tool / Resource | Scenario | Paired Skill |
|----------------|----------|--------------|
| `project_info` | Project status → sprint plan | `bmad-gds-sprint-planning` |
| `get_tests` | Test coverage → release checklist | `bmad-gds-sprint-status` |
| `editor_state` | Scene/build state → demo check | `task-planning` |
| `read_console` | Bug reports → story creation | `log-analysis` |

</details>

<details>
<summary><strong>Designer Context</strong> — UI/UX, visuals, prototyping</summary>

| Tool | Scenario | Paired Skill |
|------|----------|--------------|
| `manage_ui` | UI hierarchy creation | `design-system`, `ui-component-patterns` |
| `manage_material`, `manage_shader` | Visual style prototyping | `design-system` |
| `manage_vfx`, `manage_animation` | Motion / effects iteration | `bmad-gds-quick-prototype` |
| `manage_probuilder` | Level greyboxing | `bmad-gds-gdd` |
| `manage_texture` | Asset import settings | `file-organization` |

</details>

<details>
<summary><strong>Developer Context</strong> — Scripts, tests, optimization</summary>

| Tool | Scenario | Paired Skill |
|------|----------|--------------|
| `create_script`, `validate_script` | C# generation + Roslyn validation | `bmad-gds-dev-story` |
| `script_apply_edits` | Code apply after validation | `code-refactoring` |
| `run_tests`, `get_test_job` | Unity Test Runner | `testing-strategies` |
| `read_console` | Runtime error collection | `log-analysis` |
| `batch_execute` | Batch ops 10–100× faster | `workflow-automation` |
| `manage_gameobject`, `manage_components` | Scene object manipulation | `bmad-gds-quick-dev` |

</details>

---

## 📚 Skills Index

45 skills organized by category:

### 🎮 Game Development (Unity3D)

| Skill | Description | Usage |
|-------|-------------|-------|
| **unity-mcp** 🆕 | Unity Editor MCP bridge — 37 tools | Always with Unity3D work |
| **bmad-gds** | Game dev studio: Brainstorm → GDD → Sprint → Dev → Review | Core workflow |
| **bmad-idea** | Creative intelligence for ideation | Optional — new features |

### 🔧 Orchestration

| Skill | Description | Keyword |
|-------|-------------|---------|
| **omu** | Plan → Execute → Verify → Cleanup pipeline | `omu` |
| **ralph** | Spec-first self-completing dev loop | `ralph` |
| **plannotator** | Visual plan review gate | `plannotator` |

### 🖥 Platform Setup

| Skill | Platform | Keyword |
|-------|----------|---------|
| **omc** | Claude Code | `omc` |
| **ohmg** | Gemini CLI | `ohmg` |
| **omx** (was oh-my-codex) 🔄 | Codex CLI | `omx` |
| **omu** setup-opencode.sh | OpenCode | — |

### 💻 Development

`code-review` · `code-refactoring` · `backend-testing` · `testing-strategies` · `codebase-search` · `git-workflow` · `git-submodule` · `changelog-maintenance` · `api-design` · `api-documentation` · `security-best-practices` · `performance-optimization` · `pattern-detection` · `environment-setup` · `workflow-automation` · `file-organization`

### 🎨 Design & UI

`design-system` _(Unity3D Design Guide included)_ · `ui-component-patterns` · `web-accessibility` · `web-design-guidelines` · `responsive-design`

### 📊 Infrastructure & Data

`database-schema-design` · `log-analysis` · `data-analysis` · `llm-monitoring-dashboard` · `task-planning` · `task-estimation`

### 🌟 Creative & Content

`image-generation` · `video-production` · `marketing-skills-collection` · `pptx-presentation-builder` · `remotion-video-production` · `opencontext` · `prompt-repetition` · `vibe-kanban` · `ralphmode`

### 🤖 AI/ML Research

| Skill | Description | Keyword |
|-------|-------------|---------|
| **autoresearch** 🆕 | Autonomous ML experimentation loop by Karpathy — AI agent runs 5-min GPU experiments, git-ratchets improvements overnight | `autoresearch` |

> Full index with quick-select guide → [SKILLS-INDEX.md](SKILLS-INDEX.md)

---

## 🌐 Platform Support

| Platform | Setup Skill | Planning | Execution | Verification |
|----------|-------------|----------|-----------|--------------|
| **Claude Code** | `omc` | `ralph` + `plannotator` hook | `omc` team mode | `agent-browser` + unity-mcp |
| **Codex CLI** | `omx` | `plan.md` + `plannotator` loop | `bmad` fallback | `agent-browser` + unity-mcp |
| **Gemini CLI** | `ohmg` | `plan.md` + AfterAgent hook | `bmad` or `ohmg` | `agent-browser` + unity-mcp |
| **OpenCode** | `omu` setup-opencode.sh | slash-command workflow | `omx` or `bmad` | `agent-browser` + unity-mcp |

---

## 📁 Repository Layout

```
oh-my-unity3d/
├── README.md                    ← You are here
├── SKILLS-INDEX.md              ← Full 44-skill directory
├── GETTING-STARTED.md           ← Installation & first workflow
├── WORKFLOWS.md                 ← 5 Unity3D workflow guides
├── CLAUDE.md                    ← AI agent project context
└── .unity-skills/
    ├── omu/                     ← OMU orchestration (core)
    │   ├── SKILL.md
    │   ├── SKILL.toon
    │   ├── references/FLOW.md
    │   └── scripts/             ← install, setup-*, check-status, ...
    ├── unity-mcp/               ← Unity Editor MCP bridge 🆕
    │   ├── SKILL.md
    │   ├── SKILL.toon
    │   └── scripts/setup.sh
    ├── bmad-gds/                ← Game dev workflow
    ├── bmad-idea/               ← Creative intelligence
    ├── omc/                     ← Claude Code setup
    ├── ohmg/                    ← Gemini CLI setup
    ├── oh-my-codex/             ← Codex CLI setup (keyword: omx)
    ├── ralph/                   ← Spec-first dev loop
    ├── plannotator/             ← Plan review gate
    ├── autoresearch/            ← Autonomous ML experimentation (Karpathy) 🆕
    └── [35 domain skills]/
```

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [SKILLS-INDEX.md](SKILLS-INDEX.md) | 44-skill directory with categories, keywords, and quick-select guide |
| [GETTING-STARTED.md](GETTING-STARTED.md) | Installation, platform setup, first workflow walkthrough |
| [WORKFLOWS.md](WORKFLOWS.md) | 5 Unity3D workflows with step tables and quick-start examples |
| [CLAUDE.md](CLAUDE.md) | AI agent project context — unity-mcp tools, OMU verify loop |
| [.unity-skills/omu/SKILL.md](.unity-skills/omu/SKILL.md) | Full OMU orchestration reference |
| [.unity-skills/unity-mcp/SKILL.md](.unity-skills/unity-mcp/SKILL.md) | unity-mcp tool reference (37 tools, role mappings) |

---

## 📋 Changelog

### `v2.4.0` — Autonomous ML Research

- **Added** `autoresearch` skill — Karpathy's autonomous ML experimentation framework; AI agent runs 5-min GPU experiments, git-ratchets improvements, logs to `results.tsv`

### `v2.3.0` — AI Auto-Configure MCP

- **Added** AI auto-configure flow in `unity-mcp` SKILL.md — when invoked, the agent automatically writes correct MCP config (`"url"`) to the platform settings file
- **Changed** SKILL.md setup section rewritten as Step 1–4 (Package → Start → Config → Verify)
- **Fixed** Skill metadata: removed incorrect Python 3.10+/uv dependency

### `v2.2.0` — MCP Config Hotfix

- **Fixed** unity-mcp MCP config: changed from `"command": "python"` (subprocess) to `"url": "http://localhost:8080/mcp"` (HTTP) — resolves tools not appearing in `/mcp` after installation
- **Updated** `setup.sh` to write correct URL-based config for all platforms
- **Updated** `SKILL.md` with correct platform configs and troubleshooting note

### `v2.1.0` — Unity3D Integration Release

- **Added** `unity-mcp` skill — Unity Editor MCP bridge with 37 tools, role-based mappings, and platform auto-setup script
- **Added** Unity3D verification loop in OMU VERIFY phase (`run_tests → read_console → editor_state`, up to 3 retries)
- **Added** 5 Unity3D workflow templates in `WORKFLOWS.md`
- **Added** `SKILLS-INDEX.md` — 44-skill directory
- **Added** `GETTING-STARTED.md` — onboarding guide with unity-mcp integration
- **Added** `CLAUDE.md` — AI agent project context
- **Added** Unity3D Design Guide to `design-system` skill
- **Changed** `oh-my-codex` keyword renamed to `omx`
- **Changed** OpenCode added as 4th supported platform across all documentation

### `v2.0.0` — OMU Clean Release

- Removed `agentation` integration and related keywords (`annotate`, `agentui`)
- Reduced the skill to the supported release surface
- Aligned setup scripts with the new platform contract
- Rewrote release docs around actual package contents

---

## License

MIT — see [LICENSE](LICENSE) for details.

---

<div align="center">
Built with <a href="https://github.com/akillness/oh-my-unity3d">OMU</a> · Powered by <a href="https://github.com/CoplayDev/unity-mcp">unity-mcp</a>
</div>
