---
name: stack-advisor
description: >
  Wise 개발환경 표준의 스택 의사결정 지식 베이스 / Stack decision knowledge base. PRD/요구사항과
  사용자의 기본 선택(node/python/go/rust, frontend/backend, 팀 규모, 업종/도메인)을 받아 우선순위 언어·
  패키지매니저·프레임워크·DB·실행방식·환경(local/dev/staging/prod)을 추천한다. Recommends priority
  language, package manager, framework, DB, run method, environments from PRD + basic choices.
  업종(KSIC 대분류)을 입력하면 domains/*.yaml 오버레이로 규제·데이터등급·선호스택·인프라를 반영한다.
  "스택 추천", "어떤 언어/프레임워크", "패키지 매니저 선택", "기술스택 결정", "업종/도메인 표준",
  "stack recommendation" 요청 시 사용. 추천은 profiles/*.yaml + domains/*.yaml 데이터 근거,
  최신 트렌드/규제 필요 시 WebSearch 로 버전·규정 확인.
---

# Stack Advisor — 스택 의사결정 지식 베이스

이 스킬은 추천 **로직과 근거**를 담는다. 구체적 데이터는 두 축으로 분리된다:
- **스택(무엇으로 만드나)**: `${CLAUDE_PLUGIN_ROOT}/profiles/*.yaml`
- **업종/업태(어떤 도메인이라 무엇을 더 지키나)**: `${CLAUDE_PLUGIN_ROOT}/domains/*.yaml`

둘은 **직교**한다. 추천은 항상 **프로파일 × 도메인** 으로 해석한다.
새 `*.yaml` 한 개를 추가하면 자동 반영된다(코드 수정 불필요).

## 0. 작업 순서 (always)

1. `${CLAUDE_PLUGIN_ROOT}/profiles/` 와 `${CLAUDE_PLUGIN_ROOT}/domains/` 의 YAML 목록을 읽는다 (Glob + Read).
2. 작업 디렉터리에 `PRD.md`(또는 `prd.md`, `docs/PRD.md`)가 있으면 읽어 요구사항·**업종**을 파악한다.
3. **업종(KSIC 대분류) 해석** — §1.5 매핑표로 도메인 오버레이를 고른다. PRD/사용자 입력의 업종
   키워드를 `domains/*.yaml` 의 `keywords`/`ksic_section` 과 매칭. 모르면 §1.5 표를 보여주고 1번 질문.
   업종 불명/순수 SW = `ict-saas`(J) 베이스라인.
4. 아래 결정 매트릭스로 후보 프로파일을 점수화한다(도메인 `recommended_profiles` 가점 포함).
5. 부족한 정보는 **한 번에 묶어** 질문한다(언어 1순위, FE/BE 범위, 팀 규모, **업종**, 실행방식).
6. 추천 결과를 표로 제시한다(선택/대안/근거/수정 포인트) + **도메인 오버레이 요약**(규제·데이터등급·인프라·시험).
7. 사용자가 확정하면 project-scaffolder 스킬로 넘긴다(도메인 오버레이는 `COMPLIANCE.md` 로 출력).

## 1.5 업종(KSIC 대분류) → 도메인 오버레이 매핑

근거: `.doc` 의 KSIC·ISIC·NACE·NAICS 통합표(21 대분류). KSIC 를 canonical 로 사용.

| KSIC | 업태 | 도메인 오버레이 | NAICS |
|---|---|---|---|
| **K** | 금융·보험 | `finance` | 52 |
| **L** | 부동산 | `finance`(proptech 정산) 또는 `ict-saas` + PostGIS | 53 |
| **Q** | 보건·의료·사회복지 | `healthcare` (+연구 RAG 시 `bio-rag-research`) | 62 |
| **G** | 도소매 | `commerce` | 44-45/42 |
| **H** | 운수·창고 | `logistics` | 48-49 |
| **C** | 제조 | `manufacturing` | 31-33 |
| **O** | 공공행정·국방 | `govtech` | 92 |
| **P** | 교육 | `edtech` | 61 |
| **R** | 예술·스포츠·여가 | `media-gaming` | 71 |
| **J** | 정보통신 | `ict-saas` (**기본 베이스라인**) | 51 |
| **M** | 전문·과학·기술(R&D) | `bio-rag-research` 또는 `ict-saas` | 54 |
| **A** | 농림어업 | `agriculture` (스마트팜·푸드테크) | 11 |
| **F** | 건설 | `construction` (ConTech/BIM) | 23 |
| **I** | 숙박·음식 | `hospitality` (O2O 예약·주문) | 72 |
| **D**/**E** | 전기·가스 / 수도·환경 | `energy-utilities` (유틸리티·에너지, OT) | 22 |
| 그 외 (B,N,S,T,U) | — | `ict-saas` 베이스 + PRD 근거로 델타 | — |

