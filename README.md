# Wise Dev Standard — Claude Code 플러그인 (공개 배포본)

PRD.md와 몇 가지 선택만으로 **현재 트렌드에 맞는 개발 스택(언어·패키지매니저·프레임워크·DB·실행방식)을 추천**하고, **기본 프로젝트 구조를 생성**하는 Claude Code 플러그인입니다. 표준은 IDE 중립 포맷(`AGENTS.md`)으로 내보낼 수 있어 **Cursor·Antigravity 에서도 동일하게 준용**됩니다.

- **English**: [README.en.md](README.en.md)
- **공개 저장소**: `pub-wise-dev-std` — 마켓플레이스 이름은 `wise-dev-std`, 플러그인 이름은 `wise-dev-std`.
- **1차 범위**: Claude CLI 플러그인. Cursor/Antigravity 는 `AGENTS.md` 내보내기로 준용.

> 설치/업데이트 명령은 **`wise-dev-std@wise-dev-std`** 형식입니다 (`<플러그인>@<마켓플레이스>`).

---

## 1. 무엇을 해결하나

일반 개발자가 새 프로젝트를 시작할 때 반복하는 의사결정을 표준화·자동화합니다.

1. 환경 구성 + FE/BE/DB/Ops 구조 설계
2. 언어별 패키지 매니저 선택 — `uv`, `pip`, `pnpm`, `npm` …
3. `local / dev / staging / prod` 환경 분리 + DB 선택 (`sqlite` / `postgres`)
4. 실행 방식 — 직접(`pnpm dev`, `uvicorn`) vs `docker compose up`
5. PRD.md 가 주어지면 → node/python·frontend/backend 등 **기본 조건만 선택**하면
   트렌드에 맞는 언어·패키지매니저·구동 방식을 추천하고 기본 구조를 생성
   - PRD 작성이 어려우면 `/wise-dev-std:prd` 가 **5질문 설문**으로 `PRD.md` 초안을 자동 생성
     (애자일 One-Page 기본, `--full` 풀스펙).
6. **업종/업태(KSIC 대분류)** 를 입력하면 그 업종의 규제·데이터등급·선호스택·인프라·시험을
   오버레이로 반영 (예: 금융=망분리/PCI, 의료=FHIR/비식별, 게임=확률공개 audit)

---

## 2. 구성 요소

| 유형    | 이름                             | 역할                                                                       |
| ------- | -------------------------------- | -------------------------------------------------------------------------- |
| Command | `/wise-dev-std:prd`         | 설문(Why·Who·What·How·Success) → 루트 `PRD.md` 초안 생성 (`--full` 풀스펙) |
| Command | `/wise-dev-std:recommend`   | PRD + 선택 → 스택 추천 (표 출력)                                           |
| Command | `/wise-dev-std:scaffold`    | 확정 프로파일 → 디렉터리/Makefile/compose/매니페스트/CI/.env 생성          |
| Command | `/wise-dev-std:env-init`    | `local/dev/staging/prod` 환경파일 + compose 오버라이드 생성                |
| Command | `/wise-dev-std:standardize` | 표준을 `AGENTS.md` + `.cursor/rules` 로 내보내기 (Cursor/Antigravity 준용) |
| Command | `/wise-dev-std:implement`   | PRD **전체 자동 구현** — 확인 1회 후 Epic 단위 구현→시험→수정→재시험을 모두 PASS 까지 반복(`test/impl/<Nth>`), README(한/영) 현행화 |
| Command | `/wise-dev-std:review` 등   | **선택 명령**(필수 아님): review · reverse-prd · req-update · standardize · test · ui-design — §4-5 간단 가이드 |
| Skill   | `prd-advisor`                    | PRD 작성 도우미 지식 베이스(5질문 설문 + One-Page/풀스펙 템플릿 + KSIC KPI·NFR 제안) |
| Skill   | `stack-advisor`                  | 스택 의사결정 지식 베이스(결정 매트릭스 + KSIC 업종 매핑)                  |
| Skill   | `project-scaffolder`             | 구조 생성 규칙 (`test/` 시험 골격 + 업종 `COMPLIANCE.md` 포함)             |
| Skill   | `test-runner`                    | 시험 표준: 시나리오→진행→오류시 수정·재시험→결과 (`test/` 규칙)            |
| Skill   | `depth-reviewer`                 | 심층 분석 지식 베이스(스택·라이선스·보안·유지보수·아키텍처·법적·5단계 등급) |
| Skill   | `code-reviewer`                  | 라인 단위 레벨별(0~4, 기본 2) 코드 리뷰 지식 베이스 (`.review/` 트리)        |
| Agent   | `stack-architect`                | recommend→scaffold→env-init 흐름을 독립 수행하는 서브에이전트              |
| Hook    | `SessionStart`                   | `PRD.md` 있으면 사용법, 없으면 `/prd` 작성 도우미 1줄 제안 (스캐폴딩 흔적 있으면 침묵) |
| Data    | `profiles/*.yaml`                | **확장 지점(스택)** — 스택 프로파일 (YAML 1개 = 선택지 1개)                |
| Data    | `domains/*.yaml`                 | **확장 지점(업종/업태)** — KSIC 대분류별 도메인 오버레이 (규제·데이터등급·선호스택) |

