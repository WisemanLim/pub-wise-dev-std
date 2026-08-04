---
name: project-scaffolder
description: >
  확정된 스택 프로파일로 실제 프로젝트 기본 구조를 생성한다 / Generate the base project structure
  from a chosen stack profile. 디렉터리 트리, Makefile, docker-compose.yml, 언어별 매니페스트
  (package.json/pyproject.toml/go.mod/Cargo.toml), .env.{local,dev,staging,prod}, GitHub Actions CI,
  test/ 시험 골격, README 스텁을 만든다. "스캐폴딩", "프로젝트 구조 생성", "보일러플레이트",
  "초기 세팅", "scaffold" 요청 시 사용. stack-advisor 추천 확정 후 호출 / call after stack-advisor.
---

# Project Scaffolder — 기본 구조 생성기

## 0. 사전 조건
- 확정된 프로파일 id (없으면 stack-advisor 먼저).
- (선택) 확정된 **도메인 오버레이 id** (업종). 있으면 `COMPLIANCE.md` + 도메인 인프라/시험 반영.
- 대상 디렉터리 (기본: 현재 작업 디렉터리; 비어있지 않으면 사용자 확인).

## 1. 절차

> **분기**: 프로파일 `kind` 가 `mobile` 이면 **§2.5 모바일** 규칙을 따른다(아래 §2 의 compose/Dockerfile/DB
> 항목은 적용하지 않음). `kind` 가 `service`(기본)면 §2 그대로.

1. `${CLAUDE_PLUGIN_ROOT}/profiles/<id>.yaml` 을 읽는다. `extends:` 가 있으면 베이스도 읽어 병합.
   도메인 오버레이가 지정됐으면 `${CLAUDE_PLUGIN_ROOT}/domains/<domain-id>.yaml` 도 읽는다.
2. `scaffold.tree` 의 디렉터리를 만든다.
3. **정적 템플릿 우선 / static templates first (결정성)** — `${CLAUDE_PLUGIN_ROOT}/templates/scaffold/<id>/` 가
   존재하면 그 트리를 **그대로 복사**하고 파일 내용의 `{{PROJECT_NAME}}` 를 대상 프로젝트명(디렉터리명 또는
   사용자 지정)으로 치환한다 — LLM 생성 대신 결정적 출력. 템플릿에 없는 파일/디렉터리만 아래 §2 규칙으로 **보완 생성**.
   템플릿 디렉터리가 없으면(미커버 프로파일) 종전대로 `scaffold.files` 전체를 §2 규칙으로 생성(fallback).
   복사 시에도 §2.6(기존 파일 보존 → `*.generated`) 규칙 동일 적용. (참조: `templates/scaffold/README.md`)
4. 환경별 `.env.*` 를 `environments` 매트릭스로 생성한다. **단, 아래 경우는 생성하지 않는다:**
   - `native-mobile` (ios-swiftui · android-compose): xcconfig / BuildConfig / `local.properties` 사용 — `.env.*` 전혀 생성 금지.
   - `java-spring`: Spring Profile (`application-local.yml` 등) 사용 — `.env.*` 생성 금지.
   - `csharp-dotnet`: `appsettings.Development.json` + `dotnet user-secrets` 사용 — `.env.*` 생성 금지.
5. 도메인 오버레이가 있으면 `COMPLIANCE.md` 를 생성하고(§2 도메인 항), `stack_overrides` 의
   추가 서비스(Kafka/PostGIS/TimescaleDB/FHIR 등)를 compose 에 주석 스텁으로 포함한다.
6. 생성 후 트리(`find` 또는 직접 나열)와 다음 명령(`make dev`)을 안내한다.
7. **기존 파일 덮어쓰기 금지** — 존재하면 `.generated` 접미사로 쓰고 차이를 보고.

## 2. 파일 생성 규칙

### Makefile (공통 진입점, 원본 §5-2)
프로파일 `makefile_targets` 를 타겟으로. **아래 타겟 전체를 항상 포함**:

```makefile
.PHONY: dev test build deploy up down dc-logs dc-ps ps preflight \
        local-all local-logs local-stop local-restart \
        dev-all dev-build dev-logs dev-stop dev-restart \
        staging-all staging-build staging-logs staging-stop staging-restart \
        prod-all prod-logs prod-stop prod-restart \
        local-down dev-down staging-down prod-down
ENV ?= local
LOCAL_INFRA ?=   # local 모드 compose 서비스 목록. 비워두면 전체 infra. 예: LOCAL_INFRA=redis
PROC_MGR ?= <default-mgr>   # python 만: honcho(기본) | pm2(대안, overlay)

## 사전 호환성 점검 (env-init 전 실행 권장)
preflight: ## 런타임·도구 버전 호환성 점검
	# 언어별 버전 체크 + docker compose v2 확인 (정적 템플릿 참조)

## infra (DB/캐시, app 제외)
up:    ; docker compose up -d                    # 인프라만. app은 profiles:[app]라 안 뜸
down:  ; docker compose --profile app down --remove-orphans

## docker-compose 공통 유틸
dc-logs: ; docker compose logs -f $(SVC)         # SVC= 으로 특정 서비스 지정
dc-ps:   ; docker compose ps

## local 직접 실행 (포그라운드, 단일)
dev:   ; <profile.run_methods.direct.dev>
test:  ; <makefile_targets.test>
build: ; docker compose --profile app build
deploy:; <makefile_targets.deploy>

ps: ; <pm-manager> status   # 프로세스 매니저 상태

## local-all/logs/stop/restart: infra + 프로세스 매니저(web/worker) 한 번에 관리 (백그라운드 데몬화)
local-all:      ## [local] docker infra + 프로세스 매니저 일괄 기동 (백그라운드)
	docker compose up -d $(LOCAL_INFRA)
	<pm-manager 백그라운드 기동: nohup+pidfile 또는 네이티브 데몬(pm2/overmind -D)>
local-logs:     ## [local] 통합 로그 추적 (tail -f 또는 <pm-manager> logs)
	<로그 파일 tail 또는 pm-manager logs>
local-stop:     ## [local] 프로세스 매니저 종료 + infra 정리
	<pm-manager> stop
	docker compose down --remove-orphans
local-restart:  ## [local] 프로세스 매니저 재기동 (infra 유지)
	<pm-manager> restart

## dev/staging/prod: Docker 전체 스택 (환경별 .env.<env> 명시)
dev-all:          ; docker compose --env-file .env.dev --profile app up -d           # 기존 이미지 사용
dev-build:        ; docker compose --env-file .env.dev --profile app up -d --build   # 이미지 재빌드 후 기동
dev-logs:         ; docker compose --env-file .env.dev --profile app logs -f $(SVC)
dev-stop:         ; docker compose --env-file .env.dev --profile app down --remove-orphans
dev-restart:      ; docker compose --env-file .env.dev --profile app restart $(SVC)

staging-all:      ; docker compose --env-file .env.staging --profile app up -d
staging-build:    ; docker compose --env-file .env.staging --profile app up -d --build
staging-logs:     ; docker compose --env-file .env.staging --profile app logs -f $(SVC)
staging-stop:     ; docker compose --env-file .env.staging --profile app down --remove-orphans
staging-restart:  ; docker compose --env-file .env.staging --profile app restart $(SVC)

prod-all:         ; docker compose --env-file .env.prod --profile app up -d
prod-logs:        ; docker compose --env-file .env.prod --profile app logs -f $(SVC)
prod-stop:        ; docker compose --env-file .env.prod --profile app down --remove-orphans
prod-restart:     ; docker compose --env-file .env.prod --profile app restart $(SVC)

## 하위호환 별칭 (recipe 없이 선행 타겟만 실행)
local-down:      local-stop
dev-down:        dev-stop
staging-down:    staging-stop
prod-down:       prod-stop
```

타겟별 용도:

| 타겟 | 용도 | 환경 |
|------|------|------|
| `preflight` | 런타임·도구 버전 사전 점검 | 모든 환경 (env-init 전) |
| `up` / `down` | infra(DB/캐시)만 docker 기동/정리 | local |
| `dc-logs` / `dc-ps` | docker compose 로그·컨테이너 상태 | 모든 환경 |
| `dev` | 단일 프로세스 포그라운드 실행 | local |
| `ps` | 프로세스 매니저 상태 | local |
| `local-all` / `local-logs` / `local-stop` / `local-restart` | infra + 프로세스 매니저(web/worker) 일괄 기동·로그·종료·재기동 (백그라운드) | local |
| `<env>-all` | app+infra 컨테이너 기동 (빌드 없음) | dev/staging/prod |
| `<env>-build` | 이미지 빌드 후 app+infra 기동 (**prod 는 미제공** — 이미지는 CI/CD 산출물 전제) | dev/staging |
| `<env>-logs` | 컨테이너 로그 추적 (SVC=로 특정 서비스) | dev/staging/prod |
| `<env>-stop` | app+infra 전체 정리 | dev/staging/prod |
| `<env>-restart` | 컨테이너 재기동 (SVC=로 특정 서비스, 비우면 전체) | dev/staging/prod |
| `local-down` / `<env>-down` | `local-stop`/`<env>-stop` 의 하위호환 별칭(레시피 없이 선행 타겟 실행) | 모든 환경 |

- **중요**: `up` 은 datastore 만 띄운다. app 서비스(build 컨텍스트 보유)는 compose 에서
  `profiles: [app]` 로 묶어, 코드/Dockerfile 미완 상태에서도 `make up` 이 빌드를 시도해 실패하지 않게 한다.
- `local-all` 의 `LOCAL_INFRA`: SQLite 사용 시 postgres 불필요 → `LOCAL_INFRA=redis make local-all` 로 redis 만 기동.
- `<env>-all` vs `<env>-build`: 코드 변경 없이 재시작은 `-all`, Dockerfile/소스 변경 후 재빌드는 `-build`.
  **prod 는 `-build` 를 두지 않는다** — prod 이미지는 CI/CD 파이프라인 산출물을 pull 하는 것을 전제로 하고,
  로컬에서 prod 이미지를 재빌드하는 경로를 만들지 않는다(사고 방지).
- **하위호환 별칭**: 기존 `local-down`/`dev-down`/`staging-down`/`prod-down` 을 쓰던 사용자를 위해
  각각 `local-stop`/`<env>-stop` 을 그대로 실행하는 레시피 없는 별칭 타겟을 둔다(`<alias>: <target>` 형태).
- **local/dev/staging/prod 전 환경에 동일한 `-all`/`-logs`/`-stop`/`-restart` 네이밍**을 적용한다 — 환경별로
  다른 커맨드를 외우지 않아도 되게. local 은 프로세스 매니저(호스트) + infra(docker), dev/staging/prod 는
  compose 전체 스택(`--env-file .env.<env> --profile app`)을 대상으로 한다.
- **local 멀티프로세스 타겟**(`local-all`/`local-logs`/`local-stop`/`local-restart`)을 항상 포함한다 — 아래 항 참조.
  `dev` 는 단일·포그라운드 그대로 두고, `local-all` 이 프로세스 매니저로 web+worker 등을 백그라운드로 함께 관리.
- **포그라운드 전용 매니저(honcho/goreman 기본 모드)도 nohup+pidfile 로 백그라운드 데몬화**해
  `local-logs`/`local-stop`/`local-restart` 가 PM2/overmind 와 동일하게 동작하도록 한다(정적 템플릿 참조:
  `templates/scaffold/*/Makefile` 의 `.make/<mgr>.pid` + `.make/<mgr>.log` 패턴).

### local 멀티프로세스 매니저 (host/베어메탈 편의 / direct-mode process manager)
컨테이너(compose/K8s) 대신 **호스트 직접 실행** 시 web·worker 등 여러 프로세스를 한 번에 관리하는
**언어별 관용 도구**를 표준으로 둔다. compose `app` 프로파일과 별개(둘 다 제공). 프로파일별:

| 프로파일 | 매니저 | 설정 파일 | 비고 |
|---------|--------|----------|------|
| node-next-nest | **PM2** | `ecosystem.config.cjs` | 데몬·로그·재시작 완비. 베어메탈 prod 재사용. `pnpm exec pm2`(devDep) |
| python-fastapi | **honcho**(기본) 또는 **pm2**(대안, `PROC_MGR=pm2`) | `Procfile.dev` / `ecosystem.config.cjs` | honcho: foreman 류, dev 의존성(`uv add --dev honcho`), nohup+pidfile 로 백그라운드 데몬화. pm2: `npx pm2`, Node 필요. 둘 다 `.make/*.pid` 로 상태 추적, `local-all`에서 `PROC_MGR` 로 선택 |
| go-gin | **goreman** | `Procfile.dev` | `go install github.com/mattn/goreman@latest`. nohup+pidfile 백그라운드 + RPC 제어(`goreman run ...`) |
| rust-axum | **overmind** | `Procfile.dev` | +`cargo-watch`(핫리로드) +tmux. nohup+pidfile 백그라운드 + 제어 소켓. 대안 hivemind |

생성 규칙:
- 설정 파일을 템플릿에 두고 복사(§1-3). `{{PROJECT_NAME}}` 치환. **Procfile.dev / ecosystem.config.cjs 는
  web(메인) 1줄 + worker 주석 예시**를 포함해 멀티프로세스 확장 지점을 보인다.
- Makefile `local-all/local-logs/local-stop/local-restart` 타겟을 매니저 실커맨드로 채운다.
  **네이티브 데몬(PM2)**은 자체 명령을 그대로 쓰고, **포그라운드 매니저(honcho/goreman/overmind)**는
  `nohup <mgr> start > .make/<mgr>.log 2>&1 & echo $! > .make/<mgr>.pid` 로 백그라운드 데몬화해
  `local-logs`(로그 tail)·`local-stop`(pid kill)·`local-restart`(kill 후 재기동)가 PM2 와 동일하게 동작하도록 한다 —
  능력을 과장하지 않되 4개 타겟의 동작은 매니저 무관하게 통일한다.
- python-fastapi 는 `PROC_MGR ?= honcho` 변수로 `local-all/local-logs/local-stop/local-restart` 전부를
  `ifeq ($(PROC_MGR),pm2) ... else ... endif` 로 분기한다(정적 템플릿 참조:
  `templates/scaffold/python-fastapi/Makefile`). `ecosystem.config.cjs`(pm2 대안)도 함께 생성.
- 외부 설치 도구(goreman/overmind/cargo-watch/tmux)는 **설치 명령을 README·Procfile 주석으로 안내만** 하고
  스캐폴더가 실행하지 않는다(§4 네트워크/설치 금지). PM2·honcho 는 프로젝트 매니페스트(devDep)로 포함.
- 미커버 프로파일(fallback)은 `profile.run_methods.direct.local_pm` 힌트를 참고해 동급 도구를 선택.

### docker-compose.yml
- **인프라 서비스**(profile 없음 → `up` 시 기동): `database.default`(postgres) + `cache`(redis).
  프로파일에 vector/graph/object 있으면 추가(pgvector, neo4j, minio).
- **app 서비스**(각 `scaffold.tree` 앱 디렉터리별 build context): 반드시 **`profiles: [app]`** 를 붙인다.
  → 기본 `docker compose up -d` 에서 제외되어 Dockerfile/코드 미완성이어도 `make up` 이 실패하지 않음.
  app 서비스마다 **반드시 Dockerfile 을 함께 생성**한다(아래 항). build context 만 두고 Dockerfile 누락 금지.
- 포트/볼륨/healthcheck 포함. 환경변수는 `.env.${ENV}` 참조.
- **pnpm 워크스페이스 앱(Next/Nest 등)은 dev 시 호스트 실행 권장** — 별도 profile(`node-app`)로 분리하고
  `make dev` 기본 기동에서 제외. 이유: per-dir Docker 빌드는 루트 `pnpm-lock.yaml`/`pnpm-workspace.yaml`
  컨텍스트가 없어 런타임 재설치→ignored-builds 게이트로 크래시. 호스트 `pnpm --filter <app> dev`(워크스페이스 인식)로 구동.
  자체완결 서비스(pyproject 단위 Python, 단일바이너리 Go/Rust)만 compose `app` 프로파일로 컨테이너화.
  워크스페이스 앱의 prod 이미지는 **루트 컨텍스트 멀티스테이지**(lockfile+workspace COPY 후 `pnpm --filter ... deploy`)로 별도 작성.