규칙: 다른 업종도 SW 활동 자체는 J 로 이중분류되므로 **`ict-saas` 가 항상 베이스라인**이고,
업종 오버레이는 그 위에 규제·데이터등급·선호스택 **델타**를 얹는 방식으로 읽는다.
한 프로젝트가 복수 업종이면(예: 헬스+핀테크) 두 오버레이를 합집합으로 적용하되 더 강한 규제를 우선.

## 1. 우선순위 언어 (원본 §2-3, §3)

| 언어 | 1차 용도 | 비고 |
|---|---|---|
| Node/TS | 프론트, BFF/API Gateway, 프론트 근접 서비스 | 프론트와 언어 공유 |
| Python | 데이터/ML/분석/ETL API, RAG | uv + uvicorn + FastAPI |
| Go | 고처리량·저지연 코어, 워커 | 단일 바이너리 |
| Rust | 메모리안전+극한성능, 재색인 워커, Tauri | 학습비용 고려 |
| C/C++ | 네이티브 모듈, 시스템 수준 | CMake + Ninja |

우선순위: **Node, Python, Rust, Go, C/C++** (원본 명시). 동점이면 이 순서로 결정.

## 1.7 모바일 앱 결정 (kind: mobile)

PRD/요청이 **모바일 앱**(iOS/Android/앱/스토어/푸시/오프라인 등)이면 `kind: mobile` 프로파일을 후보로 본다.
서버 프로파일과 **직교**한다 — 앱은 모바일 프로파일, API 가 필요하면 서버 프로파일을 **추가로** 추천(아래 백엔드 결합).

후보(모두 `kind: mobile`):

| 프로파일 | 언어 | 타깃 | 고를 때 |
|---|---|---|---|
| `flutter-app` | Dart | iOS+Android | 단일 코드베이스 + 픽셀 단위 커스텀 UI, Dart 자산 |
| `react-native-app` | TS/JS (Expo) | iOS+Android | React/JS 팀 자산·웹 로직 공유, OTA 반복 |
| `ios-swiftui` | Swift | iOS | iOS 전용/우선, OS 최신 API·네이티브 성능, HIG |
| `android-compose` | Kotlin | Android | Android 전용/우선, 최신 API·네이티브 성능, Material You |

결정 순서:
1. **단일 플랫폼만?** iOS 전용 → `ios-swiftui`, Android 전용 → `android-compose`.
2. **iOS+Android 동시 + 네이티브 극한 아님?** → 크로스플랫폼.
   - 팀이 React/TS → `react-native-app`. 그 외/디자인 일관성 우선 → `flutter-app`(기본 권장).
3. **양 플랫폼 + OS 최신 API/성능 극한·시스템 통합(위젯/워치/AR/센서)** → 네이티브 2종 분리(`ios-swiftui` + `android-compose`).
4. 사용자 입력에 플랫폼·팀 언어가 없으면 **한 번에 질문**(타깃 플랫폼, 네이티브 vs 크로스, 팀 언어, 백엔드 필요 여부).

**백엔드 결합** (앱 단독이 기본):
- 앱만이면 모바일 프로파일 1개로 끝.
- API 가 필요하면 서버 프로파일(`python-fastapi`/`node-next-nest`/`go-gin`)을 **별도 추천**하고,
  모노레포로 묶을 때는 `extends:`(예: `react-native-app` + `node-next-nest` → `apps/mobile/`+`apps/api/`)를 안내.
- 모바일은 서버 DB(postgres)·compose·K8s 가 **아니라** 온디바이스 저장(SwiftData/Room/Drift/expo-sqlite)
  + 페어링 API + **Fastlane→TestFlight/Play** 배포다. 추천 표는 이 축으로 출력(§8 모바일 표).

## 2. 결정 매트릭스 (점수화)

각 후보 프로파일에 대해 가산:
- PRD 키워드 매칭 (`when_to_use` 일치 +2 / 항목, `avoid_when` 일치 -3 / 항목)
- 사용자 1순위 언어 == profile.languages.primary → +3
- FE 필요 && profile.layers.frontend != null → +1
- **업종 도메인 오버레이의 `recommended_profiles`** 에 들어있으면 가점:
  1순위 +4, 2순위 +3, 3순위 +2, 4순위 +1 (도메인이 선호하는 스택을 끌어올림)
