---
description: "확정된 프로파일로 프로젝트 기본 구조 생성 / Scaffold the base project structure (tree/Makefile/compose/manifest/CI/.env/test) from a chosen profile. 업종 지정 시 COMPLIANCE.md 생성. `custom` 인자로 대화형 스택 선택 가능."
argument-hint: "custom | <profile-id> [--domain <domain-id>] [target-dir]"
allowed-tools: Read, Glob, Write, Edit, Bash
---

# /wise-dev-std:scaffold

목표: 선택한 스택 프로파일로 실제 프로젝트 골격 생성. 업종(도메인) 지정 시 규제·데이터등급 `COMPLIANCE.md` 포함.

인자: `$ARGUMENTS`
- `custom`: 대화형 메뉴로 스택을 단계별 선택 → 아래 **§custom 플로우** 참조.
- `<profile-id>`: node-next-nest | python-fastapi | go-gin | rust-axum | bio-rag-research |
  ios-swiftui | android-compose | flutter-app | react-native-app | (추가된 id)
- `--domain <domain-id>`: (선택) finance | healthcare | commerce | logistics | manufacturing | govtech |
  edtech | media-gaming | ict-saas | (추가된 도메인). 없으면 PRD/recommend 결과에서 추정.
- `[target-dir]`: 생성 위치(기본 = 현재 디렉터리).

---

## §custom 플로우 — 대화형 스택 선택

`$ARGUMENTS` 가 `custom` 이면 아래 단계를 순서대로 실행한다.  
각 단계마다 `AskUserQuestion` 으로 선택지를 제시하고, 모든 선택이 끝나면 요약 후 일반 scaffold 를 진행한다.

### STEP 1 — 플랫폼 유형

질문: **"어떤 유형의 서비스를 개발하나요?"**

| # | 선택지 | 설명 |
|---|--------|------|
| 1 | 웹 서비스 (서버 API) ★ | REST API 서버, 풀스택 웹, BFF |
| 2 | 모바일 앱 | iOS / Android / 크로스플랫폼 |

### STEP 2a — 백엔드 언어 & 프레임워크 (웹 서비스 선택 시)

질문: **"백엔드 언어 및 프레임워크를 선택하세요."**

| # | 선택지 | 프레임워크 | 추천 이유 |
|---|--------|-----------|---------|
| 1 | TypeScript / Node.js ★ | Next.js + NestJS | 풀스택·언어 통일, 생태계 최대 |
| 2 | Python ★ | FastAPI + uv | ML/AI·데이터 친화, 개발 생산성 |
| 3 | Go | Gin | 고처리량·저지연 코어 서비스, 단일 바이너리 |
| 4 | Rust | Axum | 극한 성능·메모리 안전, 보안 민감 서비스 |

### STEP 2b — 모바일 플랫폼 (모바일 선택 시)

질문: **"모바일 플랫폼 또는 앱 유형을 선택하세요."**

| # | 선택지 | 언어 | 추천 이유 |
|---|--------|------|---------|
| 1 | Flutter (iOS + Android) ★ | Dart | 단일 코드베이스·높은 성능, 크로스플랫폼 1순위 |
| 2 | React Native + Expo | TypeScript | JS 생태계 재사용, OTA 업데이트(EAS) |
| 3 | SwiftUI (iOS 전용) | Swift | iOS 네이티브 최고 품질, Apple 생태계 완전 통합 |
| 4 | Jetpack Compose (Android 전용) | Kotlin | Android 네이티브 최고 품질, Google 최신 표준 |

### STEP 3 — 데이터베이스 (웹 서비스 한정)

질문: **"주 데이터베이스를 선택하세요."**

| # | 선택지 | 특성 |
|---|--------|------|
| 1 | PostgreSQL ★ | 범용 RDBMS, ACID·JSON·전문검색 지원 |
| 2 | MySQL / MariaDB | 웹 전통 RDBMS, 단순 읽기 다중화 |
| 3 | MongoDB | 도큐먼트 DB, 스키마 유연·비정형 데이터 |
| 4 | SQLite | 초경량·파일 기반, 로컬/임베디드 전용 |

> ★ 표시 = 해당 범주에서 트렌드·생태계 기준 1순위 권장.  
> PostgreSQL 외 선택 시 프로파일 기본(postgres)과 다름을 안내하고 `STACK.md` 에 결정 이유 기록.

### STEP 4 — 환경 구성

질문: **"배포 환경 구성을 선택하세요."**