### Dockerfile (build context 보유 서비스마다 / required per build service)
compose 에 `build:` 를 둔 모든 app/service 디렉터리에는 **그 디렉터리의 언어에 맞는 최소 Dockerfile** 을
함께 생성한다. 누락 시 `docker compose build`/`--profile app up` 이
`failed to read dockerfile: open Dockerfile: no such file` 로 실패한다(이 버그의 원인).
언어는 해당 레이어(profile.layers.frontend/backend/analysis_api/workers)에서 판별. 템플릿:

- **Node (Next.js/NestJS)** — `<app>/Dockerfile` (base ≥ node:22 — corepack 최신 pnpm 는 Node ≥22.13 요구, node:20 은 `node:sqlite` 없어 pnpm 크래시):
  ```dockerfile
  FROM node:22-slim
  WORKDIR /app
  RUN corepack enable
  COPY package.json ./
  RUN pnpm install || true
  COPY . .
  EXPOSE 3000
  CMD ["pnpm", "dev"]
  ```
- **Python (FastAPI/uv)** — `<service>/Dockerfile`:
  ```dockerfile
  FROM python:3.12-slim
  WORKDIR /app
  RUN pip install --no-cache-dir uv
  COPY pyproject.toml ./
  RUN uv sync || true
  COPY . .
  EXPOSE 8000
  CMD ["uv", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
  ```
- **Go (Gin)** — multi-stage `golang:1.23` → `gcr.io/distroless/base`; `CMD ["/server"]`.
- **Rust (Axum)** — multi-stage `rust:1` → `debian:bookworm-slim`; `CMD ["/app/server"]`.
- **C/C++ (CMake + vcpkg)** — multi-stage `ubuntu:24.04` build → `debian:bookworm-slim` runtime:
  ```dockerfile
  FROM ubuntu:24.04 AS builder
  RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential cmake ninja-build git curl zip unzip tar pkg-config \
      libssl-dev libpq-dev libsqlite3-dev && rm -rf /var/lib/apt/lists/*
  ENV VCPKG_ROOT=/opt/vcpkg
  RUN git clone --depth=1 https://github.com/microsoft/vcpkg /opt/vcpkg && \
      /opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics
  WORKDIR /src
  COPY vcpkg.json CMakeLists.txt CMakePresets.json ./
  RUN /opt/vcpkg/vcpkg install --triplet=x64-linux --no-print-usage
  COPY . .
  RUN cmake --preset release -B build/release && \
      cmake --build build/release --parallel

  FROM debian:bookworm-slim AS runtime
  RUN apt-get update && apt-get install -y --no-install-recommends \
      libssl3 libpq5 libsqlite3-0 ca-certificates && rm -rf /var/lib/apt/lists/*
  COPY --from=builder /src/build/release/{{PROJECT_NAME}} /app/server
  EXPOSE 8080
  CMD ["/app/server"]
  ```
  VCPKG_ROOT 레이어 캐시 팁: `vcpkg.json` 과 `CMakeLists.txt` 를 먼저 COPY 후 `vcpkg install`(의존성 고정) → 이후 소스 COPY. 의존성 변경 없으면 vcpkg 레이어 재사용.

포트/EXPOSE/CMD 는 compose 의 해당 서비스 포트·dev 커맨드와 일치시킨다. `|| true` 는 lockfile/코드
미완 스캐폴드에서도 이미지 빌드가 통과하도록 둔 스텁 — 구현 단계에서 `--frozen-lockfile` 등으로 강화.

### 언어별 매니페스트
- Node: `package.json` (+ monorepo면 `pnpm-workspace.yaml`). scripts: dev/build/start/test.
- Python: `pyproject.toml` (`[project]` + uv. deps: fastapi, uvicorn, sqlalchemy, alembic, pydantic). `uv.lock` 은 `uv sync` 안내.
  - **build-backend(hatchling) 사용 시 반드시 패키지 경로 명시**: `[tool.hatch.build.targets.wheel] packages = ["app"]`
    (코드 디렉터리명과 프로젝트명이 다르면 `uv sync` 가 `Unable to determine which files to ship` 로 실패함).
    앱 코드 디렉터리에 맞춰 `packages` 지정(`app`/`src/<pkg>` 등). 라이브러리 아닌 순수 앱이면 `[tool.uv] package = false` 도 가능.
