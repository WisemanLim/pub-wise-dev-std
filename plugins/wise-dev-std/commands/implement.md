---
description: "PRD 기반 기능 구현 + 시험 사이클 / Implement features from PRD and run the test cycle. 구현마다 test/impl/<Nth>/ 저장, README(한/영) 현행화."
argument-hint: "[profile-id] [feature-keyword]"
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
---

# /wise-dev-std:implement

목표: 표준 환경 구성 완료 후, PRD 에 맞춰 기능을 구현하고 시험 사이클을 적용한다.

인자 / Args: `$ARGUMENTS`
- `[profile-id]`: 대상 프로파일(생성물 위치 추정에 사용).
- `[feature-keyword]`: 이번에 구현할 PRD 항목 힌트.

사전 조건: recommend → scaffold → env-init → standardize 완료. 누락 시 해당 명령 먼저 안내.

## 절차 / Steps

1. **dev-env 시험 (최초 1회)** — **test-runner 스킬 사용**.
   `test/dev-env/` 가 없거나 result 가 PASS 아니면 dev-env 시험을 먼저 수행하고
   `test/dev-env/{scenario,result}.md` 작성.
2. **`.gitignore` 보장** — **project-scaffolder 스킬 §2.7** 규칙(조립 순서·모바일 매핑·멱등 센티넬)으로
   누락 섹션만 보강. 추가한 섹션 목록 보고.
3. **PRD 분석** — `PRD.md`(또는 `docs/PRD.md`)에서 이번 `feature-keyword` 범위 추출.
4. **추가 요구사항 감지 — PRD 먼저, 코드는 그 다음.**
   사용자 입력에 PRD 에 없는 기능·비기능·범위 변경이 포함되면:
   a. 현재 이터레이션을 자연스러운 중단점까지 완료 후 정지.
   b. **`PRD.md` 즉시 갱신**(해당 섹션 + `## 변경 이력` 한 줄). PRD 갱신 없이 구현 금지.
   c. **living-doc 스킬 §1.1→§1.2→§2** 로 나머지 문서(README·COMPLIANCE 등) 전파.
   d. 갱신 후 구현 재개. 현 이터레이션 범위를 벗어나면 PRD 에만 기록하고 다음 이터레이션으로
      (현 `test/impl/<Nth>/` 범위 확대 금지). **이 단계에서 소스코드 수정 금지.**
   > 명시적 호출: `/wise-dev-std:req-update`.
5. **구현** — 표준 구조 위에 기능 작성. 언어/패키지매니저/프레임워크/DB/실행방식 = 선택 프로파일.
   기존 코드 스타일·구조 유지, 표면적 최소 변경.
6. **시험** — **test-runner 스킬 표준**(§1 test/ 단일 트리, §3 사이클: 시나리오→실행→수정·재시험→결과)을
   새 차수 `test/impl/<Nth>/` 에 적용. 차수는 기존 `test/impl/*` 스캔 후 자동 증가.
   `COMPLIANCE.md` 있으면 도메인 `testing_additions` 케이스 포함
   (예: 금융=멱등결제, 의료=비식별 검증, 커머스=오버셀 방지, 게임=확률공개 audit).
7. **README 갱신 (한/영, 하드 게이트)** — 구현된 **코드를 분석**해 `README.md`(한글) +
   `README.en.md`(영어, 동일 구성, 상단 상호 링크)를 갱신. **매 구현·수정 후 예외 없이 실행** —
   두 파일 현행화 없이 step 9 보고로 넘어가지 않는다.
   - 코드에서 추출(추측 금지): 엔드포인트·포트(라우터 + compose `ports`), compose 서비스·프로파일별
     기동 범위, Makefile 타겟·실제 명령, 환경 매트릭스(`.env.*`)와 연결 URL(직접실행 vs 컨테이너).
   - 필수 섹션: ①개요+profile/domain+문서 링크 ②아키텍처/디렉터리 ③사전 요구사항(버전)
     ④환경 설정(.env 매트릭스, 실시크릿 금지) ⑤실행 방법(서버: compose vs 호스트 직접 /
     모바일: 시뮬레이터·플레이버·Fastlane) ⑥접속/포트 표 + API 문서 경로 ⑦API 예시(curl, 실제 응답 기준)
     ⑧테스트(make test + 차수별) ⑨트러블슈팅(실제 만난 이슈 우선) ⑩다음 단계(PRD 잔여).
   - 멱등: 사용자 추가 섹션 보존, 표준 섹션만 갱신.
8. **문서 동기화 (항상)** — **living-doc 스킬**로 PRD.md(범위·지표·기술메모 일치 확인 + 변경 이력)와
   README 양쪽의 현행화를 재검토. 새 요구사항 감지 여부와 무관하게 매 사이클 종료 시 실행.
   변경 필요 항목만 갱신(멱등). 소스코드 수정 금지.
9. **보고** — 구현 요약 + 시험 판정(PASS/FAIL) + 생성/수정 파일(PRD·README 포함) + 결과 경로.

## 규칙 / Rules
- 새 요구사항은 **PRD.md 먼저 갱신**(step 4) 후 구현 재개. PRD 갱신 없이 코드 작성 금지.
- 시험·README·문서화 세부는 각 스킬(test-runner·living-doc·project-scaffolder)을 단일 기준으로 따른다.
- 기존 차수 디렉터리 덮어쓰기 금지.
- 파괴적 명령·실시크릿·prod 배포 금지. 네트워크 설치는 사용자 승인 후.
