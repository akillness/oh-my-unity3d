# .omu — Game Project Management Hub

> OMU 워크플로우에서 자동으로 읽고 업데이트하는 게임 프로젝트 관리 폴더.
> 작업 시작 전 반드시 이 폴더의 문서를 확인하고, 완료 후 업데이트하세요.

---

## 폴더 구조

```
.omu/
├── README.md              ← 이 파일 — 사용 가이드
├── long-term-plan.md      ← 장기계획: 기획 컨셉, 규칙, 게임성
├── short-term-plan.md     ← 단기계획: 시스템, 밸런스, 배치, 연출
├── progress.md            ← 진행내용: 현재 작업 체크리스트
└── history/
    └── YYYYMMDD-<task>.md ← 이전 작업 히스토리 (자동 아카이브)
```

---

## 게임 개발 단계 (OMU Flow)

```
기획 (Plan) ──► 개발 (Execute) ──► QA (Verify) ──► 수익성 (Monetize)
     │                │                 │                  │
 long-term       short-term         progress           history
 concept.md      systems.md         checks             archive
 rules.md        balance.md
 gameplay.md     production.md
```

| 단계 | OMU 페이즈 | 주요 문서 | 액션 |
|------|-----------|----------|------|
| **기획** | PLAN | `long-term-plan.md` | 컨셉/규칙/게임성 작성 및 검토 |
| **개발** | EXECUTE | `short-term-plan.md` | 시스템/밸런스/배치/연출 구현 |
| **QA** | VERIFY | `progress.md` | 테스트 항목 체크 및 버그 추적 |
| **수익성** | POST-VERIFY | `progress.md` → `history/` | 완료 아카이브, 수익성 지표 기록 |

---

## OMU 워크플로우에서의 사용

### 작업 시작 시 (PLAN 단계)
1. `long-term-plan.md` 읽기 — 현재 컨셉과 방향 확인
2. `short-term-plan.md` 읽기 — 이번 스프린트 항목 확인
3. `progress.md` 읽기 — 미완료 항목 파악
4. 새 계획은 해당 문서에 추가

### 작업 중 (EXECUTE 단계)
- 완료된 항목은 `progress.md`에서 `- [x]`로 체크
- 새로 발견된 작업은 즉시 추가

### 작업 완료 후 (CLEANUP 단계)
- 완료된 항목을 `history/YYYYMMDD-<task>.md`로 아카이브
- `progress.md`에서 완료 항목 제거
- `short-term-plan.md`에서 완료된 스프린트 항목 제거

---

## 파일 생성/제거 규칙

| 상황 | 액션 |
|------|------|
| 새 게임 프로젝트 시작 | `long-term-plan.md` 작성 |
| 새 스프린트 시작 | `short-term-plan.md` 업데이트 |
| 스프린트 완료 | 완료 항목 → `history/` 아카이브 후 제거 |
| 장기계획 변경 | `long-term-plan.md` 수정, 변경 사유 주석 추가 |
| 프로젝트 완료 | 전체 `progress.md` → `history/FINAL.md` 아카이브 |