- Go: `go.mod` + `cmd/server/main.go` 최소 Gin 핸들러.
- Rust: `Cargo.toml` + `src/main.rs` 최소 Axum 핸들러 + tokio.
- C/C++: `CMakeLists.txt`(cmake_minimum_required 3.21, project, add_executable) +
  `CMakePresets.json`(debug/release 프리셋, `CMAKE_EXPORT_COMPILE_COMMANDS=ON`) +
  `vcpkg.json`(dependencies: drogon, gtest, sqlite3 등) +
  `src/main.cpp`(최소 Drogon 또는 cpp-httplib 핸들러) +
  `.clang-format`(BasedOnStyle: Google 또는 LLVM) +
  `Procfile.dev`(`web: ./build/debug/{{PROJECT_NAME}}` + worker 주석 예시).

### .env.{local,dev,staging,prod}
`environments` 매트릭스대로:
- local → `DATABASE_URL=sqlite:///./local.db`, compose 불필요 항목 주석
- dev/staging/prod → `DATABASE_URL=postgres://...`, `REDIS_URL=...`
- 비밀값은 placeholder + "Vault/Secret Manager 로 주입" 주석. 실제 시크릿 절대 미포함.
- `.env.prod` 은 값 대신 키 목록만(주입 전제).

### GitHub Actions (`.github/workflows/ci.yml`)
단계: checkout → setup(언어별) → install → lint → test → build(docker). 단일 파이프라인(원본 §3).

### test/ 시험 골격 / test scaffold (항상 생성 / always)
**test-runner 스킬 표준**을 따른다 / follow the test-runner standard. 항상 다음을 생성:
```
test/
├── README.md          # 시험 표준 요약 / testing standard overview
└── dev-env/
    ├── scenario.md    # 표준 환경 검증 시나리오 / env verification scenario
    └── logs/.gitkeep
```

> **모든 테스트는 `test/` 하나로 통일 / all tests under a single `test/`.**
> 언어별 유닛/소스 테스트도 `tests/` 가 아니라 **`test/`** 하위에 둔다(예: pytest `test/test_*.py`,
> GTest `test/unit/`, xUnit `test/Api.Tests/`). `tests/`(복수형) 디렉터리는 **생성 금지** — 시험표준
> `test/dev-env`·`test/impl` 과 한 트리에서 공존한다. 테스트 러너는 `test/` 를 탐색하도록 설정
> (pytest `testpaths=["test"]`, CMake `add_subdirectory(test/unit)`, .sln 은 `test/` 경로).
> 예외: 프레임워크가 디렉터리명을 강제하는 경우만 유지 — RN `__tests__/`, iOS `AppTests/`,
> Android `app/src/test`, Go/Rust in-package `_test.go`/`#[cfg(test)]`.
- `test/dev-env/scenario.md` 는 프로파일 기준 케이스로 채운다: 의존성 설치, `make up`, DB 연결,
  헬스 체크, `make test` 동작. Fill with profile-based cases (deps, compose up, DB, health, make test).
- `test/impl/` 는 비워 둔다(구현 시 `/wise-dev-std:implement` 가 `<Nth>/` 생성).
  Leave `test/impl/` empty; `implement` creates `<Nth>/` per iteration.
- `.gitignore` 에 `test/**/logs/` 를 추가하도록 안내(원본 로그 비커밋) / suggest ignoring raw logs.

