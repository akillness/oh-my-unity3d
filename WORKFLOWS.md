# oh-my-unity3d Unity3D 워크플로우

OMU 오케스트레이션 + bmad-gds + unity-mcp 통합 워크플로우 가이드

## 워크플로우 개요

모든 워크플로우는 `omu` 명령으로 시작하며, OMU가 PLAN → EXECUTE → VERIFY → CLEANUP 단계를 오케스트레이션합니다.
VERIFY 단계에서는 unity-mcp 검증 루프(run_tests → read_console → editor_state)가 자동 실행됩니다.

---

## Workflow 1: 게임 기획 → 씬 프로토타이핑 (PM + 디자이너)

**적용 상황**: 새 레벨/씬 프로토타입, 게임 컨셉 시각화, GDD 기반 씬 구성

```
omu "씬 프로토타이핑: <게임명 또는 씬 설명>"
```

### 단계별 실행

| 단계 | 스킬/도구 | 설명 |
|------|---------|------|
| PLAN | `bmad-gds-brainstorm-game` | 게임 아이디어 발산 |
| PLAN (옵셔널) | `bmad-idea` | 추가 아이디어 확장 |
| PLAN | `bmad-gds-game-brief` | 컨셉 확정 |
| PLAN | `bmad-gds-gdd` | GDD 생성 |
| EXECUTE | `unity-mcp: manage_scene` | 씬 생성 |
| EXECUTE | `unity-mcp: manage_gameobject` | 플레이스홀더 오브젝트 배치 |
| EXECUTE | `unity-mcp: manage_probuilder` | 레벨 레이아웃 그레이박싱 |
| VERIFY ① | `unity-mcp: run_tests` | 씬 유효성 검증 |
| VERIFY ② | `unity-mcp: read_console` | 씬 로드 에러 확인 |
| VERIFY ③ | `unity-mcp: editor_state` | 씬 상태 검증 |
| VERIFY Fix | Fix 루프 (최대 3회) | 실패 시 자동 재시도 |
| CLEANUP | `worktree-cleanup.sh` | 워크트리 정리 |

### 빠른 실행 예제
```bash
omu "씬 프로토타이핑: 2D 플랫포머 첫 번째 레벨"
# → GDD 작성 → 씬 자동 생성 → 오브젝트 배치 → 검증 루프
```

---

## Workflow 2: 스프린트 스토리 → C# 구현 (PM + 개발자)

**적용 상황**: 기능 스토리 구현, C# 스크립트 생성, 컴포넌트 개발

```
omu "스토리 구현: <스토리명 또는 기능 설명>"
```

### 단계별 실행

| 단계 | 스킬/도구 | 설명 |
|------|---------|------|
| PLAN | `bmad-gds-sprint-planning` | 스프린트 계획 |
| PLAN | `bmad-gds-create-story` | 구현 스토리 생성 |
| EXECUTE | `bmad-gds-dev-story` | 스토리 실행 |
| EXECUTE | `unity-mcp: create_script` | C# 스크립트 생성 |
| EXECUTE | `unity-mcp: validate_script` | Roslyn 컴파일 사전 검증 |
| EXECUTE | `unity-mcp: script_apply_edits` | 코드 적용 |
| VERIFY ① | `unity-mcp: run_tests` | Unit/Integration 테스트 |
| VERIFY ② | `unity-mcp: read_console` | 런타임 에러·Exception 확인 |
| VERIFY Fix | `unity-mcp: validate_script` → `script_apply_edits` | Fix 루프 |
| POST-VERIFY | `bmad-gds-code-review` | 코드 리뷰 (검증 통과 후) |
| POST-VERIFY | `changelog-maintenance` | 변경 사항 기록 |
| CLEANUP | `worktree-cleanup.sh` | 워크트리 정리 |

### 빠른 실행 예제
```bash
omu "스토리 구현: 플레이어 이동 및 점프 시스템"
# → 스토리 생성 → C# 스크립트 → Roslyn 검증 → 테스트 → 코드 리뷰
```

---

## Workflow 3: 에셋 파이프라인 자동화 (디자이너 + 개발자)

**적용 상황**: 에셋 배치 임포트, 머티리얼 일괄 설정, 텍스처 최적화

```
omu "에셋 파이프라인: <에셋 종류 또는 작업>"
```

### 단계별 실행

| 단계 | 스킬/도구 | 설명 |
|------|---------|------|
| PLAN | `file-organization` | 에셋 폴더 구조 정의 |
| EXECUTE | `unity-mcp: manage_asset` | 에셋 임포트 |
| EXECUTE | `unity-mcp: manage_texture` | 텍스처 설정 최적화 |
| EXECUTE | `unity-mcp: manage_material` | 머티리얼 구성 |
| EXECUTE | `unity-mcp: manage_shader` | 셰이더 적용 |
| EXECUTE | `unity-mcp: manage_prefabs` | 프리팹 생성 |
| EXECUTE | `unity-mcp: batch_execute` | 배치 처리 (10~100x 속도) |
| VERIFY ① | `unity-mcp: read_console` | 임포트 에러 확인 |
| VERIFY ② | `unity-mcp: run_tests` | 에셋 로드 테스트 |
| VERIFY ③ | `performance-optimization` | 메모리 사용량 검증 |
| VERIFY Fix | Fix 루프 | 실패 시 재시도 |
| CLEANUP | `worktree-cleanup.sh` | 워크트리 정리 |

