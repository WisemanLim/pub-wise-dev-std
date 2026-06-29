---
description: >
  PRD 기반 기능 구현 + 시험 사이클 / Implement features from PRD and run the test cycle.
  recommend→scaffold→env-init→standardize 완료 후 실행. 표준 환경(dev-env) 검증 후 PRD 구현,
  구현마다 test/impl/<Nth>/ 에 시나리오·결과 저장. 구현 후 코드 분석 기반 상세 README(한글 README.md +
  영어 README.en.md) 를 현행화한다.
argument-hint: "[profile-id] [feature-keyword]"
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
---

# /wise-dev-std:implement

목표 / Goal: 표준 환경 구성 완료 후, PRD 에 맞춰 기능을 구현하고 동일한 시험 사이클을 적용한다.
Implement features per PRD on the standardized project, applying the test cycle.

인자 / Args: `$ARGUMENTS`
- `[profile-id]`: 대상 프로파일(생성물 위치 추정에 사용) / target profile.
- `[feature-keyword]`: 이번에 구현할 PRD 항목 힌트 / which PRD item to implement.

## 사전 조건 / Preconditions
recommend → scaffold → env-init → standardize 가 끝나 있어야 한다.
누락 시 해당 명령을 먼저 실행하도록 안내. If missing, point to the prior command.

## 절차 / Steps

1. **dev-env 시험 (최초 1회) / env verification (once)** — **test-runner 스킬 사용**.
   - `test/dev-env/` 가 없거나 result 가 PASS 아니면, dev-env 시험을 먼저 수행하고
     `test/dev-env/{scenario,result}.md` 작성.
   - If `test/dev-env/` missing or not PASS → run env verification first.
2. **`.gitignore` 보장 / Ensure `.gitignore`** — 언어별 + 플랫폼별 예외를 미리 적용.
   Apply per-language and per-platform ignores up front.
   - 언어 결정 / languages: 프로파일 `languages.primary` + `languages.also`
     (예 / e.g. node-next-nest → node; python-fastapi → python; bio-rag-research → python+node+go+rust).
     - **모바일 매핑 / mobile**: ios-swiftui(swift)→`swift`; android-compose(kotlin)→`android`;
       flutter-app(dart)→`flutter`; react-native-app(node)→`react-native` + `node`.
   - 조립 / assemble (이 순서 / in this order):
     `templates/gitignore/_common.gitignore` + `_platform.gitignore`(macOS·Windows·Linux 모두 / all three)
     + 언어별 `templates/gitignore/<lang>.gitignore`
     (`node|python|go|rust|c-cpp|swift|android|flutter|react-native`).
   - 멱등 / idempotent: 각 프래그먼트는 헤더 라인(`# ===== ... =====`)을 센티넬로 사용.
     `.gitignore` 없으면 생성, 있으면 **누락된 섹션만 추가**(기존 사용자 항목 보존, 삭제·재정렬 금지).
     If absent → create; if present → append only missing sections, never remove/reorder user lines.
   - 결과 보고 / report: 추가한 섹션 목록.

4. **PRD 분석 / Read PRD** — `PRD.md`(또는 `docs/PRD.md`)에서 이번 `feature-keyword` 범위 추출.
4.5. **추가 요구사항 감지 / Detect new requirements** — **PRD 먼저, 코드는 그 다음.**
   사용자 입력(인자·대화)에 PRD 에 없는 기능·비기능·범위 변경이 포함되면
   아래 순서를 **반드시** 지킨다:
   a. 현재 구현 이터레이션을 자연스러운 중단점까지 완료한 후 정지.
   b. **`PRD.md` 를 즉시 갱신** — 새 요구사항을 PRD 의 해당 섹션(범위·성공지표·기술메모 등)에 추가하고
      `## 변경 이력` 에 한 줄 기록. PRD 갱신 없이 구현으로 넘어가지 않는다.
   c. **living-doc 스킬**로 나머지 문서 전파 — §1.1 유형 분류 → §1.2 영향 문서 결정 → §2 절차로
      README.md·README.en.md·COMPLIANCE.md 등 소스 제외 문서 갱신.
   d. 갱신 완료 후 구현 재개. 새 요구사항이 현 이터레이션 범위를 벗어나면
      PRD 에만 기록하고 다음 이터레이션 대상으로 안내(현 `test/impl/<Nth>/` 범위 확대 금지).
   **소스코드는 이 단계에서 절대 수정하지 않는다.**
   > `/wise-dev-std:req-update` 로 명시적으로 호출도 가능.
5. **구현 / Implement** — 표준 구조 위에 기능 작성. 표준 준수:
   - 언어/패키지매니저/프레임워크/DB/실행방식 = 선택 프로파일.
   - 기존 코드 스타일·구조 유지, 표면적 최소 변경 / surgical changes.