### 도메인 오버레이 → `COMPLIANCE.md` (업종 지정 시 / when a domain is chosen)
`domains/<domain-id>.yaml` 가 지정되면 `COMPLIANCE.md` 를 생성한다. 구성:
```
# COMPLIANCE — <domain title> (KSIC <section>)
> 자동 생성. 근거: domains/<id>.yaml + .doc KSIC 통합표. 규제는 변하므로 references 로 재확인.

## 분류 / Classification    : KSIC <section> · ISIC/NACE/NAICS 병기
## 한국 규제 (1순위)         : korea_regulations (name · since · impact) 표
## 국제 기준                 : global_compliance 목록
## 데이터 등급              : data_classes (name/level/note) 표 — 규제대상은 비프로드 반입 금지 명시
## 인프라 패턴              : infra_patterns + stack_overrides
## 개발환경 특수 요구       : dev_env_special (마스킹/샌드박스/감사 등)
## 추가 시험 (test/ 반영)   : testing_additions
## 출처 / References        : references (URL)
```
- `data_classes` 중 `level: 규제대상` 항목은 **"비-프로덕션(dev/staging/test)에 실데이터 반입 금지"** 를 명시.
- `dev_env_special`·`testing_additions` 는 `test/dev-env/scenario.md` 와 향후 `test/impl/<Nth>/` 케이스로 연결.
- compose 스텁: `stack_overrides` 의 messaging/timeseries/geospatial/vector 등을 주석 처리된 서비스로 추가.

### 도메인/보안 (bio-rag-research 프로파일)
`security_standards` 와 `index_metadata_min_fields` 를 `SECURITY.md` 로 출력(COMPLIANCE.md 와 별개·보완).
RAG 서비스 디렉터리에 인덱싱 메타데이터 스키마 스텁(JSON/py) 포함.
RAG 시험은 Ragas groundedness/recall 케이스를 `test/` 에 포함 / include RAG eval cases.

## 2.5 모바일 (kind: mobile) — compose/Dockerfile/DB 대신 이 규칙

프로파일 `kind: mobile` 이면 §2 의 **docker-compose / Dockerfile / 서버 DB(postgres) / `up`·`down` 타겟은 생성하지 않는다**.
대신 앱 빌드·실행·배포·플레이버 구조를 만든다.

### Makefile (모바일 타겟)
`makefile_targets` 를 그대로 타겟으로. compose 대신:
```makefile
.PHONY: dev test build deploy
ENV ?= local
dev:    ; <run_methods.simulator>      # 시뮬레이터/에뮬레이터 실행
test:   ; <makefile_targets.test>      # flutter test / xcodebuild test / gradlew test / jest
build:  ; <makefile_targets.build>     # ipa / aab / eas build
deploy: ; <makefile_targets.deploy>    # fastlane → TestFlight / Play
```
플랫폼별 보조 타겟 추가 가능: `ios:`(`run_methods.ios`), `android:`(`run_methods.android`).

### 플랫폼 프로젝트 레이아웃 + 매니페스트 (언어별)
`scaffold.tree`/`files` 대로 생성하되 언어 매니페스트는:
- **Flutter**: `pubspec.yaml`(name/deps: flutter, go_router, riverpod, dio, drift) + `lib/main.dart`(중앙정렬 `Text` 스텁) + `lib/core/env.dart`(flavor→`api_base` 매핑).
- **React Native(Expo)**: `package.json`(expo, expo-router, zustand, @tanstack/react-query) + `app.json`(expo, scheme, ios/android) + `tsconfig.json` + `src/core/env.ts`(flavor→`api_base`).
- **iOS(SwiftUI)**: `Package.swift`(또는 .xcodeproj 안내) + `App/Sources/App.swift`(@main) + `ContentView.swift`(중앙정렬 `Text`) + `Core/Env.swift` + `Config/{Debug,Release}.xcconfig`(API base/서명).
- **Android(Compose)**: `settings.gradle.kts` + 루트/`app/build.gradle.kts`(compose BOM, productFlavors: dev/staging/prod) + `gradle/libs.versions.toml`(Version Catalog) + `MainActivity.kt`(중앙정렬 `Text`).

### 빌드 플레이버 / 환경 (env-init 와 연동)
`environments`(local/dev/staging/prod)는 **DB/compose 가 아니라 flavor + `api_base` + `signing`**:
- Flutter: `lib/core/env.dart` 의 `--dart-define` 또는 flavor 분기 + `.env.local`(API base).
- RN: `src/core/env.ts` + `app.json`/EAS `eas.json` profile(development/preview/production).
- iOS: `Config/*.xcconfig`(스킴별 `API_BASE_URL`) — 실서명/프로비저닝은 placeholder + match 안내.
- Android: `app/build.gradle.kts` 의 `productFlavors { dev/staging/prod }` + `buildConfigField("API_BASE_URL")`.
- **실서명 자격(키스토어/.p12/.mobileprovision/ASC 키)·실 API 키는 절대 생성/커밋 금지** — placeholder + CI 시크릿/Vault/match 주입 주석만.

