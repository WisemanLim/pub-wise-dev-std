# Custom Stack — 컴포넌트 카탈로그

> `profiles/custom.yaml` `components` 섹션의 인간 가독 버전.
> `/wise-dev-std:recommend custom <컴포넌트>` 에서 인식되는 모든 항목.

## 런타임 (Runtime)

| ID | 별칭 | 기본 프레임워크 | Base Profile | gitignore |
|----|------|----------------|--------------|-----------|
| `node` | nodejs, js, typescript, ts | NestJS | node-next-nest | node |
| `python` | py | FastAPI | python-fastapi | python |
| `go` | golang | Gin | go-gin | go |
| `rust` | — | Axum | rust-axum | rust |
| `java` | jvm | Spring Boot | java-spring | java |
| `csharp` | dotnet, c#, cs, net | ASP.NET Core | csharp-dotnet | csharp |
| `kotlin` | — | Spring Boot | java-spring | java |

## 백엔드 프레임워크 (Backend Framework)

| ID | 별칭 | 런타임 | Base Profile |
|----|------|--------|--------------|
| `spring-boot` | spring, springboot | java/kotlin | java-spring |
| `aspnet` | aspnetcore, asp.net | csharp | csharp-dotnet |
| `fastapi` | — | python | python-fastapi |
| `gin` | gin-gonic | go | go-gin |
| `axum` | — | rust | rust-axum |
| `nest` | nestjs | node | node-next-nest |
| `express` | expressjs | node | node-next-nest |
| `django` | — | python | python-fastapi |

## 프론트엔드 (Frontend)

| ID | 별칭 | 레이어 | gitignore |
|----|------|--------|-----------|
| `next` | nextjs, next.js | frontend | node |
| `react` | reactjs | frontend | node |
| `vue` | vuejs, nuxt | frontend | node |
| `angular` | — | frontend | node |
| `svelte` | sveltekit | frontend | node |

## 데이터베이스 (Database)

| ID | 별칭 | Compose Fragment | Local 대체 |
|----|------|-----------------|-----------|
| `postgres` | postgresql, pg, psql | docker-compose-postgres.yml | sqlite |
| `mysql` | mariadb | docker-compose-mysql.yml | sqlite |
| `mongodb` | mongo | docker-compose-mongodb.yml | — |
| `mssql` | sql-server, sqlserver | docker-compose-mssql.yml | — |
| `sqlite` | — | — (로컬 파일) | — |

## 캐시 (Cache)

| ID | Compose Fragment |
|----|-----------------|
| `redis` | docker-compose-redis.yml |
| `memcached` | docker-compose-memcached.yml |

## 메시징 (Messaging)

| ID | 별칭 | Compose Fragment |
|----|------|-----------------|
| `kafka` | apache-kafka | docker-compose-kafka.yml |
| `rabbitmq` | amqp | docker-compose-rabbitmq.yml |

---

## 주요 조합 예시

| 지정 | 추론 결과 | Base Profile |
|------|----------|--------------|
| `java` | Spring Boot + PostgreSQL + Redis | java-spring |
| `spring-boot` | Java 21 + Gradle + PostgreSQL + Redis | java-spring |
| `csharp` | ASP.NET Core 8 + EF Core + PostgreSQL | csharp-dotnet |
| `aspnet + mssql` | C# + ASP.NET Core + MSSQL + Redis | csharp-dotnet |
| `python + vue` | FastAPI 백엔드 + Vue SPA + PostgreSQL | python-fastapi |
| `java + react` | Spring Boot API + React SPA + PostgreSQL | java-spring |
| `node + mongodb` | NestJS + MongoDB + Redis | node-next-nest |
| `spring-boot + kafka` | Java + Spring Boot + Kafka + PostgreSQL | java-spring |
| `go + redis` | Go Gin + Redis + PostgreSQL | go-gin |