- 도메인이 규제/연구/RAG → bio-rag-research +4
- 팀 규모: Small 은 monorepo·단순 프로파일 가점, Large 는 분리형(bio-rag-research, 멀티서비스) 가점

최고점 프로파일을 1순위로, 차순위를 대안으로 제시.
**업종 오버레이는 스택을 교체하지 않고 편향**한다 — 사용자가 다른 스택을 골라도 도메인의
규제·데이터등급·인프라·시험 델타(§8 도메인 요약)는 그대로 적용한다.

## 3. 패키지 매니저 선택 (원본 §4, 사용자 요구)

| 언어 | 1순위 | 대안 | 규칙 |
|---|---|---|---|
| Python | **uv** | pip | uv: 빠른 resolver + venv 통합. pyproject.toml + uv.lock. pip 은 제약 환경만 |
| Node | **pnpm** | npm | monorepo=pnpm workspaces. yarn/bun 승인제 |
| Go | go modules | — | go.mod/go.sum |
| Rust | cargo | — | Cargo workspace |

## 4. 환경 매트릭스 (local/dev/staging/prod) — 원본 사용자 요구 + §5

| 환경 | DB 기본 | compose | 핵심 |
|---|---|---|---|
| local | **sqlite** | 보통 false | 빠른 반복, 외부 의존 최소 |
| dev | **postgres** | true | 공유 개발 DB + redis |
| staging | postgres | true | prod 동등 구성 검증 |
| prod | postgres | false (K8s) | Helm + GitOps(Argo/Flux) |

규칙: **신규 서비스 DB 기본은 PostgreSQL**, local/test 만 SQLite. MySQL 은 레거시 연계 시에만.

## 5. 실행 방식 (원본 사용자 요구 4번)

- 직접 실행: `pnpm dev` / `uv run uvicorn --reload` / `go run` / `cargo run`
- 컨테이너: `docker compose up` (dev 이상 공유 의존 포함)
- 프로덕션: K8s + Helm. Node 프로세스 관리는 PM2(베어메탈) 또는 K8s. **forever 금지(레거시)**.

## 6. 레이어 표준 요약 (원본 §1~5)

- Frontend: Next.js(App Router) + React + TS + Tailwind, Vitest+Playwright, Storybook
- Backend: NestJS / FastAPI / Gin / Axum, ORM=Prisma/SQLAlchemy/GORM/SQLx
- DB: PostgreSQL(+Redis), 로컬 SQLite, 벡터=PGVector/Chroma, 그래프=Neo4j
- Ops: GitHub Actions(or GitLab CI), Docker/Compose, K8s+Helm, Argo CD/Flux, SonarQube+Sentry
- App: Flutter/React Native + Fastlane + Firebase, 데스크톱=Tauri(Rust)

## 6.5 시험 표준 / Testing standard (필수 / required)

모든 프로파일은 **test-runner 스킬**의 시험 표준을 포함한다 / every profile includes the test-runner standard.
- 위치 / location: 프로젝트 루트 `test/`.
- 영역 / areas: `test/dev-env/`(표준 환경 검증 1회), `test/impl/<Nth>/`(구현마다, 차수 자동 증가).
- 사이클 / cycle: 시나리오 작성 → 시험 진행 → 오류 시 수정·재시험 → 시험결과 작성.
  scenario → run → fix & retest on failure → write result.
- 러너 / runner: profile.testing.framework (Vitest+Playwright / pytest / go test / cargo test / Ragas).
- 추천 표에 시험 러너를 한 행으로 포함 / include the test runner as a row in the recommendation table.

## 7. 최신 트렌드/규제 반영 (선택) — 캐시 우선 / cache-first

사용자가 "현재 트렌드/최신 버전" 또는 `--trends` 를 요구하면 **캐시를 먼저 읽고, stale 일 때만 WebSearch**:

1. **캐시 읽기** — `${CLAUDE_PLUGIN_ROOT}/data/trends-cache.yaml` 의 `runtimes`/`frameworks`/`datastores`/`regulations`.
   `meta.last_updated + meta.ttl_days` 로 신선도 판정(또는 `scripts/refresh-trends.sh` 실행 → FRESH/STALE).
