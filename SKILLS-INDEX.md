# oh-my-unity3d Skills Index

47개 스킬 라이브러리 — OMU 오케스트레이션 생태계

## 플랫폼 초기 설정

| 스킬 | 플랫폼 | 역할 | 키워드 |
|------|--------|------|--------|
| omc | Claude Code | 팀·에이전트·훅 구성 | omc |
| ohmg | Gemini CLI | 훅·GEMINI.md 구성 | ohmg |
| omx | Codex CLI | developer_instructions·notify 훅 | omx |
| omu | OpenCode | setup-opencode.sh 경유 | omu |

## 오케스트레이션 (핵심)

| 스킬 | 설명 | 키워드 | Unity3D |
|------|------|--------|---------|
| omu | Plan→Execute→Verify→Cleanup 통합 워크플로우 | omu | ✅ 검증 루프 |
| ralph | 명세 기반 자기완결 개발 루프 | ralph | - |
| plannotator | 계획 시각적 리뷰·승인 게이트 | plannotator | - |
| unity-mcp | Unity Editor MCP 연동 (37개 도구) | unity-mcp | ✅ 핵심 |

## 게임 개발 (Unity3D 중심)

| 스킬 | 설명 | 사용 조건 |
|------|------|----------|
| bmad-gds | 게임 개발 스튜디오 (기획→GDD→아키텍처→스프린트→구현) | 기본 사용 |
| bmad-idea | 창의 인텔리전스 (아이디어 발산·확장) | 옵셔널 |

## 개발 실천

| 스킬 | 설명 | 관련 스킬 |
|------|------|----------|
| code-refactoring | 코드 단순화·리팩터링 | code-review, backend-testing |
| code-review | 코드 품질·보안 리뷰 | testing-strategies |
| backend-testing | 백엔드 테스트 (Unit/Integration/API) | api-design |
| testing-strategies | 테스트 전략 설계 | backend-testing |
| codebase-search | 코드베이스 탐색 | - |
| git-workflow | Git 워크플로우 (커밋·브랜치·PR) | changelog-maintenance |
| git-submodule | Git 서브모듈 관리 | git-workflow |
| changelog-maintenance | 버전 변경 사항 기록 | git-workflow |
| api-design | REST/GraphQL API 설계 | api-documentation |
| api-documentation | API 문서화 | api-design |
| security-best-practices | 보안 취약점 방지 | code-review |
| performance-optimization | 성능 최적화 | database-schema-design |
| pattern-detection | 코드 패턴·이상 탐지 | codebase-search |
| environment-setup | 개발 환경 구성 | workflow-automation |
| workflow-automation | 반복 작업 자동화 | - |
| file-organization | 프로젝트 파일 구조 | - |

## UI/디자인

| 스킬 | 설명 |
|------|------|
| design-system | 디자인 토큰·레이아웃 (Unity3D Design Guide 포함) |
| ui-component-patterns | 재사용 UI 컴포넌트 패턴 |
| web-accessibility | WCAG 2.1 접근성 |
| web-design-guidelines | 웹 인터페이스 가이드라인 |
| responsive-design | 반응형 웹 디자인 |

## 인프라·데이터

| 스킬 | 설명 |
|------|------|
| database-schema-design | DB 스키마 설계 (SQL/NoSQL) |
| log-analysis | 로그 분석 (Unity Console 포함) |
| data-analysis | 데이터셋 인사이트 추출 |
| llm-monitoring-dashboard | LLM 토큰·비용·지연 모니터링 |
| task-planning | 개발 작업 분류·스토리 |
| task-estimation | 작업 규모 추정 |

## 창의·콘텐츠

| 스킬 | 설명 |
|------|------|
| image-generation | AI 이미지 생성 |
| video-production | Remotion 기반 동영상 제작 |
| marketing-skills-collection | 마케팅 자동화 (CRO·SEO·성장) |
| pptx-presentation-builder | PPTX 프레젠테이션 생성 |
| remotion-video-production | Remotion 비디오 제작 |

## 기타

| 스킬 | 설명 |
|------|------|
| autoresearch | Karpathy 자율 ML 실험 루프 — 5분 GPU 실험 반복, 개선만 git ratchet |
| opencontext | AI 에이전트 영구 메모리·컨텍스트 |
| prompt-repetition | 프롬프트 반복 기법 (정확도 향상) |
| vibe-kanban | AI 에이전트 Kanban 보드 |
| ralphmode | Claude Code/Codex/Gemini 자동화 설정 |
| omx (legacy: oh-my-codex) | Codex CLI 멀티 에이전트 설정 |

---

## 빠른 스킬 선택 가이드

| 상황 | 추천 스킬 |
|------|----------|
| Unity3D 게임 개발 시작 | `bmad-gds` + `unity-mcp` |
| AI 워크플로우 오케스트레이션 | `omu` |
| 새 아이디어 발산 | `bmad-idea` |
| Claude Code 초기 설정 | `omc` |
| Gemini CLI 초기 설정 | `ohmg` |
| Codex CLI 초기 설정 | `omx` |
| 코드 품질 리뷰 | `code-review` |
| 성능 문제 해결 | `performance-optimization` + `log-analysis` |
| GPU 실험 자동화 | `autoresearch` |
| 디자인 시스템 구축 | `design-system` |
