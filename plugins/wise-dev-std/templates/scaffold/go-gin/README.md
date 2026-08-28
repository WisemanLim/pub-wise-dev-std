# {{PROJECT_NAME}}

Go + Gin 기반 REST API 서비스.

> **스캐폴딩 정보**: `wise-dev-std` 플러그인 / 프로파일 `go-gin` 으로 생성됨.

## 기술 스택

| 구분 | 도구 |
|------|------|
| 언어 | Go 1.23+ |
| 프레임워크 | [gin-gonic/gin](https://github.com/gin-gonic/gin) |
| DB | PostgreSQL 17 (Alpine) |
| 캐시 | Redis 7.4 (Alpine) |
| 컨테이너 | Docker / Docker Compose v2 |
| 배포 | Helm 3 (Kubernetes) |
| CI/CD | GitHub Actions |

## 사전 요구사항

- Go 1.23+
- Docker Desktop (또는 Docker Engine + Compose plugin)
- GNU Make
- Helm 3+ _(배포 시)_

## 빠른 시작

```bash
# 1. 환경 변수 파일 복사
cp .env.local .env

# 2. 의존성 설치/빌드 + 인프라(Postgres :5432 + Redis :6379) + 호스트 프로세스 일괄 기동 (백그라운드)
make local-build && make local-all

# 3. 로그 추적 (Ctrl-C 는 tail 만 종료 · 직접 실행은 `go run ./cmd/server`)
make local-logs
# → http://localhost:8080
```

## Make 사용법

```
make <target> [ENV=<env>]
```

| 명령 | 설명 |
|------|------|
| `make preflight` | 런타임·도구 버전 호환성 점검 |
| `make test` | 테스트 실행 (`go test ./...`) |
| `make deploy` | Helm 으로 Kubernetes 배포 |
| `make help` | 타겟 목록 |
| `make local-build` | [local] 의존성 설치/호스트 빌드 (`go mod download && go build ./...`) |
| `make local-all` | [local] infra(docker) + **goreman** 호스트 프로세스 일괄 기동 (백그라운드) |
| `make local-logs` | [local] 통합 로그 추적 (Ctrl-C 로 tail 종료, 프로세스는 유지) |
| `make local-stop` | [local] 호스트 프로세스 중지 + infra 정리 |
| `make local-restart` | [local] 호스트 프로세스 재기동 (infra 유지) |
| `make local-ps` | [local] 프로세스 상태 (`goreman run status`) |
| `make <env>-all` | [dev\|staging\|prod] infra + app 컨테이너 기동 (`docker compose --env-file .env.<env> --profile app`) |
| `make <env>-build` | [dev\|staging] 이미지 재빌드 후 기동 (prod 미제공 — CI/CD 산출물) |
| `make <env>-logs` | [dev\|staging\|prod] 컨테이너 로그 추적 (`SVC=`로 특정 서비스) |
| `make <env>-stop` | [dev\|staging\|prod] app + infra 전체 정리 |
| `make <env>-restart` | [dev\|staging\|prod] 컨테이너 재기동 (`SVC=`로 특정 서비스) |
| `make <env>-ps` | [dev\|staging\|prod] 컨테이너 상태 |
| `make db-migrate [ENV=<env>]` | 마이그레이션 적용 (기본 `go run ./cmd/migrate up`, `MIGRATE="..."` 로 교체) |
| `make db-seed [ENV=<env>]` | 시드 데이터 적재 (기본 `go run ./cmd/seed`, `SEED="..."` 로 교체) |
| `make db-reset [ENV=<env>]` | DB 초기화 + 마이그레이션 (local=SQLite 파일 삭제 · 그 외=postgres `schema public` 재생성 · prod 거부) |
| `make db-fresh [ENV=<env>]` | `db-reset` + `db-seed` (예: `make db-fresh ENV=dev`) |

### 로컬 멀티프로세스 (goreman)

server 외에 큐 소비자/재색인 워커를 함께 띄울 때 사용. `Procfile.dev` 의 `web:`/`worker:` 줄로 정의.
사전 설치 필요(1회): `go install github.com/mattn/goreman@latest`. goreman 은 **백그라운드 데몬화**
(nohup+pidfile, `.make/goreman.pid`)되어 `local-logs`/`local-stop`/`local-restart` 로 제어한다.

```bash
go install github.com/mattn/goreman@latest   # 1회
make local-all      # infra + goreman 백그라운드 기동
make local-logs      # 통합 로그 추적
make local-stop      # 전체 종료
```

`ENV` 변수로 환경별 설정 파일 선택:

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
make local-all    # infra + 호스트 프로세스 백그라운드 기동 (직접 실행: `go run ./cmd/server`)
make local-logs   # 로그 추적
```

### 테스트

```bash
make test
# 커버리지 포함:
go test -race -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

## 빌드 & 배포

### Docker 이미지 빌드

```bash
make staging-build   # .env.staging 기반 이미지 재빌드 + 전체 스택 기동
make staging-logs
```

### Kubernetes (Helm)

```bash
# values 수정 후:
make deploy
# 또는:
helm upgrade --install {{PROJECT_NAME}} ./deploy/helm \
  --set image.tag=$(git rev-parse --short HEAD)
```

## 디렉터리 구조

```
{{PROJECT_NAME}}/
├── cmd/server/          # 진입점 (main.go)
├── internal/            # 도메인 로직
│   ├── handler/
│   ├── service/
│   └── repository/
├── deploy/helm/         # Helm 차트
├── .github/workflows/   # CI 파이프라인
├── docker-compose.yml   # 개발 인프라
├── Dockerfile           # 멀티스테이지 빌드
└── Makefile
```
