# {{PROJECT_NAME}}

Java / Spring Boot 3 REST API 서비스.

> **스캐폴딩 정보**: `wise-dev-std` 플러그인 / 프로파일 `java-spring` 으로 생성됨.

## 기술 스택

| 구분 | 도구 |
|------|------|
| 언어 | Java 21 (LTS) |
| 프레임워크 | [Spring Boot 3.3](https://spring.io/projects/spring-boot) |
| ORM | Spring Data JPA (Hibernate + PostgreSQL) |
| 빌드 | [Gradle 8](https://gradle.org/) (Kotlin DSL) |
| DB | PostgreSQL 17 (Alpine) |
| 캐시 | Redis 7.4 (Alpine) |
| 컨테이너 | Docker / Docker Compose v2 |
| 배포 | Helm 3 (Kubernetes) |
| CI/CD | GitHub Actions |

## 사전 요구사항

- JDK 21+ (temurin 권장: `sdk install java 21-tem`)
- Docker Desktop (또는 Docker Engine + Compose plugin)
- GNU Make
- goreman _(로컬 멀티프로세스 시)_ `go install github.com/mattn/goreman@latest`

## 빠른 시작

```bash
# 1. 환경 변수 파일 복사
cp .env.local .env

# 2. 인프라 기동 (Postgres :5432 + Redis :6379)
make up

# 3. 개발 서버 실행 (H2 인메모리 DB, 외부 의존 없음)
make dev
# → http://localhost:8080
# → H2 Console: http://localhost:8080/h2-console (local 프로파일)
# → Actuator:   http://localhost:8080/actuator/health
```

> **참고**: `local` 프로파일은 H2 인메모리 DB 사용. Postgres 연결은 `dev` 프로파일.

## Make 사용법

```
make <target> [ENV=<env>]
```

| 명령 | 설명 |
|------|------|
| `make up` | PostgreSQL + Redis 컨테이너 기동 |
| `make down` | 전체 컨테이너 종료 및 정리 |
| `make dev` | 단일 로컬 개발 서버 (`bootRun --spring.profiles.active=local`) |
| `make run` | **goreman** 으로 api(+worker) 동시 기동 (`Procfile.dev`) |
| `make stop` | 전체 중지 (`goreman run stop-all`, 별도 터미널) |
| `make test` | 전체 테스트 실행 (`./gradlew test`) |
| `make build` | Docker 앱 이미지 빌드 (`--profile app`) |
| `make deploy` | Helm 으로 Kubernetes 배포 |

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
| `SPRING_PROFILES_ACTIVE` | `local` | Spring 프로파일 |
| `DATABASE_URL` | — | JDBC 연결 문자열 |
| `POSTGRES_USER` | `app` | DB 사용자 |
| `POSTGRES_PASSWORD` | `app` | DB 비밀번호 |
| `REDIS_HOST` | `localhost` | Redis 호스트 |

> **주의**: 실제 시크릿은 `.env.prod` 에 커밋하지 마세요.

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
│   ├── main/
│   │   ├── java/com/example/app/
│   │   │   ├── Application.java
│   │   │   ├── controller/
│   │   │   ├── service/
│   │   │   └── repository/
│   │   └── resources/
│   │       ├── application.yml
│   │       └── application-local.yml
│   └── test/
├── deploy/helm/             # Helm 차트
├── .github/workflows/       # CI 파이프라인
├── docker-compose.yml       # 개발 인프라 (Postgres/Redis)
├── Dockerfile               # 멀티스테이지 빌드
├── Procfile.dev             # goreman 로컬 멀티프로세스
├── build.gradle.kts
├── settings.gradle.kts
└── Makefile
```