6. **시험 / Test (test-runner 사이클)** — 새 차수 `test/impl/<Nth>/`:
   - 시나리오 작성 → 시험 진행 → 오류 시 수정·재시험 → 시험결과 작성.
   - write scenario → run → fix & retest on failure → write result.
   - 차수는 기존 `test/impl/*` 스캔 후 자동 증가 / auto-increment iteration.
   - `COMPLIANCE.md`(업종 적용 시)가 있으면 도메인 `testing_additions` 케이스를 시나리오에 포함
     (예: 금융=멱등결제/정산대사, 의료=비식별 검증, 커머스=오버셀 방지, 게임=확률공개 audit).
     If COMPLIANCE.md exists, include the domain's compliance test cases.
7. **README 작성/갱신 (한/영 분리) / Write README (KO + EN)** — 구현된 **코드를 분석**해 상세 README 작성.
   매 구현 후 README 를 현행화한다. Analyze the implemented code and write/refresh detailed READMEs after each iteration.
   - 출력 / files:
     - `README.md` — **한글**, 상세.
     - `README.en.md` — **영어**, 동일 구성. 두 파일 상단에 상호 링크(한국어 ↔ English).
   - 코드 분석으로 채울 내용 / derive from code (추측 금지 / no guessing):
     - 엔드포인트·포트 — 서비스 라우터(`@app.get/post`, Nest 컨트롤러, 라우트)와 compose `ports` 에서 추출.
     - compose 서비스·**프로파일**(`default`/`app`/`dev`/`node-app` 등)과 각 기동 범위.
     - `Makefile` 타겟(up/down/dev/dev-*/test/lint/build/deploy)과 실제 명령.
     - 환경 매트릭스(`.env.{local,dev,staging,prod}`)와 연결 URL(직접실행 vs 컨테이너 host 차이).
   - 필수 섹션 / required sections:
     1) 개요 + profile/domain + PRD·COMPLIANCE·SECURITY·AGENTS 링크
     2) 아키텍처/디렉터리(서비스별 역할·포트)
     3) 사전 요구사항(런타임 **버전** 포함)
     4) 환경 설정(.env 매트릭스 + `.env.example` 복사 + 연결정보, 실시크릿 금지 명시)
     5) **실행 방법** — 서버: A) docker compose(`make up`/`dev`/`down`, 프로파일별 기동범위) · B) 호스트 직접(uv/pnpm).
        모바일(`kind: mobile`): 시뮬레이터/에뮬레이터 실행(`make dev`/`ios`/`android`, flutter run/xcodebuild/gradlew), 빌드 플레이버(local/dev/staging/prod), Fastlane→TestFlight/Play(미실행 안내)
     6) **접속/포트 표**(URL·포트·프로파일·비고) + API 문서 경로(예: FastAPI `/docs`)
     7) 구현된 API 예시(`curl` 요청/응답 — 실제 스키마·실제 응답값 기준)
     8) 테스트(`make test` + `test/impl/<Nth>` 개별 실행)
     9) 트러블슈팅(이번 구현·환경에서 실제 만난 이슈 우선)
     10) 다음 단계(PRD 잔여)
   - 실행 방식 구분 / run modes: 자체완결 서비스(컨테이너)와 워크스페이스 앱(호스트 dev)을 명확히 구분해 기술.
   - 멱등 / idempotent: 기존 README 의 사용자 추가 섹션은 보존, 표준 섹션만 갱신.
7.5. **문서 동기화 (항상 실행) / Doc sync (always)** — **living-doc 스킬을 사용**해 이번 구현 이후
   모든 문서의 현행화 여부를 확인하고 갱신한다. 새 요구사항 감지 여부와 **무관하게 매 구현 사이클 종료 시 항상** 실행.
   - **PRD.md** — 구현된 기능이 PRD 범위(§3)·성공 지표(§5)·기술메모(§7)와 일치하는지 확인.
     불일치(실제 구현이 PRD 를 앞서거나 누락) 시 해당 섹션 갱신 + `## 변경 이력` 기록.
   - **README.md / README.en.md** — step 7 에서 갱신됐더라도 API 예시·실행 방법·트러블슈팅이
     이번 구현 결과를 완전히 반영하는지 재검토. 누락 항목 보완.
   - 변경 필요 항목만 갱신 (멱등). 소스코드 수정 절대 금지.
   - living-doc §1.2 매트릭스로 영향 파일 결정 → §3 파일별 규칙 적용.
8. **보고 / Report** — 구현 요약 + 시험 판정(PASS/FAIL) + 생성/수정 파일(PRD·README 포함) + 결과 경로.

## 규칙 / Rules
- **구현 중 언제든** 사용자가 새 요구사항을 언급하면 **PRD.md 를 먼저 갱신**(§4.5-b)한 뒤
  living-doc 스킬로 나머지 문서를 전파하고 구현을 재개한다. PRD 갱신 없이 코드를 작성하지 않는다.
  명시적으로는 `/wise-dev-std:req-update` 로도 호출 가능.
- 시험 사이클은 **test-runner 스킬 표준**을 그대로 따른다 / follow the test-runner standard.
- 기존 차수 디렉터리 덮어쓰기 금지 / never overwrite existing iteration dirs.
- 파괴적 명령·실시크릿·prod 배포 금지 / no destructive ops, real secrets, prod deploy.
- 네트워크 설치는 사용자 승인 후 / network installs only after approval.
