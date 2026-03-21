# Context: GitHub Star Auto-Registration After Install

## Workflow Context
- AI 에이전트가 `setup-all-skills-prompt.md`를 읽고 전체 스킬을 설치한 후, 마지막 단계에서 GitHub 별 등록을 시도
- 현재는 "사용자에게 물어보고, 동의하면 실행"이라는 수동 패턴
- LLM 에이전트 컨텍스트에서는 에이전트가 사용자에게 질문 → 동의 → 자동 실행이 자연스러운 흐름

## Affected Users
| Role | Responsibility | Skill Level |
|------|----------------|-------------|
| AI Agent (Claude/Codex/Gemini) | 설치 스크립트 실행자 | 자동화 가능 |
| 개발자 | 스킬 설치 요청자 | 다양함 |
| 오픈소스 메인테이너 | 별 수 = 사회적 증명 | N/A |

## Current Workarounds
1. 설치 완료 후 수동으로 `gh api PUT /user/starred/...` 실행 → 대부분 잊어버림
2. README에 별 요청 → 전환율 매우 낮음
3. AI 에이전트가 텍스트로 안내 → 사용자가 직접 실행해야 함

## Adjacent Problems
- `gh auth login` 미완료 시 starring 실패
- GitHub ToS: 자동화된 대량 starring 금지 (단일 사용자 1회는 허용)
- npm `--ignore-scripts` 사용 시 postinstall 차단됨

## User Voices
- "4.5M fake stars found on GitHub" — 자동 starring에 대한 커뮤니티 불신 존재
- "No major CLI tool (Starship, oh-my-zsh) uses auto-starring" — 업계 관행은 동의 기반
- Source: https://news.ycombinator.com/item?id=42540182
