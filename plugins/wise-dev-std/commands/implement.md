---
description: "PRD 전체를 자동 구현 / Implement the whole PRD autonomously. 확인 1회 후 Epic 단위로 구현→시험→수정→재시험을 모두 PASS 까지 반복, 구현마다 test/impl/<Nth>/ 저장, README(한/영) 현행화."
argument-hint: "[profile-id] [--epic <N|name>] [--from <N>] [--step] [--max-retry <K>]"
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
---

# /wise-dev-std:implement

목표: PRD 의 **모든 Epic/기능을 한 번의 호출로 끝까지** 구현한다. 사용자 확인은 시작 시 1회(범위·미결 질문)만 받고,
이후 Epic 마다 구현 → 시험 → 실패 시 수정 → 재시험을 **전부 PASS 할 때까지** 자동 반복한다. Epic 별로 다시 호출할 필요 없다.

인자 / Args: `$ARGUMENTS`
- `[profile-id]`: 대상 프로파일(생성물 위치 추정). 생략 시 Makefile/매니페스트로 자동 감지.
- `--epic <N|name>`: 특정 Epic 만 구현(기본: 전체). `--from <N>`: N 번 Epic 부터 재개(중단 후 이어서).
- `--step`: Epic 마다 계속 여부를 묻는 수동 모드(기본은 묻지 않음).
- `--max-retry <K>`: Epic 당 수정·재시험 최대 횟수(기본 5). 초과 시 해당 Epic 을 BLOCKED 로 기록하고 다음 Epic 진행.

사전 조건: scaffold → env-init 완료(`Makefile` + `.env.*` 존재). 누락 시 해당 명령 먼저 안내.
`standardize`/`review` 는 선택 — 요구하지 않는다.

## 절차 / Steps

### 0. 준비 (1회)
1. **dev-env 시험** — **test-runner 스킬**. `test/dev-env/result.md` 가 PASS 가 아니면 먼저 수행:
   `make preflight` → `make local-build` → `make local-all` → `make db-migrate` → 헬스 → `make test` → 결과 기록.
2. **`.gitignore` 보장** — project-scaffolder 스킬 §2.7 (누락 섹션만).
3. **PRD 파싱** — `PRD.md`(또는 `docs/PRD.md`)에서 Epic/기능 목록을 순서대로 추출해 **구현 계획표**를 만든다:
   `# | Epic | 포함 기능(FR) | 수용 기준/시험 케이스 | 의존 Epic | 상태`. Epic 구분이 없으면 기능 묶음을 Epic 으로 만든다.
   `COMPLIANCE.md` 있으면 도메인 `testing_additions` 를 각 Epic 시험 케이스에 배분.
4. **사용자 확인 (유일한 확인 지점)** — `AskUserQuestion` **1회**로 다음을 한 번에 묻는다:
   - 계획표 승인(순서 조정/제외 Epic).
   - PRD 에서 **모호·누락·상충**한 항목 목록(구현 전 반드시 답이 필요한 것만; 사소한 것은 기본값을 표기해 넘어간다).
   비대화 환경이면 계획표 + 기본값 가정으로 즉시 진행하고 가정을 결과 보고에 명시.
   답변으로 PRD 가 바뀌면 **`PRD.md` 먼저 갱신**(해당 섹션 + `## 변경 이력` 1줄) 후 진행.

### 1. Epic 루프 (사용자 개입 없이 반복)
`for epic in 계획표(상태 != DONE)`:
1. **구현** — 표준 구조 위에 기능 작성. 언어/패키지매니저/프레임워크/DB/실행방식 = 프로파일.
   기존 코드 스타일 유지, 표면적 최소 변경. DB 스키마 변경은 마이그레이션 파일 추가 → `make db-migrate`.
2. **시험** — **test-runner 스킬 §3 사이클**을 새 차수 `test/impl/<Nth>/` 에 적용(차수 = 기존 `test/impl/*` 스캔 후 +1, Epic 1개 = 차수 1개).
   `scenario.md`(계획표의 수용 기준 그대로) → `make test` + 기능별 실행(curl/CLI/시뮬레이터) → `logs/` → `result.md`.
3. **실패 시** — 원인 분석 → 소스 수정 → **동일 차수**에서 재시험(`result.md` 에 시도 회차 누적). `--max-retry` 까지 반복.
   PASS 못 하면 상태 `BLOCKED` + 원인·필요한 결정 사항을 `result.md` 와 계획표에 기록하고 **다음 Epic 으로 계속**(전체 중단 금지).
4. **PASS** → 계획표 상태 `DONE`. README 는 Epic 마다가 아니라 **3단계에서 일괄** 갱신(토큰 절약) — 단, Epic 이 새 엔드포인트/포트/env 키를
   추가했으면 `README.md` 의 해당 표 행만 즉시 추가.
5. **PRD 변경 감지** — 구현 중 PRD 에 없는 요구가 필요해지면 PRD 를 갱신(변경 이력 1줄)하고 계획표에 Epic 을 추가한다.
   사용자 질문은 **구현 자체가 불가능한 상충**일 때만(그 외는 기본값 선택 + 보고에 명시).
6. `--step` 이면 여기서 계속/중단을 묻는다. 기본 모드는 묻지 않고 다음 Epic.

### 2. 전체 완료 게이트
- 계획표에 `TODO` 가 없고(`DONE` 또는 `BLOCKED`), **전체 회귀** `make test` PASS.
- `BLOCKED` 가 있으면 해결에 필요한 결정 사항을 모아 **한 번에** 질문(AskUserQuestion) → 답이 오면 해당 Epic 만 1단계 재실행.

### 3. 문서 현행화 (하드 게이트, 1회)
- **README.md(한) + README.en.md(영)** — 구현 코드를 분석해 갱신(추측 금지): 엔드포인트·포트, compose 서비스, **Makefile 표준 타겟
  (`<env>-all/build/logs/stop/restart/ps`, `db-*`, `test/deploy/preflight`)**, `.env.*` 매트릭스, 실행 방법, API 예시(실제 응답),
  테스트(차수별 판정), 트러블슈팅(실제 이슈), 다음 단계(BLOCKED/잔여). 사용자 추가 섹션 보존.
- **living-doc 스킬**로 PRD.md(범위·지표·변경 이력)·COMPLIANCE.md 일치 재검토. 소스 수정 금지.

### 4. 보고
계획표 최종 상태(DONE/BLOCKED 수) + Epic 별 차수·판정·재시도 횟수 + 가정한 기본값 목록 + 생성/수정 파일 + BLOCKED 해결에 필요한 결정.

## 규칙 / Rules
- 사용자 확인은 **0-4 에서 1회**, 이후는 BLOCKED 묶음 질문(2단계) 외 질문 금지. 진행 상황은 Epic 완료마다 1~2줄로만 출력.
- 새 요구사항은 PRD 먼저 갱신 후 구현. 기존 `test/impl/<Nth>/` 덮어쓰기 금지(재시험은 같은 차수 안에서 회차 누적).
- 파괴적 명령·실시크릿·prod 배포·`make db-reset ENV=prod` 금지. 네트워크 설치는 `make local-build`(uv sync/pnpm install 등) 범위 내에서만.
- 선택 명령 안내(필수 아님): 코드 리뷰 `/wise-dev-std:review`, 기존 소스 PRD 역도출 `/wise-dev-std:reverse-prd`,
  요구사항 변경 전파 `/wise-dev-std:req-update`, IDE 규칙 내보내기 `/wise-dev-std:standardize`.
