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

# 3. 의존성 설치/빌드 + 인프라(Postgres :5432 + Redis :6379) + 호스트 프로세스 일괄 기동 (백그라운드)
make local-build && make local-all

# 4. 로그 추적 (Ctrl-C 는 tail 만 종료 · 직접 실행은 `pnpm -r dev`)
make local-logs
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
| `make preflight` | 런타임·도구 버전 호환성 점검 |
| `make test` | 테스트 실행 (`pnpm -r test`) |
| `make deploy` | Helm 으로 Kubernetes 배포 |
| `make help` | 타겟 목록 |
| `make local-build` | [local] 의존성 설치/호스트 빌드 (`pnpm install && pnpm -r build`) |
| `make local-all` | [local] infra(docker) + **PM2** 호스트 프로세스 일괄 기동 (백그라운드) |
| `make local-logs` | [local] 통합 로그 추적 (Ctrl-C 로 tail 종료, 프로세스는 유지) |
| `make local-stop` | [local] 호스트 프로세스 중지 + infra 정리 |
| `make local-restart` | [local] 호스트 프로세스 재기동 (infra 유지) |
| `make local-ps` | [local] 프로세스 상태 (`pm2 ls`) |
| `make <env>-all` | [dev\|staging\|prod] infra + app 컨테이너 기동 (`docker compose --env-file .env.<env> --profile app`) |
| `make <env>-build` | [dev\|staging] 이미지 재빌드 후 기동 (prod 미제공 — CI/CD 산출물) |
| `make <env>-logs` | [dev\|staging\|prod] 컨테이너 로그 추적 (`SVC=`로 특정 서비스) |
| `make <env>-stop` | [dev\|staging\|prod] app + infra 전체 정리 |
| `make <env>-restart` | [dev\|staging\|prod] 컨테이너 재기동 (`SVC=`로 특정 서비스) |
| `make <env>-ps` | [dev\|staging\|prod] 컨테이너 상태 |
| `make db-migrate [ENV=<env>]` | 마이그레이션 적용 (기본 `pnpm -C apps/api exec prisma migrate deploy`, `MIGRATE="..."` 로 교체) |
| `make db-seed [ENV=<env>]` | 시드 데이터 적재 (기본 `pnpm -C apps/api exec prisma db seed`, `SEED="..."` 로 교체) |
| `make db-reset [ENV=<env>]` | DB 초기화 + 마이그레이션 (local=SQLite 파일 삭제 · 그 외=postgres `schema public` 재생성 · prod 거부) |
| `make db-fresh [ENV=<env>]` | `db-reset` + `db-seed` (예: `make db-fresh ENV=dev`) |

### 로컬 멀티프로세스 (PM2)

호스트 직접 실행 시 web(Next)+api(Nest)를 한 번에 관리. `ecosystem.config.cjs` 에 앱 정의(워커 추가 가능).
PM2 는 `devDependencies` 에 포함되어 `pnpm install` 후 바로 사용, **백그라운드 데몬**으로 기동되어
`local-logs`/`local-stop`/`local-restart` 로 제어한다. 베어메탈 prod 기동에도 동일 설정 재사용.

```bash
make local-all      # infra + PM2 백그라운드 기동
make local-logs      # 통합 로그 추적
make local-stop      # 전체 종료
make local-ps        # 상태
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
make local-build
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
