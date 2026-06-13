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
8. **보고 / Report** — 구현 요약 + 시험 판정(PASS/FAIL) + 생성/수정 파일(README 포함) + 결과 경로.

## 규칙 / Rules
- 시험 사이클은 **test-runner 스킬 표준**을 그대로 따른다 / follow the test-runner standard.
- 기존 차수 디렉터리 덮어쓰기 금지 / never overwrite existing iteration dirs.
- 파괴적 명령·실시크릿·prod 배포 금지 / no destructive ops, real secrets, prod deploy.
- 네트워크 설치는 사용자 승인 후 / network installs only after approval.
