# oh-my-unity3d — AI 에이전트 컨텍스트

## 프로젝트 개요

44개 스킬의 Unity3D 게임 개발 오케스트레이션 라이브러리.
OMU 워크플로우(Plan → Execute → Verify → Cleanup)를 중심으로 bmad-gds, unity-mcp와 통합.

## 핵심 스킬 계층

```
omu (오케스트레이터)
  ├── bmad-gds (게임 개발 워크플로우 — 기본)
  │     └── bmad-idea (옵셔널 아이디어 확장)
  ├── unity-mcp (Unity Editor MCP 연동 — 37개 도구)
  └── 플랫폼 설정: omc | ohmg | omx | omu(opencode)
```

## unity-mcp MCP 서버

- **주소**: localhost:8080
- **총 도구**: 37개 (씬, 스크립트, 에셋, UI, 테스트, 디버깅)
- **총 리소스**: 32개 (project_info, editor_state, cameras 등)
- **소스**: https://github.com/CoplayDev/unity-mcp

### 주요 도구 카테고리

| 카테고리 | 도구 |
|---------|------|
| 씬·오브젝트 | manage_scene, manage_gameobject, find_gameobjects |
| 스크립트 | create_script, validate_script, script_apply_edits |
| 에셋·비주얼 | manage_asset, manage_material, manage_texture, manage_vfx |
| 테스트·디버깅 | run_tests, read_console, get_test_job |
| 편집기 | execute_menu_item, batch_execute, manage_editor |

## OMU Unity3D 검증 루프

OMU VERIFY 단계에서 unity-mcp 연결 시 자동 실행:

1. `run_tests` → Unity Test Runner 실행
2. `read_console` → Error/Exception 탐지
3. `editor_state` → 씬 로드 상태 확인
4. 실패 시 Fix 루프 (최대 3회)
5. `omu-state.json` → `unity_verify: { tests_passed, console_errors, retry_count }`

## 플랫폼 지원

| 플랫폼 | 설정 스킬 | 설정 파일 |
|--------|---------|---------|
| Claude Code | omc | ~/.claude/settings.json |
| Gemini CLI | ohmg | ~/.gemini/settings.json |
| Codex CLI | omx | ~/.codex/config.toml |
| OpenCode | omu (setup-opencode.sh) | opencode.json |

## 스킬 디렉토리 구조

```
.unity-skills/
├── omu/          # 오케스트레이션 핵심
├── unity-mcp/    # Unity Editor MCP 연동 (신규)
├── bmad-gds/     # 게임 개발 워크플로우
├── bmad-idea/    # 창의 인텔리전스 (옵셔널)
├── omc/          # Claude Code 설정
├── ohmg/         # Gemini CLI 설정
├── oh-my-codex/  # Codex CLI 설정 (keyword: omx)
├── ralph/        # 명세 기반 개발
├── plannotator/  # 계획 리뷰 게이트
└── [38개 도메인 스킬]
```

## OMC 상태 관리

- `.omc/state/omu-state.json` — OMU 실행 상태
- `.omc/plans/` — 승인된 계획
- `.omc/logs/` — 실행 로그