### 빠른 실행 예제
```bash
omu "에셋 파이프라인: 캐릭터 텍스처 배치 임포트 및 머티리얼 설정"
# → 폴더 구조 → 배치 임포트 → 텍스처/머티리얼 설정 → 검증
```

---

## Workflow 4: Unity UI/비주얼 개발 (디자이너)

**적용 상황**: HUD 구성, 인벤토리 UI, 메인 메뉴, 애니메이션 UI

```
design-system → ui-component-patterns → unity-mcp UI 도구
```

### 단계별 실행

| 단계 | 스킬/도구 | 설명 |
|------|---------|------|
| 시작 | `design-system` | 디자인 토큰 정의 (Unity3D Design Guide 탐색 가능) |
| 탐색 | `codebase-search '디자인 토큰'` | 프로젝트 내 기존 디자인 파일 탐색 |
| 설계 | `ui-component-patterns` | UI 컴포넌트 설계 |
| EXECUTE | `unity-mcp: manage_ui` | UI 계층 구조 생성 |
| EXECUTE | `unity-mcp: manage_animation` | UI 애니메이션 설정 |
| EXECUTE | `unity-mcp: manage_vfx` | 시각 이펙트 추가 |
| VERIFY | `bmad-gds-test-design` | UI 테스트 설계 |
| VERIFY | `unity-mcp: run_tests` | UI 테스트 실행 |
| VERIFY | `unity-mcp: read_console` | UI 에러 확인 |

> **design-system Unity3D Design Guide**: `design-system` 스킬에서 게임 UI 색상 팔레트, 타이포그래피, 아이콘/스프라이트 명명 규칙을 탐색하세요.

### 빠른 실행 예제
```bash
/design-system  # Unity3D Design Guide 확인
/ui-component-patterns  # UI 컴포넌트 설계
# 그 다음 unity-mcp: manage_ui로 Unity Editor에 직접 구현
```

---

## Workflow 5: 성능 최적화 & 디버깅 (개발자 + QA)

**적용 상황**: 프레임 드랍, 드로우콜 최적화, GC 할당 감소, 씬 로딩 속도

```
omu "성능 최적화: <문제 증상>"
```

### 단계별 실행

| 단계 | 스킬/도구 | 설명 |
|------|---------|------|
| PLAN | `log-analysis` + `unity-mcp: read_console` | 에러·경고 수집 |
| PLAN | `unity-mcp: find_gameobjects` | 문제 오브젝트 탐색 |
| PLAN | `codebase-search` | 관련 스크립트 검색 |
| EXECUTE | `performance-optimization` | 병목 분석 |
| EXECUTE | `unity-mcp: manage_components` | 컴포넌트 최적화 |
| EXECUTE | `unity-mcp: batch_execute` | 배치 수정 |
| VERIFY ① | `unity-mcp: run_tests` | 회귀 테스트 |
| VERIFY ② | `unity-mcp: read_console` | 새로운 에러 없음 확인 |
| VERIFY ③ | `bmad-gds-performance-test` | 성능 테스트 전략 적용 |
| VERIFY Fix | Fix 루프 (최대 3회) | 프레임 드랍·에러 잔류 시 재진입 |
| CLEANUP | `worktree-cleanup.sh` | 워크트리 정리 |

### 빠른 실행 예제
```bash
omu "성능 최적화: 모바일에서 프레임 드랍 30fps 이하"
# → 콘솔 분석 → 병목 탐색 → 최적화 → 회귀 테스트
```

---

## OMU Unity3D 검증 루프 상세

모든 워크플로우의 VERIFY 단계에서 공통으로 실행:

```
① unity-mcp: run_tests        → pass/fail 집계
② unity-mcp: read_console     → Error/Exception 패턴 탐지
③ unity-mcp: editor_state     → 씬 로드 상태 확인
④ unity-mcp: find_gameobjects → 필수 오브젝트 존재 확인

결과 분기:
  모두 통과 → CLEANUP 진행
  실패 → Fix 루프:
    code-refactoring 또는 unity-mcp: validate_script
    → 코드 수정 → ① 재검증
    → 최대 3회 반복
    → 3회 초과 시 사용자 확인 요청

omu-state.json 업데이트:
{ "unity_verify": { "tests_passed": true/false, "console_errors": 0, "retry_count": 0 } }
```

---

## 워크플로우 선택 가이드

| 상황 | 워크플로우 |
|------|-----------|
| 새 게임/씬 프로토타입 제작 | Workflow 1 |
| 기능 스토리 C# 구현 | Workflow 2 |
| 에셋 배치 임포트·설정 | Workflow 3 |
| UI/HUD/애니메이션 개발 | Workflow 4 |
| 성능 문제·디버깅 | Workflow 5 |

---

## 관련 문서

- [SKILLS-INDEX.md](SKILLS-INDEX.md) — 전체 스킬 목록
- [GETTING-STARTED.md](GETTING-STARTED.md) — 설치 및 시작 가이드
- [CLAUDE.md](CLAUDE.md) — AI 에이전트 컨텍스트
- [unity-mcp GitHub](https://github.com/CoplayDev/unity-mcp) — 37개 도구 레퍼런스