| # | 선택지 | 설명 |
|---|--------|------|
| 1 | local + dev + staging + prod ★ | 표준 4단계 (권장) |
| 2 | local + dev + prod | 3단계 (소규모 프로젝트) |
| 3 | local + prod | 2단계 (초기 MVP) |

### STEP 5 — 업종 / 도메인 (선택)

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

### STEP 6 — 프로젝트 이름

질문: **"프로젝트 이름을 입력하세요."** (기본값: 현재 디렉터리명)

---

### 선택 완료 후 처리

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

이후 **선택 결과를 profile-id + --domain 으로 변환**하여 아래 일반 실행 단계(§1~§8)를 진행한다.

선택→프로파일 매핑:
- TypeScript/Node.js → `node-next-nest`
- Python → `python-fastapi`
- Go → `go-gin`
- Rust → `rust-axum`
- Flutter → `flutter-app`
- React Native → `react-native-app`
- SwiftUI → `ios-swiftui`
- Jetpack Compose → `android-compose`

데이터베이스가 프로파일 기본값(postgres)과 다를 경우: `STACK.md` 에 선택 이유·변경 사항 기록. 환경 파일의 DB 관련 변수도 해당 DB 에 맞게 생성.

---

실행:
1. **project-scaffolder 스킬을 사용**한다.
2. profile-id 없으면 (custom 아닌 경우) `/wise-dev-std:recommend` 를 먼저 실행하도록 안내.
3. `${CLAUDE_PLUGIN_ROOT}/profiles/<id>.yaml` 읽기 (`extends` 병합). `--domain` 있으면
   `${CLAUDE_PLUGIN_ROOT}/domains/<domain-id>.yaml` 도 읽기.
4. target-dir 가 비어있지 않으면 사용자 확인. 기존 동일 파일은 덮어쓰지 않고 `*.generated` 로.
5. `scaffold.tree` 디렉터리 + `scaffold.files` 파일 생성.
   - **정적 템플릿 우선**: `${CLAUDE_PLUGIN_ROOT}/templates/scaffold/<id>/` 가 있으면 복사 + `{{PROJECT_NAME}}` 치환(결정적). 나머지만 생성으로 보완.
   - 템플릿에 포함된 `README.md`(한국어) · `README.en.md`(영문) 도 함께 복사·치환.
     없는 경우 아래 내용을 포함한 두 파일을 **생성**: 기술 스택·사전 요구사항·빠른 시작·`make` 전체 타겟 설명·환경 변수 목록·빌드&배포 절차·디렉터리 구조.
     스캐폴딩에 사용된 플러그인/프로파일 정보(`wise-dev-std / <id>`)를 문서 상단에 명시.
   - `kind: service`(기본) → project-scaffolder **§2**(compose/Dockerfile/DB) 규칙.
   - `kind: mobile` → project-scaffolder **§2.5**(compose/Dockerfile/DB 미생성, 플랫폼 레이아웃 + 빌드 플레이버 + `fastlane/Fastfile` + macOS CI) 규칙.
5-a. **`.gitignore` 조립 (멱등)** — implement 와 동일한 규칙으로 스캐폴딩 시점에 미리 생성.
   - 조립 순서: `templates/gitignore/_common.gitignore` → `_platform.gitignore`(macOS·Windows·Linux)
     → 언어별(`node|python|go|rust|c-cpp|swift|android|flutter|react-native`).
   - 언어는 프로파일 `languages.primary` + `languages.also` 에서 결정. 모바일 매핑:
     `ios-swiftui`→`swift`, `android-compose`→`android`, `flutter-app`→`flutter`,
     `react-native-app`→`react-native`+`node`.
   - `.gitignore` 없으면 생성. 있으면 **누락 섹션만 추가**(헤더 `# ===== ... =====` 를 센티넬로 사용).
     기존 사용자 항목 보존 — 삭제·재정렬 금지.
   - 결과 보고: 추가한 섹션 목록.
6. `.env.{local,dev,staging,prod}` 를 environments 매트릭스대로 생성(실제 시크릿 금지).
   모바일은 DB URL 대신 **flavor + `api_base` + 서명 placeholder**(실 키스토어/.p12/프로비저닝 금지).
7. 도메인 지정 시 `COMPLIANCE.md` 생성 + `stack_overrides` 추가 서비스를 compose 주석 스텁으로(서버 한정).
8. 생성 후 `find <target> -maxdepth 2` 로 트리 출력, `make dev` 사용법 안내(모바일=시뮬레이터/에뮬레이터).