### 디렉터리

```
pub-wise-dev-std/
├── .claude-plugin/
│   └── marketplace.json            # 마켓플레이스 정의 (name: wise-dev-std)
├── plugins/
│   └── wise-dev-std/
│       ├── .claude-plugin/plugin.json
│       ├── commands/               # prd, recommend, scaffold, env-init, standardize, implement, review
│       ├── skills/                 # prd-advisor, stack-advisor, project-scaffolder, test-runner, depth-reviewer, code-reviewer
│       ├── agents/                 # stack-architect
│       ├── profiles/               # *.yaml (스택 확장 지점) + _schema.md
│       ├── domains/                # *.yaml (업종/업태 확장 지점, KSIC) + _schema.md
│       ├── hooks/hooks.json        # SessionStart
│       ├── data/trends-cache.yaml  # 버전 핀 + 규제 시행일 캐시 (--trends cache-first)
│       ├── scripts/                # detect-prd.sh, export-portable.sh, install-portable.sh, refresh-trends.sh
│       └── templates/              # AGENTS.md(IDE 중립) + gitignore/ + scaffold/<id>/ (정적 스캐폴드)
└── README.md  /  README.en.md
```

---

## 3. 설치

> 핵심: **마켓플레이스 이름 = `wise-dev-std`**, **플러그인 이름 = `wise-dev-std`**.
> 설치 시 `wise-dev-std@wise-dev-std` 를 사용합니다.

### 방법 A — git clone 후 로컬 마켓플레이스 (수정·기여용)

먼저 저장소를 clone:

```
git clone https://github.com/WisemanLim/pub-wise-dev-std.git
cd pub-wise-dev-std
```

Claude CLI 에서 (clone 한 디렉터리 기준):

```
/plugin marketplace add .
/plugin install wise-dev-std@wise-dev-std
```

> `marketplace add` 에는 `.claude-plugin/marketplace.json` 이 있는 **디렉터리 경로**(clone 루트)를 줍니다.
> 설치 후 `/help` 또는 `/plugin` 에서 명령어가 보이면 성공입니다.

### 방법 B — Git 마켓플레이스 (팀 공유)

```
/plugin marketplace add WisemanLim/pub-wise-dev-std
/plugin install wise-dev-std@wise-dev-std
```

활성화/비활성화: `/plugin` 메뉴에서 토글.

### 업데이트 / Update

**방법 A (git clone) 로 설치한 경우** — 소스를 당겨받고 마켓플레이스를 새로고침:

```
cd pub-wise-dev-std
git pull
```

그 다음 Claude CLI 에서:

```
/plugin marketplace update wise-dev-std
/plugin update wise-dev-std@wise-dev-std
```

**방법 B (원격 마켓플레이스) 로 설치한 경우** — 마켓플레이스 메타데이터만 갱신:

```
/plugin marketplace update wise-dev-std
/plugin update wise-dev-std@wise-dev-std
```

