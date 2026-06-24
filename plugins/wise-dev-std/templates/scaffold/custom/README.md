# {{PROJECT_NAME}} — Custom Stack

> **스캐폴딩 정보**: `wise-dev-std` 플러그인 / 프로파일 `custom` 으로 생성됨.

선택한 컴포넌트 및 추론 결과는 [`CUSTOM_STACK.md`](CUSTOM_STACK.md) 에 기록됩니다.

---

## Custom 프로파일 사용법

`custom` 은 스택 일부를 지정하면 나머지를 자동 추론해 최적 전체 스택을 구성하는 **메타 프로파일**입니다.

### 1. 단일 런타임 지정

```bash
/wise-dev-std:recommend custom java
# → Java 21 + Spring Boot 3 + Gradle + PostgreSQL + Redis + Docker + GitHub Actions
```

```bash
/wise-dev-std:recommend custom "python + vue"
# → Python FastAPI 백엔드 + Vue.js 프론트엔드 + PostgreSQL + Redis
```

### 2. 복합 스택 지정

```bash
/wise-dev-std:recommend custom "spring-boot + react + kafka"
# → Java/Spring Boot API + React SPA + Kafka + PostgreSQL + Redis
```

```bash
/wise-dev-std:recommend custom "c# + postgres"
# → ASP.NET Core 8 + EF Core + PostgreSQL + Redis + Docker
```

### 3. DB/캐시만 지정

```bash
/wise-dev-std:recommend custom "mongodb + node"
# → NestJS + MongoDB + Redis + Docker
```

### 4. 스캐폴드 생성

추론 결과를 확인한 후:

```bash
/wise-dev-std:scaffold custom
```

---

## 지원 컴포넌트

전체 카탈로그는 [`COMPONENTS.md`](COMPONENTS.md) 참조.

| 카테고리 | 지원 항목 |
|----------|----------|
| 런타임 | Node.js, Python, Go, Rust, Java, C#(.NET), Kotlin |
| 백엔드 프레임워크 | NestJS, Spring Boot, ASP.NET Core, FastAPI, Gin, Axum, Django, Express |
| 프론트엔드 | Next.js, React, Vue.js, Angular, Svelte |
| DB | PostgreSQL, MySQL/MariaDB, MongoDB, SQLite, MSSQL |
| 캐시 | Redis, Memcached |
| 메시징 | Kafka, RabbitMQ |
| Ops | Docker, Kubernetes, Helm, GitHub Actions, GitLab CI |

---

## 추론 결과 확인

스캐폴드 완료 후 생성되는 `CUSTOM_STACK.md` 에서:
- 지정 컴포넌트 vs 자동 추론된 컴포넌트 구분
- 사용된 base_profile
- 합성된 gitignore 프래그먼트 목록
- 조합 품질 점수 및 대안 제안
