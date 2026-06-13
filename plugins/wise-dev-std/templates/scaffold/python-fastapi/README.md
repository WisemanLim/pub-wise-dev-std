# {{PROJECT_NAME}}

Python + FastAPI 기반 REST API 서비스.

> **스캐폴딩 정보**: `wise-dev-std` 플러그인 / 프로파일 `python-fastapi` 으로 생성됨.

## 기술 스택

| 구분 | 도구 |
|------|------|
| 언어 | Python 3.12+ |
| 프레임워크 | [FastAPI](https://fastapi.tiangolo.com/) |
| 패키지 매니저 | [uv](https://docs.astral.sh/uv/) |
| DB | PostgreSQL 17 (Alpine) |
| 캐시 | Redis 7.4 (Alpine) |
| 컨테이너 | Docker / Docker Compose v2 |
| 배포 | Helm 3 (Kubernetes) |
| CI/CD | GitHub Actions |

## 사전 요구사항

- Python 3.12+
- [uv](https://docs.astral.sh/uv/getting-started/installation/) (`curl -LsSf https://astral.sh/uv/install.sh | sh`)
- Docker Desktop (또는 Docker Engine + Compose plugin)
- GNU Make

## 빠른 시작

```bash
# 1. 가상환경 및 의존성 설치
uv sync

# 2. 환경 변수 파일 복사
cp .env.local .env

# 3. 인프라 기동 (Postgres :5432 + Redis :6379)
make up

# 4. 개발 서버 실행 (hot-reload)
make dev
# → http://localhost:8000
# → Swagger UI: http://localhost:8000/docs
# → ReDoc:      http://localhost:8000/redoc
```

## Make 사용법

```
make <target> [ENV=<env>]
```

| 명령 | 설명 |
|------|------|
| `make up` | PostgreSQL + Redis 컨테이너 기동 |
| `make down` | 전체 컨테이너 종료 및 정리 |
| `make dev` | 단일 개발 서버, 포그라운드 (`uv run uvicorn app.main:app --reload`) |
| `make run` | **honcho** 로 web(+worker) 동시 기동 (`Procfile.dev`) |
| `make ps` | Procfile 검증 (`honcho check`) |
| `make test` | pytest 실행 (`uv run pytest`) |
| `make build` | Docker 앱 이미지 빌드 (`--profile app`) |
| `make deploy` | Helm 으로 Kubernetes 배포 |

### 로컬 멀티프로세스 (honcho)

web(uvicorn) 외에 워커(arq/celery/rq 등)를 함께 띄울 때 사용. `Procfile.dev` 의 `web:`/`worker:` 줄로 정의.
honcho 는 dev 의존성(`uv sync` 시 설치). 포그라운드로 통합 로그 출력, **Ctrl-C 로 전체 종료**(데몬 아님).

```bash
make run      # Procfile.dev 의 전체 프로세스 기동
# worker 추가: Procfile.dev 의 'worker:' 줄 주석 해제
```

### 환경 오버라이드

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
make dev   # --reload 로 코드 변경 자동 반영
```

### 테스트

```bash
make test
# 커버리지 포함:
uv run pytest --cov=app --cov-report=html
```

### DB 마이그레이션 (Alembic)

```bash
uv run alembic upgrade head         # 마이그레이션 적용
uv run alembic revision --autogenerate -m "add users table"
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
make deploy
# 또는:
helm upgrade --install {{PROJECT_NAME}} ./deploy/helm \
  --set image.tag=$(git rev-parse --short HEAD)
```

## 디렉터리 구조

```
{{PROJECT_NAME}}/
├── app/
│   ├── main.py          # FastAPI 진입점
│   ├── api/             # 라우터
│   ├── services/        # 비즈니스 로직
│   ├── models/          # SQLAlchemy 모델
│   └── schemas/         # Pydantic 스키마
├── tests/
├── deploy/helm/         # Helm 차트
├── .github/workflows/   # CI 파이프라인
├── docker-compose.yml   # 개발 인프라
├── Dockerfile           # 멀티스테이지 빌드
├── pyproject.toml       # uv 의존성 관리
└── Makefile
```
