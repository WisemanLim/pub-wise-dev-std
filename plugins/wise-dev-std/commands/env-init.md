---
description: "local/dev/staging/prod 환경 파일·compose 오버라이드·DB 선택(sqlite/postgres) 생성 / Generate local/dev/staging/prod env files, compose override, DB choice"
argument-hint: "<profile-id> [--db sqlite|postgres]"
allowed-tools: Read, Glob, Write, Edit, Bash
---

# /wise-dev-std:env-init

목표: 4개 환경(local/dev/staging/prod) 구성을 표준대로 생성. 플랫폼별로 불필요한 파일은 삭제.

인자: `$ARGUMENTS`
- `<profile-id>`: 환경 매트릭스를 가져올 프로파일.
- `--db`: 강제 DB. 미지정 시 프로파일 매트릭스(local=sqlite, dev+=postgres).

---

## §0 플랫폼 분류 (최우선 실행)

`${CLAUDE_PLUGIN_ROOT}/profiles/<id>.yaml` 의 `kind` + `profile-id` 로 아래 세 경로 중 하나를 선택한다.

| 분류 | 해당 프로파일 | `.env.*` 사용 여부 |
|------|--------------|-------------------|
| **service** | node-next-nest · python-fastapi · go-gin · rust-axum · bio-rag-research | ✅ 사용 (dotenv 로드) |
| **native-mobile** | ios-swiftui · android-compose | ❌ **미사용** — xcconfig / BuildConfig 로 대체 |
| **cross-mobile** | flutter-app · react-native-app | ✅ 사용 (dart-define 소스 / dotenv 플러그인) |

---

## §1 실행 분기

### A) `kind: service` — DB/compose 환경

1. 각 환경별 생성:
   - `.env.local` — sqlite, 외부 의존 최소, `--reload`/dev 모드.
   - `.env.dev` — postgres+redis, compose=true.
   - `.env.staging` — prod 동등 구성.
   - `.env.prod` — **값 대신 키 목록만**(Vault/Secret Manager 주입 전제).
2. `docker-compose.override.yml` (dev/staging 용 서비스: postgres/redis[/pgvector/neo4j/minio]).
3. `.env.example` (커밋용, placeholder만) + `.gitignore` 에 `.env.local/.env.dev/.env.staging/.env.prod` 추가.

---

### B-1) `kind: mobile`, **native** (ios-swiftui · android-compose) — xcconfig / BuildConfig 전용

`.env.*` 파일은 Swift/Xcode·Gradle 빌드 시스템이 **직접 읽지 않는다.**
scaffold 또는 이전 env-init 이 생성한 `.env.*` 파일이 있으면 **삭제** 후 보고한다.

#### §cleanup — `.env.*` 삭제

```
삭제 대상 (존재할 경우):
  .env  .env.local  .env.dev  .env.staging  .env.prod  .env.example
```

- 삭제 전 목록을 출력하고 각 파일 제거.
- `.gitignore` 의 `.env.*` 항목은 그대로 유지(향후 실수 방지).

#### §ios-swiftui — xcconfig 파일 생성/갱신

`Config/` 디렉터리에 아래 파일을 생성(없으면) 또는 누락 키만 추가(있으면):

| 파일 | 환경 | `API_BASE_URL` |
|------|------|----------------|
| `Config/Debug.xcconfig` | local + dev | 프로파일 `environments.local.api_base` |
| `Config/Staging.xcconfig` | staging | 프로파일 `environments.staging.api_base` |
| `Config/Release.xcconfig` | prod | 프로파일 `environments.prod.api_base` |

xcconfig 포맷:
```
// {{ENV}} — 실 서명키/토큰 금지. CI Secret/match 주입.
API_BASE_URL = https://api.example
APP_ENV = staging
```

`App/Sources/Core/Env.swift` 가 없으면 생성:
```swift
import Foundation
enum Env {
    static let apiBaseURL: String = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? ""
    static let appEnv: String = Bundle.main.object(forInfoDictionaryKey: "APP_ENV") as? String ?? "debug"
}
```
`Info.plist` 에 `API_BASE_URL`·`APP_ENV` 키를 `$(API_BASE_URL)` 로 추가 안내(xcconfig→Info.plist 연결 필요).

서명 placeholder 안내: `.p12` / `.mobileprovision` / `AuthKey_*.p8` 는 CI 시크릿/Fastlane match 로 주입.

#### §android-compose — local.properties + BuildConfig

1. `local.properties` — `sdk.dir` 없거나 placeholder(`<YOUR_ANDROID_SDK_PATH>`) 상태면 `make setup` 실행 안내.
   `make setup` 이 자동 감지한다 (`§troubleshoot-android` 참조).

2. `app/build.gradle.kts` 의 `productFlavors` 에서 `buildConfigField("String", "API_BASE_URL", ...)` 가
   프로파일 `environments` 와 다르면 **차이만 보고** — 덮어쓰기 금지, 수정 제안만.

3. `app/src/main/java/…/core/Config.kt` 가 없으면 생성:
```kotlin
object Config {
    val apiBaseUrl: String = BuildConfig.API_BASE_URL
    val appEnv: String = BuildConfig.FLAVOR
}
```

4. `keystore.properties` placeholder 생성(없으면):
```properties
# 실 키스토어 경로/비밀번호는 CI 시크릿/Vault 주입 — 절대 커밋 금지
storeFile=<PATH_TO_KEYSTORE>
storePassword=<STORE_PASSWORD>
keyAlias=<KEY_ALIAS>
keyPassword=<KEY_PASSWORD>
```

5. `docker-compose.override.yml` **생성 안 함**.

---

### B-2) `kind: mobile`, **cross-platform** (flutter-app · react-native-app) — `.env.*` 유지

`.env.*` 파일은 빌드 스크립트(dart-define / babel dotenv)의 **소스**로 사용된다. 유지.

각 환경(local/dev/staging/prod) = `environments` 의 `flavor` + `api_base` + `signing`:
- `.env.{local,dev,staging,prod}` — `API_BASE_URL` + `APP_ENV/FLAVOR` (실 키 금지).

**Flutter** 추가 생성:
- `lib/core/env.dart` (없으면):
```dart
// dart-define 으로 주입: flutter run --dart-define-from-file=.env.local
const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');
const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'local');
```
- `Makefile` `dev` 타겟에 `--dart-define-from-file=.env.local` 포함 여부 확인, 누락 시 추가 제안.

**React Native** 추가 생성:
- `src/core/env.ts` (없으면):
```typescript
import { API_BASE_URL, APP_ENV } from '@env';
export const config = { apiBaseUrl: API_BASE_URL, appEnv: APP_ENV };
```
- `eas.json` 환경 프로파일 (없으면) + `babel.config.js` `react-native-dotenv` 설정 확인.

서명 placeholder 안내: `*.jks` / `*.keystore` / `*.p12` / `*.mobileprovision` / `AuthKey_*.p8` 는 CI 시크릿/match 주입.
`docker-compose.override.yml` **생성 안 함**.

---

## 규칙

- 실제 비밀번호/토큰/서명키 절대 생성 금지 — 모두 placeholder.
- 서버 DB URL 형식: sqlite `sqlite:///./local.db`, postgres `postgresql://user:pass@host:5432/db`.
- 모바일 `api_base` 호스트: iOS Simulator=`localhost`, Android Emulator=`10.0.2.2`.
- 기존 파일 덮어쓰기 금지 — **누락 항목만 추가**, 차이는 보고.
- native-mobile 의 `.env.*` 삭제는 **보고 후 실행** (파일 목록 먼저 출력).