- `marketplace update` 는 마켓플레이스 목록(버전/플러그인 메타)을 새로고침합니다 (인자 = 마켓플레이스 이름 `wise-dev-std`).
- `plugin update` 는 설치된 플러그인을 최신 버전으로 올립니다.
- 변경 확인: `/plugin` 메뉴에서 버전(현재 `0.8.0`) 표시를 확인.
- 문제 시 재설치: `/plugin uninstall wise-dev-std@wise-dev-std` 후 다시 install.

> 버전 규칙 / versioning: `plugin.json` 과 `marketplace.json` 의 `version` 을 함께 올립니다(SemVer).

---

## 4. 사용법

### 4-1. 기본 흐름

```
# 1) PRD.md 준비 — 직접 두거나, 작성이 어려우면 설문으로 초안 생성
/wise-dev-std:prd "내 프로젝트" healthcare        # 5질문 설문 → 루트 PRD.md
#   풀스펙(아키텍처·NFR·데이터·규제):  /wise-dev-std:prd "내 프로젝트" --full

# 2) 스택 추천 (+ 업종 힌트로 규제·데이터등급 오버레이)
/wise-dev-std:recommend
#   언어 힌트:     /wise-dev-std:recommend python --trends
#   언어+업종 힌트: /wise-dev-std:recommend python healthcare --trends

# 3) 추천 확정 후 구조 생성 (업종 지정 시 COMPLIANCE.md 생성)
/wise-dev-std:scaffold python-fastapi --domain healthcare
#   대화형 스택 선택:  /wise-dev-std:scaffold custom

# 4) 환경 파일 생성 (local/dev/staging/prod)
/wise-dev-std:env-init python-fastapi

# 5) PRD 전체 자동 구현 — 확인 1회 후 모든 Epic 을 구현→시험→수정→재시험 (PASS 까지)
/wise-dev-std:implement python-fastapi
#   특정 Epic 만 / 중단 후 재개 / Epic 마다 확인:  --epic 3  |  --from 4  |  --step

# (선택) 코드 리뷰·IDE 표준 내보내기 등은 §4-5 참조
```

생성된 프로젝트의 실행은 **환경 무관 동일 네이밍**의 Makefile 로 통일됩니다:

```
make preflight                       # 도구 점검
make local-build && make local-all   # local: 의존성/빌드 + infra(docker) + 프로세스 매니저 기동
make local-logs | local-stop | local-restart | local-ps
make dev-all | staging-all | prod-all          # 컨테이너 전체 스택 (.env.<env>)   (+ dev-build / staging-build)
make dev-logs | dev-stop | dev-restart | dev-ps  # staging-*, prod-* 동일
make db-migrate | db-seed | db-reset | db-fresh [ENV=dev]   # prod reset 거부
make test | deploy | help
```

---

### 4-2. 단계별 가이드 (prd → implement)

5개 명령이 **하나의 파이프라인**입니다. 각 단계는 앞 단계의 산출물을 입력으로 받아 다음 단계로 넘깁니다.
순서: **prd → recommend → scaffold → env-init → implement.** (standardize·review 등은 선택 — §4-5)

```
PRD.md  →  스택 추천  →  골격 생성  →  환경 파일  →  구현+시험(자동 반복)
 prd      recommend     scaffold      env-init         implement
```

#### 1단계 — `prd` · 요구사항 정의

- **목적**: 무엇을 왜 만드는지(`PRD.md`)를 먼저 고정한다. 이후 모든 단계의 단일 입력.
- **명령**: `/wise-dev-std:prd "[프로젝트이름]" [업종] [--full]`
- **입력**: 프로젝트 이름, (선택) 업종 KSIC 키워드, `--full`(풀스펙 확장).
- **동작**: `prd-advisor` 스킬이 **5 핵심 질문(Why·Who·What·How·Success)** 을 한 번에 묻고 초안 작성.
  기존 PRD 가 있으면 덮어쓰지 않고 보강 여부를 먼저 확인. 모르는 값은 `가정:` 으로 표시.
- **산출물**: 루트 `PRD.md` (One-Page 기본, `--full` 시 아키텍처·NFR·데이터·규제·Epic 추가).
- **다음**: `recommend`.
- 💡 이미 PRD 가 있으면 이 단계는 건너뛰어도 됩니다.

#### 2단계 — `recommend` · 스택 추천

