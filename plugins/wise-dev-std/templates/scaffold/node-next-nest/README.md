# {{PROJECT_NAME}}

Next.js (Web) + NestJS (API) pnpm 모노레포 서비스.

> **스캐폴딩 정보**: `wise-dev-std` 플러그인 / 프로파일 `node-next-nest` 으로 생성됨.

## 기술 스택

| 구분 | 도구 |
|------|------|
| 언어 | TypeScript / Node.js 22+ |
| 프론트엔드 | [Next.js 15](https://nextjs.org/) (App Router) |
| 백엔드 | [NestJS 11](https://nestjs.com/) |
| 패키지 매니저 | [pnpm 9](https://pnpm.io/) (워크스페이스) |
| DB | PostgreSQL 17 (Alpine) |
| 캐시 | Redis 7.4 (Alpine) |
| 컨테이너 | Docker / Docker Compose v2 |
| 배포 | Helm 3 (Kubernetes) |
| CI/CD | GitHub Actions |

## 사전 요구사항

- Node.js 22+
- pnpm 9+ (`npm i -g pnpm`)
- Docker Desktop (또는 Docker Engine + Compose plugin)
- GNU Make

## 빠른 시작

```bash
# 1. 의존성 설치
pnpm install

# 2. 환경 변수 파일 복사
cp .env.local .env

# 3. 인프라 기동 (Postgres :5432 + Redis :6379)
make up

# 4. 전체 워크스페이스 개발 서버 실행
make dev
# → Next.js: http://localhost:3000
# → NestJS:  http://localhost:4000
```

> **참고**: `docker-compose.yml` 은 인프라(Postgres/Redis)만 정의합니다.  
> 앱(web/api)은 호스트에서 직접 실행하는 것을 권장합니다(pnpm 워크스페이스 lockfile 공유).

## Make 사용법

```
make <target> [ENV=<env>]
```

| 명령 | 설명 |
|------|------|
| `make up` | PostgreSQL + Redis 컨테이너 기동 |
| `make down` | 전체 컨테이너 종료 및 정리 |
| `make dev` | 전체 워크스페이스 개발 서버 실행, 포그라운드 (`pnpm -r dev`) |
| `make run` | **PM2** 로 web+api 데몬 기동 (`pm2 start ecosystem.config.cjs`) |
| `make stop` | PM2 프로세스 중지·삭제 |
| `make restart` | PM2 프로세스 재시작 |
| `make logs` | PM2 통합 로그 추적 |
| `make ps` | PM2 프로세스 상태 (`pm2 ls`) |
| `make test` | 전체 워크스페이스 테스트 실행 (`pnpm -r test`) |
| `make build` | 전체 워크스페이스 빌드 (`pnpm -r build`) |
| `make deploy` | Helm 으로 Kubernetes 배포 |

### 로컬 멀티프로세스 (PM2)

호스트 직접 실행 시 web(Next)+api(Nest)를 한 번에 관리. `ecosystem.config.cjs` 에 앱 정의(워커 추가 가능).
PM2 는 `devDependencies` 에 포함되어 `pnpm install` 후 바로 사용. 베어메탈 prod 기동에도 동일 설정 재사용.

```bash
make run      # 데몬 기동 (백그라운드)
make logs     # 로그 추적
make ps       # 상태
make stop     # 중지
```

### 특정 앱만 실행

```bash
pnpm --filter web dev        # Next.js 만
pnpm --filter api dev        # NestJS 만
pnpm --filter api test:e2e   # e2e 테스트
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

## 빌드 & 배포

### 로컬 빌드

```bash
make build
# 개별 앱:
pnpm --filter web build
pnpm --filter api build
```

### Docker 프로덕션 빌드

```bash
# 루트 컨텍스트에서 멀티스테이지 빌드 (별도 Dockerfile 구성 필요):
docker build -f apps/api/Dockerfile -t {{PROJECT_NAME}}-api .
docker build -f apps/web/Dockerfile -t {{PROJECT_NAME}}-web .
```

### Kubernetes (Helm)

```bash
make deploy
# 또는:
helm upgrade --install {{PROJECT_NAME}} ./deploy/helm \
  --set api.image.tag=$(git rev-parse --short HEAD) \
  --set web.image.tag=$(git rev-parse --short HEAD)
```

## 디렉터리 구조

```
{{PROJECT_NAME}}/
├── apps/
│   ├── web/             # Next.js 15 (App Router)
│   └── api/             # NestJS 11
├── packages/            # 공유 라이브러리 (types, ui 등)
├── deploy/helm/         # Helm 차트
├── .github/workflows/   # CI 파이프라인
├── docker-compose.yml   # 개발 인프라 (Postgres/Redis)
├── pnpm-workspace.yaml
├── package.json         # 루트 스크립트
└── Makefile
```
