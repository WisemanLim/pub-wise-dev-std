# {{PROJECT_NAME}}

Rust + Axum 기반 REST API 서비스.

> **스캐폴딩 정보**: `wise-dev-std` 플러그인 / 프로파일 `rust-axum` 으로 생성됨.

## 기술 스택

| 구분 | 도구 |
|------|------|
| 언어 | Rust (stable, 최신) |
| 프레임워크 | [Axum](https://github.com/tokio-rs/axum) |
| 비동기 런타임 | [Tokio](https://tokio.rs/) |
| DB | PostgreSQL 17 (Alpine) |
| 캐시 | Redis 7.4 (Alpine) |
| 컨테이너 | Docker / Docker Compose v2 |
| 배포 | Helm 3 (Kubernetes) |
| CI/CD | GitHub Actions |

## 사전 요구사항

- Rust (stable) — [rustup](https://rustup.rs/) 으로 설치
- Docker Desktop (또는 Docker Engine + Compose plugin)
- GNU Make
- Helm 3+ _(배포 시)_

```bash
# Rust 설치
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup update stable
```

## 빠른 시작

```bash
# 1. 환경 변수 파일 복사
cp .env.local .env

# 2. 의존성 설치/빌드 + 인프라(Postgres :5432 + Redis :6379) + 호스트 프로세스 일괄 기동 (백그라운드)
make local-build && make local-all

# 3. 로그 추적 (Ctrl-C 는 tail 만 종료 · 직접 실행은 `cargo run`)
make local-logs
# → http://localhost:3000
```

## Make 사용법

```
make <target> [ENV=<env>]
```

| 명령 | 설명 |
|------|------|
| `make preflight` | 런타임·도구 버전 호환성 점검 |
| `make test` | 테스트 실행 (`cargo test`) |
| `make deploy` | Helm 으로 Kubernetes 배포 |
| `make help` | 타겟 목록 |
| `make local-build` | [local] 의존성 설치/호스트 빌드 (`cargo build`) |
| `make local-all` | [local] infra(docker) + **overmind** 호스트 프로세스 일괄 기동 (백그라운드) |
| `make local-logs` | [local] 통합 로그 추적 (Ctrl-C 로 tail 종료, 프로세스는 유지) |
| `make local-stop` | [local] 호스트 프로세스 중지 + infra 정리 |
| `make local-restart` | [local] 호스트 프로세스 재기동 (infra 유지) |
| `make local-ps` | [local] 프로세스 상태 (`overmind ps`) |
| `make <env>-all` | [dev\|staging\|prod] infra + app 컨테이너 기동 (`docker compose --env-file .env.<env> --profile app`) |
| `make <env>-build` | [dev\|staging] 이미지 재빌드 후 기동 (prod 미제공 — CI/CD 산출물) |
| `make <env>-logs` | [dev\|staging\|prod] 컨테이너 로그 추적 (`SVC=`로 특정 서비스) |
| `make <env>-stop` | [dev\|staging\|prod] app + infra 전체 정리 |
| `make <env>-restart` | [dev\|staging\|prod] 컨테이너 재기동 (`SVC=`로 특정 서비스) |
| `make <env>-ps` | [dev\|staging\|prod] 컨테이너 상태 |
| `make db-migrate [ENV=<env>]` | 마이그레이션 적용 (기본 `sqlx migrate run`, `MIGRATE="..."` 로 교체) |
| `make db-seed [ENV=<env>]` | 시드 데이터 적재 (기본 `cargo run --bin seed`, `SEED="..."` 로 교체) |
| `make db-reset [ENV=<env>]` | DB 초기화 + 마이그레이션 (local=SQLite 파일 삭제 · 그 외=postgres `schema public` 재생성 · prod 거부) |
| `make db-fresh [ENV=<env>]` | `db-reset` + `db-seed` (예: `make db-fresh ENV=dev`) |

### 로컬 멀티프로세스 (overmind + cargo-watch)

server 외에 대량 문서 처리/재색인 워커를 함께 띄울 때 사용. `Procfile.dev` 의 `web:`/`worker:` 줄로 정의하며
`cargo watch -x run` 으로 코드 변경 시 자동 재빌드. overmind 는 **백그라운드 데몬화**(nohup+pidfile,
`.make/overmind.pid`)되어 `local-logs`/`local-stop`/`local-restart` 로 제어한다. 사전 설치 필요(1회):

```bash
cargo install cargo-watch
brew install overmind tmux        # 또는 go install github.com/DarthSim/overmind@latest
make local-all      # infra + overmind 백그라운드 기동
make local-logs      # 통합 로그 추적
make local-stop      # 전체 종료
```

> tmux 가 없으면 `hivemind Procfile.dev` 로 대체(제어 소켓 없음).

### 환경 오버라이드

```bash
make dev-build               # .env.dev 기반 이미지 재빌드 + 기동 (dev|staging 만)
make dev-all                  # .env.dev 기반 app+infra 전체 스택
make staging-all               # .env.staging 기반 app+infra 전체 스택
```

## 환경 변수

| 파일 | 용도 |
|------|------|
| `.env.local` | 로컬 개발 (Git 제외 권장) |
| `.env.dev` | 개발 서버 |
| `.env.staging` | 스테이징 |
| `.env.prod` | 프로덕션 (시크릿은 CI/Vault 관리) |

주요 변수:

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `POSTGRES_USER` | `app` | DB 사용자 |
| `POSTGRES_PASSWORD` | `app` | DB 비밀번호 |
| `POSTGRES_DB` | `app` | DB 이름 |
| `DATABASE_URL` | — | 전체 연결 문자열 |

> **주의**: 실제 시크릿은 `.env.prod` 에 커밋하지 마세요.

## 실행 방법

### 로컬 개발

```bash
make local-all    # infra + 호스트 프로세스 백그라운드 기동 (직접 실행: `cargo run`)
make local-logs   # 로그 추적

# cargo-watch 설치 후:
cargo install cargo-watch
cargo watch -x run
```

### 테스트

```bash
make test
# 자세한 출력:
cargo test -- --nocapture
# 특정 테스트:
cargo test test_name
```

### 린트 & 포맷

```bash
cargo fmt
cargo clippy -- -D warnings
```

## 빌드 & 배포

### Docker 이미지 빌드

```bash
make staging-build   # .env.staging 기반 이미지 재빌드 + 전체 스택 기동
make staging-logs
```

> **참고**: Rust 멀티스테이지 빌드는 `cargo-chef` 를 사용해 레이어 캐시를 최적화합니다.

### Kubernetes (Helm)

```bash
make deploy
# 또는:
helm upgrade --install {{PROJECT_NAME}} ./deploy/helm \
  --set image.tag=$(git rev-parse --short HEAD)
```

## 디렉터리 구조

```
{{PROJECT_NAME}}/
├── src/
│   ├── main.rs          # 진입점
│   ├── routes/          # Axum 라우터
│   ├── handlers/        # 요청 핸들러
│   ├── services/        # 비즈니스 로직
│   └── models/          # 도메인 모델
├── deploy/helm/         # Helm 차트
├── .github/workflows/   # CI 파이프라인
├── docker-compose.yml   # 개발 인프라
├── Dockerfile           # 멀티스테이지 빌드 (cargo-chef)
├── Cargo.toml
└── Makefile
```