- **목적**: PRD 와 기본 선택으로 **언어·패키지매니저·프레임워크·DB·실행방식**을 결정.
- **명령**: `/wise-dev-std:recommend [언어/프로파일 힌트] [업종] [--trends]`
- **입력**: `PRD.md`(자동 탐색), 언어/모바일 힌트, 업종 KSIC 키워드, `--trends`(최신 버전·규제 시행일 반영).
- **동작**: `stack-advisor` 스킬이 `profiles/*.yaml` × `domains/*.yaml` 을 결정 매트릭스로 점수화 →
  1순위 프로파일 + 대안 제시. 업종 입력 시 규제·데이터등급 오버레이 요약 동봉.
- **산출물**: 추천 **표**(선택/대안/근거) + 도메인 오버레이 요약 (파일 미생성, 화면 출력).
- **다음**: 확정한 `<profile-id>` 로 `scaffold`.
- 💡 `--trends` 는 캐시 우선(`data/trends-cache.yaml`). STALE 항목만 WebSearch 로 재확인.

#### 3단계 — `scaffold` · 프로젝트 골격 생성

- **목적**: 확정 프로파일로 실제 디렉터리·빌드·CI·문서 골격을 만든다.
- **명령**: `/wise-dev-std:scaffold <profile-id> [--domain <id>] [target-dir]`
  또는 대화형: `/wise-dev-std:scaffold custom` (플랫폼→언어→DB→환경→업종→이름 6단계 선택).
- **입력**: 프로파일 id (또는 custom 선택), (선택) 업종 도메인, 생성 위치.
- **동작**: `project-scaffolder` 스킬이 `templates/scaffold/<id>/` 정적 템플릿을 복사 + `{{PROJECT_NAME}}` 치환.
  `kind: service` 는 compose/Dockerfile/DB, `kind: mobile` 은 플랫폼 레이아웃+플레이버+Fastlane.
  멱등 `.gitignore`(언어+플랫폼)도 이 시점에 조립.
- **산출물**: 디렉터리 트리, `Makefile`, `docker-compose.yml`, 언어 매니페스트, `.env.*`,
  `.github/workflows/ci.yml`, `README.md`/`README.en.md` 스텁, 업종 지정 시 `COMPLIANCE.md`.
- **다음**: `env-init`.
- 💡 안전: **파일만 생성**. 설치/네트워크 명령·실시크릿 없음. 기존 동일 파일은 `*.generated` 로 보존.

#### 4단계 — `env-init` · 환경 파일

- **목적**: `local/dev/staging/prod` 4환경을 표준대로 구성하고, 플랫폼별 불필요 파일 정리.
- **명령**: `/wise-dev-std:env-init <profile-id> [--db sqlite|postgres]`
- **입력**: 프로파일 id, (선택) DB 강제 지정.
- **동작**: 프로파일 `kind` 로 분기 —
  - `service`: `.env.{local,dev,staging,prod}` + `docker-compose.override.yml` + `.env.example`.
    (local=sqlite, dev+=postgres+redis. `.env.prod` 은 **키 목록만**.)
  - `native-mobile`(iOS/Android): `.env.*` 대신 **xcconfig / BuildConfig**(불필요한 `.env.*` 는 삭제 보고).
  - `cross-mobile`(Flutter/RN): `.env.*` 유지 + `env.dart` / `env.ts` 소스.
- **산출물**: 환경 파일 일습 (실 비밀번호/토큰/서명키는 전부 placeholder).
- **다음**: `standardize`.
- 💡 모바일 `api_base` 호스트: iOS Simulator=`localhost`, Android Emulator=`10.0.2.2`.

#### (선택) `standardize` · IDE 중립 표준 내보내기 — §4-5 참조

- **목적**: Claude 플러그인 표준을 **Cursor·Antigravity 도 읽는 포맷**으로 내보낸다.
- **명령**: `/wise-dev-std:standardize [profile-id] [--domain <id>]`
- **입력**: (선택) 강조할 프로파일, (선택) 업종 오버레이.
- **동작**: `templates/AGENTS.md` 를 기반으로 현재 스택·업종 요약을 삽입해 표준 문서 생성.
- **산출물**: `AGENTS.md`(공통), `.cursor/rules/wise-dev-std.mdc`(`alwaysApply: true`),
  `.antigravity/rules.md`. → 세 도구가 동일 표준 준용.
