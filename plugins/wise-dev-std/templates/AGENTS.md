# 개발환경 표준 (Wise Dev Standard)

> 이 파일은 Claude Code / Cursor / Antigravity 가 공통으로 읽는 프로젝트 표준이다.
> AI 코딩 도구는 코드·CI·인프라 생성 시 아래 표준을 기본값으로 준수한다.

## 우선순위 언어
Node/TypeScript · Python · Rust · Go · C/C++ (동점이면 이 순서).
- Node/TS: 프론트, BFF/API Gateway, 프론트 근접 서비스
- Python: 데이터/ML/분석/ETL API, RAG (uv + uvicorn + FastAPI)
- Go: 고처리량·저지연 코어, 워커 (단일 바이너리)
- Rust: 메모리안전+극한성능, 재색인 워커, Tauri 데스크톱
- C/C++: 네이티브 모듈, 시스템 수준 (CMake + Ninja)

## 패키지 매니저
- Python: **uv** (대안 pip) — pyproject.toml + uv.lock
- Node: **pnpm** (대안 npm) — monorepo 는 pnpm workspaces
- Go: go modules · Rust: cargo
- 금지/지양: forever(레거시), yarn/bun 은 승인제

## 레이어 표준
- Frontend: Next.js(App Router) + React + TypeScript + Tailwind, Vitest + Playwright, Storybook
- Backend: NestJS(Node) / FastAPI(Python) / Gin(Go) / Axum(Rust)
  - ORM: Prisma / SQLAlchemy / GORM / SQLx
- Database: PostgreSQL(신규 기본) + Redis, local/test 만 SQLite
  - 벡터=PGVector/Chroma, 그래프=Neo4j (필요 시)
- Ops: GitHub Actions(or GitLab CI), Docker + Compose, Kubernetes + Helm, Argo CD/Flux, SonarQube + Sentry
- App: Flutter/React Native + Fastlane + Firebase, 데스크톱=Tauri(Rust)

## 환경 (local / dev / staging / prod)
| 환경 | DB | compose | 핵심 |
|---|---|---|---|
| local | SQLite | 보통 X | 빠른 반복, 외부 의존 최소 |
| dev | PostgreSQL | O | 공유 개발 DB + Redis |
| staging | PostgreSQL | O | prod 동등 구성 검증 |
| prod | PostgreSQL | (K8s) | Helm + GitOps |

## 실행 방식
- 직접: `pnpm dev` / `uv run uvicorn app.main:app --reload` / `go run ./cmd/server` / `cargo run`
- 컨테이너: `docker compose up`
- 프로덕션: K8s + Helm. Node 프로세스 관리는 PM2(베어메탈) 또는 K8s.
- 공통 진입점은 Makefile: `make dev | test | build | deploy`.

## 시험 / Testing (표준 / standard)
프로젝트 루트 `test/` 에 시험을 저장한다 / store tests under `test/`.
- `test/dev-env/` — 표준 환경 구성 검증(1회) / verify the standardized env once (deps, compose up, DB, health, `make test`).
- `test/impl/<Nth>/` — 구현마다 차수 디렉터리(`1st`,`2nd`,…) / one dir per implementation iteration.
- 사이클 / cycle: 시험 시나리오 작성 → 시험 진행 → 오류 발견 시 수정·재시험 → 시험결과 작성.
  scenario → run → fix & retest on failure → write result.
- 각 차수에 `scenario.md`, `result.md`, `logs/` 포함 / each iteration has scenario, result, logs.
- 러너 / runner: Vitest+Playwright(Node) · pytest(Python) · go test(Go) · cargo test(Rust) · Ragas(RAG).

## CI/CD
단일 파이프라인으로 build → test → scan → deploy. K8s 배포는 GitOps(Argo CD/Flux).

## 코드 생성 정책 (AI 도구용)
1. 외부 트래픽/SEO 웹 → Next.js. 내부 툴/콘솔 → Vite 기반 SPA.
2. BFF/API Gateway → NestJS. 데이터/ML API → FastAPI. 고성능 코어 → Go/Rust.
3. 신규 DB → PostgreSQL + Redis. 로컬/테스트만 SQLite.
4. CI 는 GitHub Actions(or GitLab CI), 쿠버네티스 배포는 Helm + GitOps.
5. 시크릿은 코드/`.env` 에 하드코딩 금지 — Vault/Secret Manager 주입.

## 업종/업태(도메인) 표준
업종(KSIC 대분류)에 따라 규제·데이터등급·선호스택·인프라가 달라진다. 플러그인의
`domains/*.yaml` 오버레이로 정의하며, 스택을 교체하지 않고 **편향**한다(프로파일 × 도메인).
- 베이스라인: `ict-saas`(KSIC J) — 멀티테넌시·관측성(OTel)·API-first.
- 규제 업종(금융 K / 의료 Q / 공공 O 등): 한국 규제(`korea_regulations`)가 1순위 근거.
  비-프로덕션에 실 규제데이터(개인신용정보/PHI/주민PII) 반입 금지. 데이터 마스킹·샌드박스·불변 감사 필수.
- 프로젝트에 적용된 업종은 `COMPLIANCE.md`(규제·데이터등급·인프라·시험) 로 생성된다 — 그 표준을 함께 준수.

## 도메인(연구/RAG) 확장 시
출처 병기 · 권한(ACL) 필터 · 비식별화 · 감사로그 · 재현성(모델/청커/프롬프트 버전 고정) ·
하이브리드 검색(BM25+벡터) 을 기본 전제로 한다. 고위험 응답은 human-in-the-loop.

---
_생성: wise-dev-std 플러그인. 갱신은 `/wise-dev-std:standardize`._
