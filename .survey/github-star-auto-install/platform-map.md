# Platform Map: GitHub Star Auto-Registration

## Settings
| Concern | Claude Code | Codex CLI | Gemini CLI | OpenCode | Common Layer |
|---------|-------------|-----------|------------|----------|--------------|
| gh CLI 경로 | PATH 자동 감지 | PATH 자동 감지 | PATH 자동 감지 | PATH 자동 감지 | `command -v gh` |
| 인증 상태 체크 | `gh auth status` | `gh auth status` | `gh auth status` | `gh auth status` | 동일 |
| 대상 레포 | 환경변수/하드코딩 | 환경변수/하드코딩 | 환경변수/하드코딩 | 환경변수/하드코딩 | `REPO_URL` |

## Rules
| Concern | Claude / OMC | Codex / OMX | Gemini / OHMG | Common Layer |
|---------|-------------|-------------|---------------|--------------|
| 동의 방식 | 에이전트가 텍스트로 질문 → 사용자 응답 | 에이전트가 텍스트로 질문 → 사용자 응답 | 에이전트가 텍스트로 질문 → 사용자 응답 | "ask then execute" |
| 1회 가드 | `.omc/state/star-prompted` | `.omc/state/star-prompted` | `.omc/state/star-prompted` | 파일 존재 여부 체크 |
| 실패 시 | 무시 (silent fail) | 무시 (silent fail) | 무시 (silent fail) | `2>/dev/null \|\| true` |

## Hooks
| Lifecycle | Claude Code | Codex CLI | Gemini CLI | Common Layer |
|-----------|-------------|-----------|------------|--------------|
| 설치 완료 후 | setup-claude.sh 마지막 | setup-codex.sh 마지막 | setup-gemini.sh 마지막 | setup script 종료 직전 |
| 스킬 첫 실행 | PostToolUse hook 가능 | notify hook 가능 | AfterAgent hook 가능 | `.omc/state/` 가드 |
| Star 실행 위치 | Step 4 (Verification) 이후 | Step 4 이후 | Step 4 이후 | 검증 완료 후 |

## Platform Gaps
- OpenCode: post-install hook 메커니즘 없음 → 에이전트 텍스트 프롬프트에만 의존
- npm `--ignore-scripts`: postinstall 기반 자동화 차단 → 에이전트 레벨에서 처리 필요
- `gh auth login`이 인터랙티브: 에이전트가 직접 실행 불가 → 사전 인증 필요