- **다음**: `implement`.
- 💡 셸 일괄 설치: `scripts/install-portable.sh <target-dir>` (`--zip` 배포 패키징).

#### 5단계 — `implement` · PRD 전체 자동 구현 + 시험

- **목적**: 표준 환경 위에서 PRD 의 **모든 Epic** 을 한 번의 호출로 구현하고 시험까지 통과시킴.
- **명령**: `/wise-dev-std:implement [profile-id] [--epic N] [--from N] [--step] [--max-retry K]`
- **사전조건**: scaffold → env-init 완료(Makefile + `.env.*`). standardize 는 선택.
- **동작**:
  1. **dev-env 시험(최초 1회)** — `make preflight → local-build → local-all → db-migrate → test` → `test/dev-env/`.
  2. PRD 파싱 → **Epic 구현 계획표**(기능·수용기준·의존·상태).
  3. **사용자 확인 1회** — 계획표 승인 + PRD 의 모호·누락 항목만 질문. 이후 개입 없음.
  4. **Epic 루프** — Epic 마다 구현 → `test/impl/<Nth>/` 시험 → 실패 시 수정·재시험(`--max-retry`, 기본 5) → PASS 면 다음 Epic.
     한도 초과 Epic 은 BLOCKED 로 기록하고 계속 진행. Epic 마다 다시 호출할 필요 없음(`--step` 시에만 매번 확인).
  5. 전체 회귀 `make test` → BLOCKED 가 있으면 필요한 결정을 **한 번에** 질문 → 해당 Epic 재실행.
  6. **README(한/영) 현행화** + living-doc 으로 PRD 일치 재검토.
- **산출물**: 기능 코드, Epic 별 `test/impl/<Nth>/{scenario,result}.md` + `logs/`, 갱신된 README/PRD, 최종 계획표.
- 💡 차수(`1st`,`2nd`,…)는 자동 증가, 기존 차수 디렉터리는 덮어쓰지 않음. 재시험은 같은 차수에 회차 누적.

### 4-5. 선택 명령 (필수 아님 — 간단 가이드)

| 명령 | 언제 | 사용 |
|------|------|------|
| `/wise-dev-std:review [paths] [--level 0~4] [--only depth\|code]` | 구현 후 품질 게이트가 필요할 때 | 심층 분석 + 라인 단위 코드 리뷰 → `.review/` |
| `/wise-dev-std:reverse-prd [path] [--full]` | PRD 없이 시작한 기존 소스 | 소스 분석 → `PRD.md` 역도출 |
| `/wise-dev-std:req-update` | 개발 중 요구사항 변경 | PRD·README·COMPLIANCE 등 문서에만 전파(소스 불변) |
| `/wise-dev-std:standardize <profile>` | Cursor/Windsurf/Copilot 등 다른 IDE 병용 | `AGENTS.md` + IDE 규칙 파일 내보내기 |
| `/wise-dev-std:test [--area dev-env\|impl]` | scaffold 흐름 없이 지금 소스만 시험 | test-runner 사이클 즉시 실행 |
| `/wise-dev-std:ui-design` | 프론트엔드 포함 프로젝트 | 디자인 시스템·레퍼런스·접근성 스택 델타 |

### 4-3. recommend 출력 예 (형식)

| 항목         | 선택                                            | 대안             | 근거 / 수정 포인트                 |
| ------------ | ----------------------------------------------- | ---------------- | ---------------------------------- |
| 업종(KSIC)   | `healthcare` (KSIC Q)                           | —                | 의료 도메인 → 규제·FHIR 오버레이   |
| 언어         | Python                                          | Node             | PRD 의 분석/ML 요구 → Python 1순위 |
| 패키지매니저 | uv                                              | pip              | 빠른 resolver + venv 통합          |
| 백엔드       | FastAPI                                         | NestJS           | 타입힌트·자동문서                  |
| DB           | SQLite(local) / PostgreSQL(dev+)                | —                | 신규 기본 Postgres                 |
| 실행방식     | `uv run uvicorn --reload` / `docker compose up` | —                | 직접+컨테이너                      |
| 프로파일     | `python-fastapi`                                | `node-next-nest` | —                                  |