안전: 설치/네트워크 명령 실행 금지(파일 생성만). 자격증명·서명키 생성 금지.
규제 데이터등급(규제대상)은 비-프로덕션 반입 금지를 COMPLIANCE.md 에 명시.

---

## §troubleshoot-android — Android 개발환경 초기 에러 처리

스캐폴딩 직후 `make dev` 실패 시 **`make setup` 먼저 실행**. 수동 처리가 필요한 경우 아래 표 참조.

| 증상 | 원인 | 해결 |
|------|------|------|
| `./gradlew: No such file or directory` | Gradle Wrapper 미생성 | `gradle wrapper --gradle-version 9.5.1` → `chmod +x gradlew` |
| `Could not parse version string '25.0.3'` | Gradle 8.x 임베디드 Kotlin이 JDK 25 버전 문자열 파싱 불가 | `gradle/wrapper/gradle-wrapper.properties` 의 `distributionUrl` 을 Gradle **9.5.1** 이상으로 변경 |
| `kapt` + JDK 25 에러 (`javacOptions` 관련) | kapt 어노테이션 프로세서가 JDK 25 미지원 | `kapt` → **KSP** 마이그레이션: root `build.gradle.kts` 에 `id("com.google.devtools.ksp") version "2.1.0-1.0.29" apply false`, 각 모듈에 `id("com.google.devtools.ksp")` 추가. `kapt(...)` 의존성을 `ksp(...)` 로 변경 |
| `AndroidManifest.xml` 없음 | scaffold 템플릿 누락 | `app/src/main/AndroidManifest.xml` 생성 (템플릿 `§2` 규칙) |
| `sdk.dir` 없음 / `local.properties` 없음 | Android SDK 경로 미등록 | `make setup` 자동 감지, 또는 `local.properties` 에 수동 설정: macOS=`~/Library/Android/sdk`, Linux=`~/Android/Sdk`, Windows=`%USERPROFILE%\AppData\Local\Android\Sdk` |
| `installDevDebug` 실패 (에뮬레이터 미실행) | `make dev` 는 실행 중인 에뮬레이터 필요 | Android Studio → AVD Manager → 에뮬레이터 실행 후 `make dev` |

### Gradle 버전 호환성 (JDK 기준)

| JDK | 최소 Gradle | 권장 Gradle |
|-----|------------|------------|
| 17  | 7.3        | 8.x        |
| 21  | 8.5        | 8.10.x     |
| 25+ | 9.5.1+     | **9.5.1**  |

> 템플릿 기본값: Gradle **9.5.1** (`gradle-wrapper.properties`), KSP **2.1.0-1.0.29**.  
> `kapt` 사용 금지 — JDK 25 에서 `javacOptions` 파싱 에러 발생.

---

## §troubleshoot-ios — iOS 개발환경 초기 에러 처리

스캐폴딩 직후 `make dev` 실패 시 **`make setup` 먼저 실행**. 수동 처리가 필요한 경우 아래 표 참조.

| 증상 | 원인 | 해결 |
|------|------|------|
| `xcode-select: error: tool 'xcodebuild' requires Xcode` | Xcode Command Line Tools 미설치 | `xcode-select --install` |
| `xcodebuild: error: 'App' is not a workspace` | SwiftPM 프로젝트에 `.xcworkspace` 없이 `xcodebuild -workspace` 호출 | `xcodebuild -scheme App -destination '...'` (workspace 플래그 제거) |
| `simulator … not found` | DEST 이름이 설치된 시뮬레이터와 불일치 | `xcrun simctl list devices available` 로 확인 후 `make dev DEST='platform=iOS Simulator,name=<name>'` |
| `swift package resolve` 실패 | SPM 캐시 손상 또는 네트워크 | `rm -rf .build && swift package resolve` |
| 서명 에러 (`CODE_SIGNING_REQUIRED`) | 로컬 빌드에 서명 설정 없음 | `make dev` 에 `CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO` 추가, 또는 Xcode에서 Team 설정 |
| `Package.resolved` 충돌 | 의존성 버전 불일치 | `rm Package.resolved && swift package resolve` |
| `Filename.xcconfig: error: Unable to find included file` | xcconfig `#include` 경로 오류 | `Config/` 경로와 xcconfig `#include` 경로 일치 확인 |

> SPM 프로젝트(Package.swift) vs Xcode 프로젝트(.xcodeproj/.xcworkspace) 혼용 시:  
> - SPM만 사용 → `xcodebuild -scheme … -destination …` (workspace 불필요)  
> - Xcode 프로젝트 사용 → `xcodebuild -workspace … -scheme … -destination …`
