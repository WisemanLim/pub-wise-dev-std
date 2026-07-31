# §custom 플로우 — 대화형 스택 선택 (scaffold custom)

`/wise-dev-std:scaffold custom` 시 아래 단계를 순서대로 실행한다.
각 단계마다 `AskUserQuestion` 으로 선택지를 제시하고, 모든 선택이 끝나면 요약 후 일반 scaffold 를 진행한다.

## STEP 1 — 플랫폼 유형

질문: **"어떤 유형의 서비스를 개발하나요?"**

| # | 선택지 | 설명 |
|---|--------|------|
| 1 | 웹 서비스 (서버 API) ★ | REST API 서버, 풀스택 웹, BFF |
| 2 | 모바일 앱 | iOS / Android / 크로스플랫폼 |

## STEP 2a — 백엔드 언어 & 프레임워크 (웹 서비스 선택 시)

질문: **"백엔드 언어 및 프레임워크를 선택하세요."**

| # | 선택지 | 프레임워크 | 추천 이유 |
|---|--------|-----------|---------|
| 1 | TypeScript / Node.js ★ | Next.js + NestJS | 풀스택·언어 통일, 생태계 최대 |
| 2 | Python ★ | FastAPI + uv | ML/AI·데이터 친화, 개발 생산성 |
| 3 | Go | Gin | 고처리량·저지연 코어 서비스, 단일 바이너리 |
| 4 | Rust | Axum | 극한 성능·메모리 안전, 보안 민감 서비스 |
| 5 | C / C++ | CMake + vcpkg + Drogon | HFT·저지연·임베디드·OS·게임엔진·AI 프레임워크 코어 — 다른 언어로 대체 불가 영역 |

## STEP 2b — 모바일 플랫폼 (모바일 선택 시)

질문: **"모바일 플랫폼 또는 앱 유형을 선택하세요."**

| # | 선택지 | 언어 | 추천 이유 |
|---|--------|------|---------|
| 1 | Flutter (iOS + Android) ★ | Dart | 단일 코드베이스·높은 성능, 크로스플랫폼 1순위 |
| 2 | React Native + Expo | TypeScript | JS 생태계 재사용, OTA 업데이트(EAS) |
| 3 | SwiftUI (iOS 전용) | Swift | iOS 네이티브 최고 품질, Apple 생태계 완전 통합 |
| 4 | Jetpack Compose (Android 전용) | Kotlin | Android 네이티브 최고 품질, Google 최신 표준 |

## STEP 3 — 데이터베이스 (웹 서비스 한정)

질문: **"주 데이터베이스를 선택하세요."**

| # | 선택지 | 특성 |
|---|--------|------|
| 1 | PostgreSQL ★ | 범용 RDBMS, ACID·JSON·전문검색 지원 |
| 2 | MySQL / MariaDB | 웹 전통 RDBMS, 단순 읽기 다중화 |
| 3 | MongoDB | 도큐먼트 DB, 스키마 유연·비정형 데이터 |
| 4 | SQLite | 초경량·파일 기반, 로컬/임베디드 전용 |

> ★ 표시 = 해당 범주에서 트렌드·생태계 기준 1순위 권장.
> PostgreSQL 외 선택 시 프로파일 기본(postgres)과 다름을 안내하고 `STACK.md` 에 결정 이유 기록.

## STEP 4 — 환경 구성

질문: **"배포 환경 구성을 선택하세요."**

| # | 선택지 | 설명 |
|---|--------|------|
| 1 | local + dev + staging + prod ★ | 표준 4단계 (권장) |
| 2 | local + dev + prod | 3단계 (소규모 프로젝트) |
| 3 | local + prod | 2단계 (초기 MVP) |

## STEP 5 — 업종 / 도메인 (선택)

질문: **"서비스의 업종·도메인을 선택하세요. (규제·데이터등급 COMPLIANCE.md 생성에 사용)"**

| # | 선택지 | domain-id |
|---|--------|-----------|
| 1 | 없음 / 일반 서비스 | — |
| 2 | 금융·핀테크·보험 | finance |
| 3 | 의료·헬스케어 | healthcare |
| 4 | 이커머스·커머스 | commerce |
| 5 | 물류·배송 | logistics |
| 6 | 제조·스마트팩토리 | manufacturing |
| 7 | 공공·정부·GovTech | govtech |
| 8 | 교육·에듀테크 | edtech |
| 9 | 미디어·게임 | media-gaming |
| 10 | ICT·SaaS | ict-saas |
| 11 | 농업·식품 | agriculture |
| 12 | 에너지·유틸리티 | energy-utilities |
| 13 | 건설·부동산 | construction |
| 14 | 숙박·관광·F&B | hospitality |

## STEP 6 — 프로젝트 이름

질문: **"프로젝트 이름을 입력하세요."** (기본값: 현재 디렉터리명)

---

## 선택 완료 후 처리

모든 선택이 끝나면 아래 형식으로 **결정 요약**을 출력한다:

```
┌─────────────────────────────────────────────────────┐
│  🛠  스캐폴드 결정 요약                                │
├──────────────────┬──────────────────────────────────┤
│ 프로젝트 이름     │ my-project                       │
│ 플랫폼           │ 웹 서비스                          │
│ 스택 프로파일     │ node-next-nest                   │
│ 프레임워크        │ Next.js 15 + NestJS 11           │
│ 데이터베이스      │ PostgreSQL (프로파일 기본)          │
│ 캐시             │ Redis                             │
│ 환경 구성         │ local / dev / staging / prod     │
│ 업종 도메인       │ finance (금융·핀테크)              │
│ target-dir       │ ./my-project                     │
└──────────────────┴──────────────────────────────────┘
위 구성으로 스캐폴딩을 진행합니다.
```

이후 **선택 결과를 profile-id + --domain 으로 변환**하여 일반 실행 단계를 진행한다.

선택→프로파일 매핑:
- TypeScript/Node.js → `node-next-nest`
- Python → `python-fastapi`
- Go → `go-gin`
- Rust → `rust-axum`
- C/C++ → `cpp-cmake`
- Flutter → `flutter-app`
- React Native → `react-native-app`
- SwiftUI → `ios-swiftui`
- Jetpack Compose → `android-compose`

데이터베이스가 프로파일 기본값(postgres)과 다를 경우: `STACK.md` 에 선택 이유·변경 사항 기록.
환경 파일의 DB 관련 변수도 해당 DB 에 맞게 생성.

local 멀티프로세스 매니저(웹 서비스 한정)는 매핑된 프로파일의 표준을 **자동 적용**한다
(SKILL "local 멀티프로세스 매니저" 항: node=PM2 · python=honcho(대안 pm2) · go=goreman · rust=overmind ·
c/c++=goreman). base_profile Makefile 교체 시 `run/stop/restart/logs/ps` 타겟 + 설정 파일
(`ecosystem.config.cjs` / `Procfile.dev`)이 함께 들어온다. 모바일 선택 시 미적용.