### 4-4. 생성물 (scaffold)

프로파일 `python-fastapi` 예: `app/`, `tests/`, `docker/`, `Makefile`, `docker-compose.yml`, `pyproject.toml`, `.env.{local,dev,staging,prod}`, `.github/workflows/ci.yml`.
공통 진입점:

```
make preflight | local-build | local-all | local-logs | local-stop     # local (docker infra + honcho/pm2)
make dev-all | dev-build | dev-logs | dev-stop        # staging-*, prod-* 동일 (prod-build 없음)
make db-migrate | db-seed | db-reset | db-fresh [ENV=<env>]
make test | deploy | help
```

> 안전: 스캐폴더는 **파일만 생성**합니다. 설치/네트워크 명령은 실행하지 않으며,
> 실제 시크릿은 만들지 않습니다(`.env.prod` 은 키 목록만). 기존 동일 파일은 덮어쓰지 않고 `*.generated` 로 둡니다.

---

## 5. 프로파일 (확장 지점)

현재 제공:

| id                 | 설명                                               | status  |
| ------------------ | -------------------------------------------------- | ------- |
| `node-next-nest`   | Next.js + NestJS (TS 통일, BFF)                    | stable  |
| `python-fastapi`   | FastAPI + uv + uvicorn (데이터/ML/RAG)             | stable  |
| `go-gin`           | Gin + GORM (고처리량 코어/워커)                    | stable  |
| `rust-axum`        | Axum/Actix + SQLx (메모리안전·고성능, Tauri)       | stable  |
| `bio-rag-research` | 연구조직 RAG 플랫폼(역할분리형 + 보안/감사/재현성) | preview |
| `ios-swiftui`      | iOS 네이티브 (Swift + SwiftUI, Xcode)              | stable  |
| `android-compose`  | Android 네이티브 (Kotlin + Jetpack Compose)        | stable  |
| `flutter-app`      | Flutter (Dart, iOS+Android 단일 코드베이스)        | stable  |
| `react-native-app` | React Native (Expo, TS, iOS+Android)               | stable  |

> **모바일 프로파일(`kind: mobile`)** 은 서버 프로파일과 구조가 다릅니다. 서버 DB(postgres)·docker-compose·K8s
> 대신 **온디바이스 저장**(SwiftData/Room/Drift/expo-sqlite) + **페어링 API**(앱 단독이 기본, 필요 시 서버 프로파일
> 별도 또는 `extends` 로 모노레포 결합) + **빌드 플레이버**(local/dev/staging/prod → flavor·api_base·서명) +
> **Fastlane → TestFlight/Play** 배포로 매핑됩니다(iOS 빌드는 macOS CI 러너). 자세한 의미는
> `profiles/_schema.md` §모바일, 스캐폴딩 규칙은 `project-scaffolder` §2.5 참조.

### 새 프로파일 추가하기

1. `plugins/wise-dev-std/profiles/_schema.md` 의 스키마를 따른다.
2. `profiles/<new-id>.yaml` 한 개를 추가한다. (`extends:` 로 기존 프로파일 조합 가능)
3. 끝. 명령어/스킬이 런타임에 디렉터리를 스캔하므로 **코드 수정 불필요**.

---

## 5.5 도메인 오버레이 (업종/업태 — KSIC 기반)

스택(`profiles/`)과 **직교**하는 두 번째 축입니다. 업종(KSIC 대분류)을 입력하면 그 업종의
**규제·데이터등급·선호스택·인프라·시험**을 추천에 반영하고, 스캐폴딩 시 `COMPLIANCE.md` 로 출력합니다.
한국 규제를 1순위로 반영하고 2025–2026 글로벌 스택 트렌드를 서베이로 보강했습니다(각 YAML `references`).

