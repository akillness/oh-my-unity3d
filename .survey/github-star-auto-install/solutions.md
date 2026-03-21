# Solution Landscape: GitHub Star Auto-Registration

## Solution List
| Name | Approach | Strengths | Weaknesses | Notes |
|------|----------|-----------|------------|-------|
| gh CLI (consent-first) | 설치 후 에이전트가 질문 → 동의 시 `gh api PUT` | 간단, 크로스플랫폼, 동의 기반 | `gh` 설치 + 인증 필요 | **채택** |
| curl + PAT | `GITHUB_TOKEN` 환경변수로 API 호출 | gh 불필요 | 토큰 노출 위험 | 보안 문제 |
| npm postinstall | `package.json`의 postinstall 스크립트 | 자동 실행 | `--ignore-scripts`로 차단됨, 동의 없음 | ToS 위반 위험 |
| OAuth App | OAuth 동의 페이지 리다이렉트 | 명시적 권한 부여 | 과도한 복잡성 | 1회 starring에 부적합 |
| 환경변수 플래그 | `STAR_REPO=true`일 때만 실행 | 완전 opt-in | 사용자가 플래그를 알아야 함 | 채택율 낮음 |

## Categories
- **자동화**: npm postinstall, 환경변수 플래그
- **동의 기반**: gh CLI consent-first, OAuth
- **수동**: README 안내, 문서 기반

## What People Actually Use
- 대부분의 주요 CLI 도구: README/문서에서 별 요청 (자동화 없음)
- npm-star/starring 패키지: 의존성 별 등록 (명시적 opt-in)
- AI 에이전트: 텍스트 프롬프트 후 사용자 동의 → 실행

## Frequency Ranking
1. README/문서 기반 요청 (가장 보편적)
2. 설치 완료 메시지에 별 요청 텍스트 (보편적)
3. gh CLI 기반 동의 후 실행 (신규 패턴)
4. npm postinstall 자동 실행 (거의 없음 — ToS 위반)

## Key Gaps
- LLM 에이전트가 설치 완료 후 **자동으로 동의를 구하고 실행하는** 표준 패턴이 없음
- `gh auth status` 사전 체크 → 인증 상태에 따른 분기 로직 부재

## Contradictions
- "자동 별 등록" 요청 vs GitHub ToS "자동화된 대량 활동 금지"
- 해결: 단일 사용자, 1회, 명시적 동의 = ToS 준수

## Key Insight
LLM 에이전트 컨텍스트에서 최적 패턴: `gh auth status` 체크 → 인증됨이면 에이전트가 사용자에게 질문 → 동의 시 자동 실행 → 1회 가드 (`.omc/state/`). 이것은 "자동"이면서도 "동의 기반"인 하이브리드 모델.
