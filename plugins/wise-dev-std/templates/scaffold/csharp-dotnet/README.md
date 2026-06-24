# {{PROJECT_NAME}}

C# / ASP.NET Core 8 Web API 서비스.

> **스캐폴딩 정보**: `wise-dev-std` 플러그인 / 프로파일 `csharp-dotnet` 으로 생성됨.

## 기술 스택

| 구분 | 도구 |
|------|------|
| 언어 | C# 12 / .NET 8 LTS |
| 프레임워크 | [ASP.NET Core 8 Web API](https://learn.microsoft.com/aspnet/core) |
| ORM | [Entity Framework Core 8](https://learn.microsoft.com/ef/core) (Npgsql) |
| DB | PostgreSQL 17 (Alpine) |
| 캐시 | Redis 7.4 (Alpine) |
| 컨테이너 | Docker / Docker Compose v2 |
| 배포 | Helm 3 (Kubernetes) |
| CI/CD | GitHub Actions |

## 사전 요구사항

- .NET SDK 8.0+
- Docker Desktop (또는 Docker Engine + Compose plugin)
- GNU Make
- goreman _(로컬 멀티프로세스 시)_ `go install github.com/mattn/goreman@latest`

## 빠른 시작

```bash
# 1. 환경 변수 파일 복사
cp .env.local .env

# 2. 인프라 기동 (Postgres :5432 + Redis :6379)
make up

# 3. 개발 서버 실행
make dev
# → http://localhost:8080
# → Swagger UI: http://localhost:8080/swagger
```

> **참고**: `docker-compose.yml` 은 인프라(Postgres/Redis)만 정의합니다.  
> 앱은 호스트에서 직접 실행하는 것을 권장합니다(`dotnet run`).

## Make 사용법

```
make <target> [ENV=<env>]
```

| 명령 | 설명 |
|------|------|
| `make up` | PostgreSQL + Redis 컨테이너 기동 |
| `make down` | 전체 컨테이너 종료 및 정리 |
| `make dev` | 단일 로컬 개발 서버 (`dotnet run --launch-profile Development`) |
| `make run` | **goreman** 으로 api(+worker) 동시 기동 (`Procfile.dev`) |
| `make stop` | 전체 중지 (`goreman run stop-all`, 별도 터미널) |
| `make test` | 전체 테스트 실행 (`dotnet test`) |
| `make build` | Docker 앱 이미지 빌드 (`--profile app`) |
| `make deploy` | Helm 으로 Kubernetes 배포 |

## 환경 변수

| 파일 | 용도 |
|------|------|
| `.env.local` | 로컬 개발 (Git 제외 권장) |
| `.env.dev` | 개발 서버 |
| `.env.staging` | 스테이징 |
| `.env.prod` | 프로덕션 (시크릿은 CI/Vault 관리) |

> **주의**: 실제 시크릿은 `.env.prod` 에 커밋하지 마세요.

## EF Core 마이그레이션

```bash
# 마이그레이션 추가
dotnet ef migrations add InitialCreate --project src/Api

# DB 적용
dotnet ef database update --project src/Api
```

## 빌드 & 배포

### Docker 이미지 빌드

```bash
ENV=staging make build
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
├── src/
│   ├── Api/                 # ASP.NET Core Web API 진입점
│   │   ├── Controllers/
│   │   ├── Program.cs
│   │   ├── Api.csproj
│   │   ├── appsettings.json
│   │   └── appsettings.Development.json
│   └── Core/                # 도메인 / 비즈니스 로직
├── tests/
│   └── Api.Tests/           # xUnit 통합 테스트
├── deploy/helm/             # Helm 차트
├── .github/workflows/       # CI 파이프라인
├── docker-compose.yml       # 개발 인프라 (Postgres/Redis)
├── Dockerfile               # 멀티스테이지 빌드
├── Procfile.dev             # goreman 로컬 멀티프로세스
└── Makefile
```