### Fastlane (`fastlane/Fastfile`) — 배포 스텁
TestFlight/Play 배포 lane 스켈레톤을 생성(실행 아님). 예:
```ruby
# iOS:    lane :beta  → gym(build) → pilot(TestFlight)
# Android: lane :beta → gradle(bundleRelease) → supply(Play internal)
```
근거: `.ref-doc` "Cli로 ios app을 testflight 배포". 시크릿은 ENV/CI 주입 전제 주석만.

### CI (`.github/workflows/ci.yml`)
- iOS/네이티브 빌드는 **`runs-on: macos-latest`**. Android 단독은 ubuntu 가능.
- 단계: checkout → SDK 셋업(flutter/xcode/jdk+android-sdk/node+expo) → install → lint/analyze → test → build(미서명/디버그). 배포 lane 은 태그/수동 트리거 주석으로.

### gitignore
`languages.primary` → `templates/gitignore/{swift,android,flutter,react-native}.gitignore`(매핑: swift→swift, kotlin→android, dart→flutter, node(RN)→react-native + `_common`). 병합은 §2.7 규칙으로 **스캐폴딩 시점에 수행**하고, `/implement` 는 누락 섹션만 멱등 보강한다.

### test/ 골격
§2 와 동일하게 `test/README.md` + `test/dev-env/{scenario.md,logs/.gitkeep}` 생성. 단 **dev-env 시나리오는 모바일 기준**:
SDK/툴체인 확인(flutter doctor / xcodebuild -version / sdkmanager / expo --version) → 시뮬레이터·에뮬레이터 부팅 → 디버그 빌드 성공 → `make test` 동작. (DB 연결·compose up 케이스는 제외.)
프로파일 `test/`(Flutter `test/`, RN `__tests__/`, iOS `AppTests/`, Android `app/src/test`)와 시험표준 `test/dev-env`·`test/impl` 은 공존한다.

## 2.7 `.gitignore` 조립 (멱등) — 단일 규칙 / canonical rule

스캐폴딩 시점에 생성하고, `/implement` 는 누락 섹션만 보강한다. scaffold·implement 모두 이 규칙을 따른다.

- **언어 결정**: 프로파일 `languages.primary` + `languages.also`
  (예: node-next-nest→node; python-fastapi→python; bio-rag-research→python+node+go+rust).
  모바일 매핑: ios-swiftui→`swift`, android-compose→`android`, flutter-app→`flutter`,
  react-native-app→`react-native`+`node`.
- **조립 순서**: `templates/gitignore/_common.gitignore` → `_platform.gitignore`(macOS·Windows·Linux 모두)
  → 언어별 `templates/gitignore/<lang>.gitignore`(`node|python|go|rust|c-cpp|swift|android|flutter|react-native`).
  셸에서는 `templates/gitignore/_combine.sh <lang...>` 사용 가능.
- **멱등**: 각 프래그먼트의 헤더 라인(`# ===== ... =====`)을 센티넬로 사용.
  `.gitignore` 없으면 생성, 있으면 **누락 섹션만 추가** — 기존 사용자 항목 보존, 삭제·재정렬 금지.
- **보고**: 추가한 섹션 목록.
- `test/**/logs/` 포함(원본 로그 비커밋).

## 3. 멀티 IDE 준용
스캐폴딩 직후, 사용자가 원하면 `/wise-dev-std:standardize` 를 안내해
표준을 `AGENTS.md` + IDE별 규칙 파일로 내보낸다
(Cursor·Windsurf·Copilot·Gemini·Cline·Roo·Antigravity — standardize 커맨드 참조).

## 4. 안전 규칙
- 네트워크/설치 명령 실행 금지(파일 생성만). 설치는 사용자가 `make dev`/`uv sync`/`pnpm i` 로.
- 절대 실제 자격증명·토큰 생성 금지.
- 기존 파일은 보존(2.6 항). 큰 변경 전 트리 미리보기 제시.