| 도메인 id | KSIC | 업태 | 핵심 규제(한국, 1순위) | 스택 편향 |
| --- | --- | --- | --- | --- |
| `finance` | K | 금융·보험 | 전자금융감독규정(2025)·신용정보법·ISMS-P·마이데이터 | Go/Rust 코어 + Postgres 원장 + Kafka |
| `healthcare` | Q | 보건·의료 | PIPA 민감정보·의료법·EMR인증제·SaMD(IEC62304)·CSAP | FHIR R4 + Python ML + 비식별 |
| `commerce` | G | 도소매·이커머스 | 전자상거래법·전자금융거래법(정산)·PCI-DSS | 헤드리스 + 멱등결제 + 검색 |
| `logistics` | H | 운수·물류·모빌리티 | 위치정보법(6개월 파기)·화물자동차법 | PostGIS + TimescaleDB + Kafka |
| `manufacturing` | C | 제조·스마트팩토리 | 스마트공장표준·중대재해처벌법·IEC62443 | OPC-UA/MQTT + 시계열DB + 엣지 Rust/Go |
| `govtech` | O | 공공행정 | 전자정부법·eGovFrame·N2SF/CSAP·KWCAG2.2 | eGovFrame(Spring) + 접근성 |
| `edtech` | P | 교육 | PIPA·만14세미만 보호자동의·COPPA | WebRTC/HLS + 버스트스케일 |
| `media-gaming` | R | 미디어·게임 | 게임산업법 확률공개·등급분류(GRAC/IARC) | UDP/QUIC 전용서버 + 안티치트 |
| `ict-saas` | J | 정보통신·SaaS | 정보통신망법·PIPA·ISMS-P·CSAP | **기본 베이스라인**: 멀티테넌시 + OTel |
| `agriculture` | A | 농림어업·푸드테크 | 농수산물이력추적·식품위생법·HACCP·위치정보법 | 엣지/MQTT + TimescaleDB + PostGIS |
| `construction` | F | 건설·건축 | 중대재해처벌법·산업안전보건법·BIM(ISO 19650) | BIM/IFC + PostGIS + 안전 텔레메트리 |
| `hospitality` | I | 숙박·음식·여행 | 전자상거래법·식품위생법·관광진흥법·PCI-DSS | 예약 동시성(오버부킹 방지) + 멱등결제 |
| `energy-utilities` | D·E | 전기·가스·수도·환경 | 정보통신기반보호법·전기사업법·IEC 62443 | OT/IT 망분리 + AMI 시계열 + 이상감지 |

> `ict-saas`(J) 가 항상 베이스라인입니다 — 다른 업종도 SW 활동 자체는 J 로 이중분류되므로,
> 업종 오버레이는 그 위에 규제·스택 **델타**를 얹는 방식으로 적용됩니다. 부동산(L)은 `finance`(정산) 또는
> `ict-saas`+PostGIS, 연구개발(M)은 `bio-rag-research` 또는 `ict-saas` 로 매핑합니다(stack-advisor §1.5).

### 새 업종(도메인) 추가하기

1. `plugins/wise-dev-std/domains/_schema.md` 의 오버레이 스키마를 따른다.
2. `domains/<new-id>.yaml` 한 개를 추가한다 (KSIC 섹션 + 규제 + 선호 프로파일 + 데이터등급).
3. 끝. recommend/scaffold 가 런타임에 스캔하므로 **코드 수정 불필요**.

> 도메인은 스택을 **교체하지 않고 편향**합니다. 스택이 업종에 강결합(역할분리 RAG 등)이면 여전히
> `profiles/*.yaml` + `extends:` 로 작성합니다(예: `bio-rag-research`).

---

## 6. Cursor · Antigravity 준용

Cursor 와 Antigravity 는 프로젝트 루트의 `AGENTS.md` 를 컨텍스트로 읽습니다. Cursor 는 `.cursor/rules/*.mdc` 도 읽습니다.

```
/wise-dev-std:standardize          # Claude 안에서 내보내기
# 또는 쉘에서 직접:
bash plugins/wise-dev-std/scripts/export-portable.sh /path/to/your/project
```

생성물:

- `AGENTS.md` — Claude Code / Cursor / Antigravity 공통 표준
- `.cursor/rules/wise-dev-std.mdc` — `alwaysApply: true`

세 도구가 동일한 언어·패키지매니저·환경·실행 표준을 따르게 됩니다.

---