2. **FRESH** 면 캐시 값을 그대로 사용(버전 핀·규제 시행일). `verify: true` 항목 중 사용자가 콕 집은 것만 선택 재확인.
3. **STALE**(TTL 초과) 거나 캐시에 없는 항목이면 WebSearch 로 확인:
   - 프레임워크 메이저 (Next.js, FastAPI, NestJS, Flutter, Expo SDK 등), 런타임 LTS (Node LTS, Python 안정).
   - **업종 규제 최신화** — 도메인 `korea_regulations` 의 `since`/시행일·`references` 재확인(전자금융감독규정·마이데이터·CSAP/N2SF·확률공개·PCI-DSS 등).
   - 변경분은 출처와 함께 `data/trends-cache.yaml`(+ 해당 `profiles`/`domains`)에 반영 제안하고, `scripts/refresh-trends.sh --set-updated TODAY` 로 스탬프 안내.
표준 자체는 고정하되 **버전 핀·규제 시행일**만 트렌드에 맞춘다. 근거 출처를 함께 표기.

## 8. 출력 형식

추천은 항상 아래 표 + 도메인 요약으로 마무리:

| 항목 | 선택 | 대안 | 근거 / 수정 포인트 |
|---|---|---|---|
| 업종(KSIC) | `<도메인 id>` (KSIC <섹션>) | — | §1.5 매핑, 오버레이 근거 |
| 언어 | … | … | … |
| 패키지매니저 | … | … | … |
| 프론트 | … | … | … |
| 백엔드 | … | … | … |
| DB(local/dev+) | sqlite / postgres | … | 도메인 `stack_overrides` 반영 |
| 실행방식 | … | … | … |
| 시험러너 / test | … | … | test/dev-env + test/impl/<Nth> + 도메인 `testing_additions` |
| 프로파일 | `<id>` | `<id>` | … |

이어서 **도메인 오버레이 요약**(해당 업종 `domains/<id>.yaml` 기준):

> **업종**: `<title>` (KSIC `<section>` · ISIC/NACE/NAICS 병기)
> **한국 규제(1순위)**: `korea_regulations` 핵심 3~5개 (시행일 포함)
> **국제 기준**: `global_compliance`
> **데이터 등급**: `data_classes` (규제대상/민감 위주)
> **인프라 델타**: `infra_patterns` / `stack_overrides`
> **개발환경 특수**: `dev_env_special`
> **추가 시험**: `testing_additions`
> **출처**: `references`

그리고: "이 추천으로 스캐폴딩하려면 `/wise-dev-std:scaffold <profile-id>` 를 실행하세요.
도메인 규제·데이터등급은 스캐폴딩 시 `COMPLIANCE.md` 로 생성됩니다."

### 모바일(`kind: mobile`) 출력 형식
모바일 프로파일을 추천할 때는 서버용 표 대신 아래 표를 쓴다(DB/compose 행 제외):

| 항목 | 선택 | 대안 | 근거 |
|---|---|---|---|
| 종류 | 모바일 앱(`kind: mobile`) | — | PRD 모바일 요구 |
| 타깃 플랫폼 | iOS+Android / iOS / Android | — | §1.7 결정 |
| 언어 | Dart / Swift / Kotlin / TS | … | 팀 자산·네이티브 여부 |
| 패키지/빌드 | pub / SwiftPM / Gradle / pnpm(Expo) | … | 프로파일 `package_managers` |
| UI | Flutter / SwiftUI / Compose / RN | … | `layers.frontend` |
| 온디바이스 저장 | Drift/SwiftData/Room/expo-sqlite | … | `database.local_store` |
| 빌드 플레이버 | local/dev/staging/prod → flavor+api_base+서명 | … | `environments`(모바일 의미) |
| 실행 | 시뮬레이터/에뮬레이터 (`run_methods`) | … | Xcode/Android Studio/flutter run |
| 배포 | Fastlane → TestFlight / Play | … | `ops.deploy` |
| 시험러너 | XCTest / JUnit+Espresso / flutter test / Jest+Detox | … | test/dev-env + test/impl/<Nth> |
| 백엔드(선택) | 별도 서버 프로파일 또는 `extends` | — | API 필요 시에만 |
| 프로파일 | `<mobile-id>` | `<id>` | — |

이어서: "API 가 필요하면 서버 프로파일도 함께 추천합니다(모노레포는 `extends`). 스캐폴딩:
`/wise-dev-std:scaffold <mobile-id>` — 컨테이너/compose 대신 Fastlane lane + 빌드 플레이버 설정을 생성합니다."
