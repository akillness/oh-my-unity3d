> 🌐 [English](README.md) | **한국어**

# 🎮 oh-my-unity3d

<div align="center">

[![Version](https://img.shields.io/badge/version-2.6.0-blue?style=flat-square)](https://github.com/akillness/oh-my-unity3d/releases)
[![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)](LICENSE)
[![Unity](https://img.shields.io/badge/Unity-2021.3%2B-black?style=flat-square&logo=unity)](https://unity.com)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-supported-orange?style=flat-square)](https://claude.ai)
[![Codex CLI](https://img.shields.io/badge/Codex%20CLI-supported-green?style=flat-square)](https://openai.com)
[![Gemini CLI](https://img.shields.io/badge/Gemini%20CLI-supported-blue?style=flat-square)](https://gemini.google.com)
[![OpenCode](https://img.shields.io/badge/OpenCode-supported-purple?style=flat-square)](https://opencode.ai)
[![Skills](https://img.shields.io/badge/skills-48-yellow?style=flat-square)](#-스킬-인덱스)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-orange?logo=buy-me-a-coffee)](https://www.buymeacoffee.com/akillness3q)

**AI 기반 Unity3D 게임 개발 오케스트레이션 — Plan → Execute → Verify → Cleanup**

[빠른 시작](#-빠른-시작) · [워크플로우](#-unity3d-워크플로우) · [스킬](#-스킬-인덱스) · [문서](#-문서)

</div>

---

## 📦 개요

`oh-my-unity3d`는 **OMU** 오케스트레이션 스킬 패키지의 배포 버전으로, **unity-mcp** 연동을 통해 Unity3D 게임 개발에 특화되어 있습니다.

```
Plan ──► Execute ──► Verify ──► Cleanup
 │          │           │
 │      unity-mcp    run_tests
 │      bmad-gds     read_console
 └──   omc / bmad    editor_state
```

| 레이어 | 컴포넌트 | 역할 |
|--------|----------|------|
| **오케스트레이션** | `omu` | Plan → Execute → Verify → Cleanup 파이프라인 |
| **게임 개발** | `bmad-gds` | Brainstorm → GDD → Architecture → Sprint → Dev → Review |
| **Unity 에디터** | `unity-mcp` | Unity 에디터 직접 제어를 위한 MCP 도구 37종 |
| **플래닝 게이트** | `ralph` + `plannotator` | 실행 전 필수 플랜 검토 단계 |
| **검증** | `agent-browser` + unity-mcp | 브라우저 + Unity 런타임 검증 루프 |

---

## ✨ v2.6.0 새로운 기능

| # | 변경 내용 | 상세 설명 |
|---|-----------|-----------|
| 🆕 | **.omu 게임 관리 폴더** | 게임 라이프사이클(기획→개발→QA→수익성) 추적을 위한 `.omu/` 폴더 — 장기계획, 스프린트 계획, 진행 체크리스트, 히스토리 아카이브 |
| 🆕 | **게임 개발 단계 플로우** | OMU SKILL.md에 게임 단계 감지(기획/개발/QA/수익성) 및 각 페이즈에서 `.omu/` 연동 추가 |
| 🆕 | **지속적 계획 추적** | `long-term-plan.md`(컨셉/규칙/게임성)와 `short-term-plan.md`(시스템/밸런스/배치/연출)를 PLAN 시작 시 자동 로드 |
| 🆕 | **진행 및 히스토리** | EXECUTE 중 `progress.md` `[x]` 자동 체크, CLEANUP 시 `history/YYYYMMDD-<task>.md`로 아카이브 및 완료 항목 제거 |

<details>
<summary>v2.5.0</summary>

| # | 변경 내용 | 상세 설명 |
|---|-----------|-----------|
| 🆕 | **AI MCP 자동 설정** | `unity-mcp` SKILL.md 호출 시 AI 에이전트가 `settings.json`에 올바른 MCP 설정을 자동으로 작성 |
| 🔄 | **단계별 설치 가이드** | SKILL.md를 Step 1–4(패키지 설치 → 서버 시작 → 설정 → 확인) 형식으로 재작성 |
| 🐛 | **호환성 정보 수정** | 스킬 메타데이터에서 잘못된 Python 3.10+/uv 의존성 제거 |

</details>

<details>
<summary>v2.1.0</summary>

| # | 변경 내용 | 상세 설명 |
|---|-----------|-----------|
| 🆕 | **unity-mcp skill** | 신규 스킬 — Unity 에디터 MCP 도구 37종 구성 및 호출 지원 |
| 🆕 | **Unity3D 검증 루프** | OMU VERIFY 단계에서 `run_tests → read_console → editor_state` 자동 수정 루프 실행 |
| 🆕 | **Unity3D 워크플로우 5종** | 씬 프로토타이핑, C# 개발, 에셋 파이프라인, UI/비주얼, 성능 최적화 |
| 🆕 | **SKILLS-INDEX.md** | 카테고리별 빠른 선택 가이드가 포함된 47종 스킬 디렉토리 |
| 🆕 | **WORKFLOWS.md** | Unity3D 워크플로우 전체 문서 |
| 🔄 | **oh-my-codex → omx** | Codex CLI 설정 스킬 이름 변경 |
| 🔄 | **OpenCode 지원** | 모든 플랫폼 테이블에 4번째 플랫폼 추가 |
| 🔄 | **design-system** | Unity3D 디자인 가이드 섹션 추가 (색상 팔레트, 타이포그래피, 스프라이트 명명 규칙) |

</details>

---

## 🚀 빠른 시작 (LLM 에이전트용)

> 전제 조건: `npx skills add` 명령을 실행하기 전에 `skills` CLI를 먼저 설치하세요.

```bash
npm install -g skills
```

아래 명령을 LLM 에이전트에 전달하면 전체 설치가 자동으로 시작됩니다.

```bash
# 전체 설치 가이드를 읽고 자동으로 진행
curl -s https://raw.githubusercontent.com/akillness/oh-my-unity3d/main/setup-all-skills-prompt.md
```

추가 스킬 설치 → [GETTING-STARTED.md](GETTING-STARTED.md) · 플랫폼별 가이드 → [GETTING-STARTED.md#platform](GETTING-STARTED.md)

---

## 🛠 수동 설치

### 1. 설치

```bash
# 클론
git clone https://github.com/akillness/oh-my-unity3d.git
cd oh-my-unity3d

# 전체 스킬 설치
bash .unity-skills/omu/scripts/install.sh --all
```

### 2. AI 플랫폼 설정

```bash
bash .unity-skills/omu/scripts/setup-claude.sh    # Claude Code
bash .unity-skills/omu/scripts/setup-codex.sh     # Codex CLI
bash .unity-skills/omu/scripts/setup-gemini.sh    # Gemini CLI
bash .unity-skills/omu/scripts/setup-opencode.sh  # OpenCode
```

### 3. Unity 에디터 연결 (unity-mcp)

```bash
# 플랫폼에 맞는 MCP 자동 구성
bash .unity-skills/unity-mcp/scripts/setup.sh

# Unity 에디터에서: Window → MCP → Start
curl http://localhost:8080/health  # 연결 확인
```

> **동작 원리**: Unity Editor가 `mcp-for-unity` HTTP 서버를 자동으로 실행합니다.
> AI 클라이언트는 `"url": "http://localhost:8080/mcp"` 로 연결합니다 — Python subprocess 불필요.

### 4. 첫 번째 워크플로우 실행

```bash
omu "씬 프로토타이핑: 내 첫 번째 게임"
```

---

## 🎯 Unity3D 워크플로우

모든 워크플로우는 `omu`가 오케스트레이션하며, VERIFY 단계에서 Unity3D 검증 루프가 자동으로 실행됩니다.

### 검증 루프 (모든 VERIFY 단계에서 자동 실행)

```
① run_tests     →  Unity Test Runner 성공/실패 확인
② read_console  →  에러 / 예외 감지
③ editor_state  →  씬 로드 상태 확인
④ Fix loop      →  실패 시 최대 3회 자동 재시도
```

### 워크플로우 요약

| # | 워크플로우 | 담당 역할 | 주요 도구 |
|---|-----------|----------|----------|
| 1 | **Scene Prototyping** | PM + Designer | `bmad-gds-gdd` → `manage_scene` → `manage_probuilder` |
| 2 | **Story → C# Dev** | PM + Dev | `bmad-gds-dev-story` → `create_script` → `validate_script` |
| 3 | **Asset Pipeline** | Designer + Dev | `manage_asset` → `manage_texture` → `batch_execute` |
| 4 | **UI / Visual** | Designer | `design-system` → `manage_ui` → `manage_animation` |
| 5 | **Perf & Debug** | Dev + QA | `read_console` → `find_gameobjects` → `batch_execute` |

> 워크플로우 상세 설명 → [WORKFLOWS.md](WORKFLOWS.md)

---

## 🛠 unity-mcp 도구

AI 기반 Unity 에디터 제어를 위한 MCP 도구 37종을 역할별로 분류했습니다.

<details>
<summary><strong>PM 맥락</strong> — 스프린트 계획, 스토리 추적</summary>

| 도구 / 리소스 | 활용 시나리오 | 연계 스킬 |
|--------------|-------------|----------|
| `project_info` | 프로젝트 현황 → 스프린트 계획 | `bmad-gds-sprint-planning` |
| `get_tests` | 테스트 커버리지 → 릴리즈 체크리스트 | `bmad-gds-sprint-status` |
| `editor_state` | 씬/빌드 상태 → 데모 점검 | `task-planning` |
| `read_console` | 버그 리포트 → 스토리 생성 | `log-analysis` |

</details>

<details>
<summary><strong>디자이너 맥락</strong> — UI/UX, 비주얼, 프로토타이핑</summary>

| 도구 | 활용 시나리오 | 연계 스킬 |
|------|-------------|----------|
| `manage_ui` | UI 계층 구조 생성 | `design-system`, `ui-component-patterns` |
| `manage_material`, `manage_shader` | 비주얼 스타일 프로토타이핑 | `design-system` |
| `manage_vfx`, `manage_animation` | 모션 / 이펙트 반복 작업 | `bmad-gds-quick-prototype` |
| `manage_probuilder` | 레벨 그레이박싱 | `bmad-gds-gdd` |
| `manage_texture` | 에셋 임포트 설정 | `file-organization` |

</details>

<details>
<summary><strong>개발자 맥락</strong> — 스크립트, 테스트, 최적화</summary>

| 도구 | 활용 시나리오 | 연계 스킬 |
|------|-------------|----------|
| `create_script`, `validate_script` | C# 생성 + Roslyn 유효성 검사 | `bmad-gds-dev-story` |
| `script_apply_edits` | 검증 후 코드 적용 | `code-refactoring` |
| `run_tests`, `get_test_job` | Unity Test Runner 실행 | `testing-strategies` |
| `read_console` | 런타임 에러 수집 | `log-analysis` |
| `batch_execute` | 배치 작업으로 10~100배 빠른 처리 | `workflow-automation` |
| `manage_gameobject`, `manage_components` | 씬 오브젝트 조작 | `bmad-gds-quick-dev` |

</details>

---

## 📚 스킬 인덱스

카테고리별로 정리된 스킬 47종:

### 🎮 게임 개발 (Unity3D)

| 스킬 | 설명 | 사용 시점 |
|------|------|----------|
| **unity-mcp** 🆕 | Unity 에디터 MCP 브리지 — 37종 도구 | Unity3D 작업 시 항상 사용 |
| **bmad-gds** | 게임 개발 스튜디오: Brainstorm → GDD → Sprint → Dev → Review | 핵심 워크플로우 |
| **bmad-idea** | 아이디어 발상을 위한 창의적 인텔리전스 | 선택적 — 신규 기능 기획 시 |

### 🔧 오케스트레이션

| 스킬 | 설명 | 키워드 |
|------|------|--------|
| **omu** | Plan → Execute → Verify → Cleanup 파이프라인 | `omu` |
| **ralph** | 스펙 우선 자기완성 개발 루프 | `ralph` |
| **plannotator** | 비주얼 플랜 검토 게이트 | `plannotator` |

### 🖥 플랫폼 설정

| 스킬 | 플랫폼 | 키워드 |
|------|--------|--------|
| **omc** | Claude Code | `omc` |
| **ohmg** | Gemini CLI | `ohmg` |
| **omx** (구 oh-my-codex) 🔄 | Codex CLI | `omx` |
| **omu** setup-opencode.sh | OpenCode | — |

### 💻 개발

`code-review` · `code-refactoring` · `backend-testing` · `testing-strategies` · `codebase-search` · `git-workflow` · `git-submodule` · `changelog-maintenance` · `api-design` · `api-documentation` · `security-best-practices` · `performance-optimization` · `pattern-detection` · `environment-setup` · `workflow-automation` · `file-organization`

### 🎨 디자인 & UI

`design-system` _(Unity3D 디자인 가이드 포함)_ · `ui-component-patterns` · `web-accessibility` · `web-design-guidelines` · `responsive-design`

### 📊 인프라 & 데이터

`database-schema-design` · `log-analysis` · `data-analysis` · `llm-monitoring-dashboard` · `task-planning` · `task-estimation`

### 🌟 크리에이티브 & 콘텐츠

`image-generation` · `video-production` · `marketing-skills-collection` · `pptx-presentation-builder` · `remotion-video-production` · `opencontext` · `prompt-repetition` · `vibe-kanban` · `ralphmode`

### 🤖 AI/ML 리서치

| 스킬 | 설명 | 키워드 |
|------|------|--------|
| **autoresearch** 🆕 | Karpathy의 자율 ML 실험 루프 — AI 에이전트가 5분 GPU 실험을 반복 실행하며 git 래칫으로 개선 사항을 자동 커밋 | `autoresearch` |
| **skill-autoresearch** 🆕 | 기존 `SKILL.md` 를 바이너리 eval, mutation log, baseline 비교로 최적화하는 루프 | `skill-autoresearch` |

> 빠른 선택 가이드가 포함된 전체 인덱스 → [SKILLS-INDEX.md](SKILLS-INDEX.md)

---

## 🌐 플랫폼 지원

| 플랫폼 | 설정 스킬 | 플래닝 | 실행 | 검증 |
|--------|----------|--------|------|------|
| **Claude Code** | `omc` | `ralph` + `plannotator` hook | `omc` team mode | `agent-browser` + unity-mcp |
| **Codex CLI** | `omx` | `plan.md` + `plannotator` loop | `bmad` fallback | `agent-browser` + unity-mcp |
| **Gemini CLI** | `ohmg` | `plan.md` + AfterAgent hook | `bmad` or `ohmg` | `agent-browser` + unity-mcp |
| **OpenCode** | `omu` setup-opencode.sh | slash-command workflow | `omx` or `bmad` | `agent-browser` + unity-mcp |

---

## 📁 저장소 구조

```
oh-my-unity3d/
├── README.md                    ← 현재 파일
├── SKILLS-INDEX.md              ← 48종 스킬 디렉토리
├── .omu/                        ← 게임 관리 허브 🆕
│   ├── README.md                ← .omu 사용 가이드
│   ├── long-term-plan.md        ← 컨셉, 규칙, 게임성 (기획)
│   ├── short-term-plan.md       ← 시스템, 밸런스, 배치, 연출 (개발)
│   ├── progress.md              ← 활성 체크리스트 (OMU 자동 업데이트)
│   └── history/                 ← 완료 작업 아카이브 (OMU 자동 아카이브)
├── GETTING-STARTED.md           ← 설치 및 첫 번째 워크플로우
├── WORKFLOWS.md                 ← Unity3D 워크플로우 가이드 5종
├── CLAUDE.md                    ← AI 에이전트 프로젝트 컨텍스트
└── .unity-skills/
    ├── omu/                     ← OMU 오케스트레이션 (핵심)
    │   ├── SKILL.md
    │   ├── SKILL.toon
    │   ├── references/FLOW.md
    │   └── scripts/             ← install, setup-*, check-status, ...
    ├── unity-mcp/               ← Unity 에디터 MCP 브리지 🆕
    │   ├── SKILL.md
    │   ├── SKILL.toon
    │   └── scripts/setup.sh
    ├── bmad-gds/                ← 게임 개발 워크플로우
    ├── bmad-idea/               ← 창의적 인텔리전스
    ├── omc/                     ← Claude Code 설정
    ├── ohmg/                    ← Gemini CLI 설정
    ├── omx/                     ← Codex CLI 설정 (키워드: omx)
    ├── ralph/                   ← 스펙 우선 개발 루프
    ├── plannotator/             ← 플랜 검토 게이트
    ├── autoresearch/            ← 자율 ML 실험 프레임워크 (Karpathy) 🆕
    ├── skill-autoresearch/      ← eval 기반 스킬 최적화 루프 🆕
    └── [35 domain skills]/
```

---

## 📖 문서

| 문서 | 설명 |
|------|------|
| [SKILLS-INDEX.md](SKILLS-INDEX.md) | 카테고리, 키워드, 빠른 선택 가이드가 포함된 47종 스킬 디렉토리 |
| [GETTING-STARTED.md](GETTING-STARTED.md) | 설치, 플랫폼 설정, 첫 번째 워크플로우 안내 |
| [WORKFLOWS.md](WORKFLOWS.md) | 단계별 표와 빠른 시작 예제가 포함된 Unity3D 워크플로우 5종 |
| [CLAUDE.md](CLAUDE.md) | AI 에이전트 프로젝트 컨텍스트 — unity-mcp 도구, OMU 검증 루프 |
| [.unity-skills/omu/SKILL.md](.unity-skills/omu/SKILL.md) | OMU 오케스트레이션 전체 레퍼런스 |
| [.unity-skills/unity-mcp/SKILL.md](.unity-skills/unity-mcp/SKILL.md) | unity-mcp 도구 레퍼런스 (37종 도구, 역할별 매핑) |

---

## 📁 .omu — 게임 관리 허브

`.omu/`는 OMU 워크플로우가 자동으로 읽고 업데이트하는 게임 프로젝트 관리 폴더입니다.

```
.omu/
├── README.md              ← 사용 가이드
├── long-term-plan.md      ← 컨셉, 규칙, 게임성 (기획)
├── short-term-plan.md     ← 시스템, 밸런스, 배치, 연출 (개발)
├── progress.md            ← 활성 체크리스트 — EXECUTE 중 자동 체크
└── history/               ← 완료된 작업 아카이브 (CLEANUP)
    └── YYYYMMDD-<task>.md
```

| 단계 | OMU 페이즈 | .omu 파일 | 액션 |
|------|-----------|-----------|------|
| **기획** | PLAN | `long-term-plan.md` | 컨셉/규칙/게임성 로드 |
| **개발** | EXECUTE | `short-term-plan.md` | 완료 시스템 체크 |
| **QA** | VERIFY | `progress.md` | 테스트 결과 및 버그 추적 |
| **수익성** | CLEANUP | `history/` | 완료 스프린트 아카이브 |

---

## 📋 변경 이력

### `v2.6.0` — 게임 라이프사이클 관리

- **추가** `.omu/` 게임 관리 폴더 — `long-term-plan.md`, `short-term-plan.md`, `progress.md`, `history/`
- **추가** OMU SKILL.md Step 0.1: `.omu` 부트스트랩, 게임 단계 감지(기획/개발/QA/수익성), 계획 자동 로드
- **추가** EXECUTE 단계 `.omu/progress.md` `[x]` 자동 체크 및 신규 태스크 추가
- **추가** CLEANUP 단계 히스토리 아카이브 — 완료 항목이 `history/YYYYMMDD-<task>.md`로 이동하고 활성 문서에서 제거

### `v2.4.0` — 자율 ML 리서치

- **추가** `autoresearch` 스킬 — Karpathy의 자율 ML 실험 프레임워크; AI 에이전트가 5분 GPU 실험을 반복 실행하며 개선 시 git 래칫 커밋, 결과를 `results.tsv`에 기록

### `v2.3.0` — AI MCP 자동 설정

- **추가** `unity-mcp` SKILL.md에 AI 자동 설정 플로우 — 스킬 호출 시 에이전트가 플랫폼 설정 파일에 올바른 MCP 설정(`"url"`)을 자동으로 작성
- **변경** SKILL.md 설치 섹션을 Step 1–4(패키지 → 시작 → 설정 → 확인) 형식으로 재작성
- **수정** 스킬 메타데이터: 잘못된 Python 3.10+/uv 의존성 제거

### `v2.2.0` — MCP 설정 핫픽스

- **수정** unity-mcp MCP 설정: `"command": "python"` (subprocess) → `"url": "http://localhost:8080/mcp"` (HTTP) 변경 — 설치 후 `/mcp`에 도구가 노출되지 않던 문제 해결
- **수정** `setup.sh`: 모든 플랫폼에서 올바른 URL 방식 설정 적용
- **수정** `SKILL.md`: 올바른 플랫폼별 설정 코드 및 트러블슈팅 노트 업데이트

### `v2.1.0` — Unity3D 통합 릴리즈

- **추가** `unity-mcp` 스킬 — Unity 에디터 MCP 브리지 (37종 도구, 역할별 매핑, 플랫폼 자동 설정 스크립트)
- **추가** OMU VERIFY 단계에 Unity3D 검증 루프 (`run_tests → read_console → editor_state`, 최대 3회 재시도)
- **추가** `WORKFLOWS.md`에 Unity3D 워크플로우 템플릿 5종
- **추가** `SKILLS-INDEX.md` — 47종 스킬 디렉토리
- **추가** `GETTING-STARTED.md` — unity-mcp 연동을 포함한 온보딩 가이드
- **추가** `CLAUDE.md` — AI 에이전트 프로젝트 컨텍스트
- **추가** `design-system` 스킬에 Unity3D 디자인 가이드 추가
- **변경** `oh-my-codex` 키워드를 `omx`로 이름 변경
- **변경** 모든 문서에 4번째 지원 플랫폼으로 OpenCode 추가

### `v2.0.0` — OMU 클린 릴리즈

- `agentation` 연동 및 관련 키워드(`annotate`, `agentui`) 제거
- 스킬을 지원 릴리즈 범위로 축소
- 새로운 플랫폼 계약에 맞게 설정 스크립트 정렬
- 실제 패키지 내용 기반으로 릴리즈 문서 재작성

---

## 라이선스

MIT — 자세한 내용은 [LICENSE](LICENSE)를 참조하세요.

---

<div align="center">
Built with <a href="https://github.com/akillness/oh-my-unity3d">OMU</a> · Powered by <a href="https://github.com/CoplayDev/unity-mcp">unity-mcp</a>
</div>
