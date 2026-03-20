# Getting Started with oh-my-unity3d

## 1. 스킬 라이브러리 설치

```bash
# 전체 스킬 설치
npx skills add https://github.com/akillness/oh-my-unity3d --all

# 또는 개별 스킬 설치
npx skills add https://github.com/akillness/oh-my-unity3d --skill omu
npx skills add https://github.com/akillness/oh-my-unity3d --skill unity-mcp
npx skills add https://github.com/akillness/oh-my-unity3d --skill bmad-gds
npx skills add https://github.com/akillness/oh-my-unity3d --skill autoresearch
npx skills add https://github.com/akillness/oh-my-unity3d --skill skill-autoresearch
```

## 2. AI 플랫폼 초기 설정

사용하는 AI 도구에 맞는 스킬을 실행하세요:

| AI 도구 | 스킬 | 명령어 |
|---------|------|--------|
| Claude Code | omc | `/omc` → omc-setup 실행 |
| Gemini CLI | ohmg | `/ohmg` |
| Codex CLI | omx | `/omx` |
| OpenCode | omu | `bash .unity-skills/omu/scripts/setup-opencode.sh` |

## 3. Unity3D 연동 (unity-mcp)

```bash
# unity-mcp MCP 클라이언트 자동 설정
bash .unity-skills/unity-mcp/scripts/setup.sh

# Unity Editor에서:
# Window → MCP → Start
# 연결 확인:
curl http://localhost:8080/health
```

## 4. 첫 번째 워크플로우 실행

### Unity3D 게임 개발 시작 (추천)

```bash
# 1. 게임 기획 → 씬 프로토타이핑
omu "씬 프로토타이핑: 내 첫 번째 게임"

# 2. 스프린트 스토리 구현
omu "스토리 구현: 플레이어 이동 시스템"

# 3. 성능 최적화
omu "성능 최적화: 프레임 드랍 문제"
```

### bmad-gds 게임 개발 워크플로우

```bash
/bmad-gds-brainstorm-game  # 아이디어 발산
/bmad-gds-gdd              # GDD 생성
/bmad-gds-sprint-planning  # 스프린트 계획
/bmad-gds-dev-story        # 스토리 구현
```

## 5. 스킬 선택 가이드

질문에 맞는 스킬을 선택하세요:

- "게임 개발을 시작하고 싶다" → `bmad-gds`
- "Unity Editor를 AI로 제어하고 싶다" → `unity-mcp`
- "전체 워크플로우를 자동화하고 싶다" → `omu`
- "새로운 아이디어가 필요하다" → `bmad-idea`
- "코드를 리뷰받고 싶다" → `code-review`
- "GPU 실험을 자동으로 반복하고 싶다" → `autoresearch`
- "기존 스킬을 eval 기반으로 반복 개선하고 싶다" → `skill-autoresearch`

자세한 스킬 목록은 [SKILLS-INDEX.md](SKILLS-INDEX.md)를 참고하세요.