## 7. 시험 표준 (test/)

표준에 시험이 포함됩니다. 표준 환경 구성 직후와 모든 구현 단계에서 동일한 시험 사이클을 적용하고, 결과를 프로젝트 루트 `test/` 에 저장합니다. (`test-runner` 스킬)

### 시험 사이클

1. **시험 시나리오 작성** — PRD 의 요구사항·수용기준을 케이스 표로 분해 → `scenario.md`
2. **시험 진행** — `make test` 또는 직접 러너 실행, 원본 출력은 `logs/` 에
3. **오류 발견 시 수정·재시험** — 근본 원인 분석 → 코드 수정 → 재실행, 각 라운드 기록(loop)
4. **시험결과 작성** — 케이스별 pass/fail·발견 오류·수정 내역·재시험 라운드·최종 판정 → `result.md`

### 디렉터리 규칙

```
test/
├── README.md                 # 시험 표준 요약
├── dev-env/                  # 표준 환경 구성 검증 (1회) — scaffold + env-init 후
│   ├── scenario.md           #   make preflight/local-build/local-all, db-migrate, 헬스 체크, make test
│   ├── result.md
│   └── logs/
└── impl/                     # 구현 시마다 (implement 명령)
    ├── 1st/                  #   차수는 기존 디렉터리 스캔 후 자동 증가
    │   ├── scenario.md
    │   ├── result.md
    │   └── logs/
    ├── 2nd/
    └── ...                   # 3rd, 4th, …
```

- `test/dev-env/` 는 **표준 환경**(언어·패키지매니저·DB·실행방식·compose)이 제대로 구성됐는지 1회 검증.
- `test/impl/<Nth>/` 는 **구현마다** 새 차수 디렉터리를 만들어 그 회차의 시나리오·결과를 보존(덮어쓰기 금지).
- 러너: 프로파일별 `testing.framework` (Vitest+Playwright / pytest / go test / cargo test / Ragas).
- 원본 로그(`test/**/logs/`)는 비커밋 권장(`.gitignore`).

> 안전: 시험은 코드 수정을 동반할 수 있으나(3단계), 파괴적 명령(DB drop·prod 배포)·실데이터·실시크릿은 금지합니다.

---

## 8. 표준 요약

- **우선순위 언어**: Node/TS · Python · Rust · Go · C/C++
- **패키지매니저**: Python=`uv`(대안 pip), Node=`pnpm`(대안 npm), Go=modules, Rust=cargo. `forever` 금지
- **DB**: 신규 기본 PostgreSQL + Redis, local/test 만 SQLite. 벡터=PGVector/Chroma, 그래프=Neo4j
- **환경**: local(sqlite) / dev·staging·prod(postgres), dev+ 는 compose
- **실행**: 직접 실행 + `docker compose up`, 프로덕션 K8s + Helm + GitOps
- **Ops**: GitHub Actions(or GitLab CI), Docker/Compose, K8s/Helm, Argo CD/Flux, SonarQube/Sentry
- **모바일(App)**: 네이티브 iOS(Swift/SwiftUI)·Android(Kotlin/Compose), 크로스 Flutter(Dart)·React Native(Expo/TS).
  온디바이스 저장(SwiftData/Room/Drift/expo-sqlite), 빌드 플레이버(local/dev/staging/prod), Fastlane→TestFlight/Play, iOS 빌드=macOS CI

---

## 9. 검증

```
python3 -c "import json; json.load(open('.claude-plugin/marketplace.json'))"   # 마켓플레이스 JSON
bash -n plugins/wise-dev-std/scripts/*.sh                                  # 스크립트 문법
bash plugins/wise-dev-std/scripts/refresh-trends.sh                        # 트렌드 캐시 신선도(FRESH/STALE)
# 프로파일·도메인·캐시 YAML 문법 (PyYAML 있으면):
python3 -c "import glob,yaml; P='plugins/wise-dev-std'; fs=glob.glob(P+'/profiles/*.yaml')+glob.glob(P+'/domains/*.yaml')+[P+'/data/trends-cache.yaml']; [yaml.safe_load(open(f)) for f in fs]; print('YAML OK', len(fs))"
```

라이선스: 내부 사용.
