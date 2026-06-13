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

# 2. 인프라 기동 (Postgres :5432 + Redis :6379)
make up

# 3. 개발 서버 실행
make dev
# → http://localhost:8080
```

## Make 사용법

```
make <target> [ENV=<env>]
```

| 명령 | 설명 |
|------|------|
| `make up` | PostgreSQL + Redis 컨테이너 기동 |
| `make down` | 전체 컨테이너 종료 및 정리 |
| `make dev` | 단일 로컬 개발 서버 (`go run ./cmd/server`) |
| `make run` | **goreman** 으로 server(+worker) 동시 기동 (`Procfile.dev`) |
| `make stop` | 전체 중지 (`goreman run stop-all`, 별도 터미널) |
| `make restart` | 전체 재시작 (`goreman run restart-all`) |
| `make ps` | 프로세스 상태 (`goreman run status`) |
| `make test` | 전체 테스트 실행 (`go test ./...`) |
| `make build` | Docker 앱 이미지 빌드 (`--profile app`) |
| `make deploy` | Helm 으로 Kubernetes 배포 |

### 로컬 멀티프로세스 (goreman)

server 외에 큐 소비자/재색인 워커를 함께 띄울 때 사용. `Procfile.dev` 의 `web:`/`worker:` 줄로 정의.
사전 설치 필요(1회): `go install github.com/mattn/goreman@latest`.
`make run` 은 포그라운드 통합 로그, 별도 터미널에서 `goreman run status/restart-all` 로 제어.

```bash
go install github.com/mattn/goreman@latest   # 1회
make run                                      # 전체 기동
```

`ENV` 변수로 환경별 설정 파일 선택:

```bash
make up ENV=dev         # .env.dev 사용
make build ENV=staging  # .env.staging 사용
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
make up    # 인프라 기동
make dev   # 코드 변경 시 재시작 (air 사용 권장: air init && air)
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
ENV=staging make build
# 빌드 후 컨테이너 실행:
docker compose --profile app up
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
