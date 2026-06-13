# {{PROJECT_NAME}}

Jetpack Compose 기반 Android 네이티브 앱.

> **스캐폴딩 정보**: `wise-dev-std` 플러그인 / 프로파일 `android-compose` 으로 생성됨.

## 기술 스택

| 구분 | 도구 |
|------|------|
| 언어 | Kotlin |
| UI 프레임워크 | Jetpack Compose |
| 빌드 시스템 | Gradle (Kotlin DSL) |
| 최소 SDK | API 26 (Android 8.0) |
| 배포 자동화 | [Fastlane](https://fastlane.tools/) (supply) |
| 배포 채널 | Play Store internal → production |
| CI/CD | GitHub Actions |

## 사전 요구사항

- Android Studio (최신 안정 버전) 또는 JDK 17+ + SDK Command-line Tools
- Ruby & Bundler (`gem install bundler`)
- Fastlane (`bundle install`)
- Google Play 개발자 계정 + 서비스 계정 JSON _(배포 시)_

```bash
# Fastlane 의존성 설치
bundle install
```

## 빠른 시작

```bash
# 1. dev 플레이버 디버그 빌드 + 연결된 기기/에뮬레이터에 설치
make dev
```

Android Studio 에서 열기: `File > Open > {{PROJECT_NAME}}` 선택.

## Make 사용법

| 명령 | 설명 |
|------|------|
| `make dev` | Dev 플레이버 디버그 빌드 및 설치 (`./gradlew installDevDebug`) |
| `make test` | Dev 플레이버 단위 테스트 (`./gradlew testDevDebugUnitTest`) |
| `make build` | Prod 플레이버 릴리스 번들 생성 (`./gradlew bundleProdRelease`) |
| `make deploy` | Fastlane `beta` lane — Play Store internal 트랙 업로드 |

### Gradle 직접 사용

```bash
./gradlew tasks --all                    # 전체 태스크 목록
./gradlew installDevDebug                # 에뮬레이터/기기에 설치
./gradlew testDevDebugUnitTest           # 단위 테스트
./gradlew connectedDevDebugAndroidTest   # 인스트루멘테이션 테스트
./gradlew bundleProdRelease              # 릴리스 AAB
./gradlew lintDevDebug                   # 린트
```

## 빌드 플레이버

| 플레이버 | 용도 |
|----------|------|
| `dev` | 로컬 개발 / 에뮬레이터 |
| `staging` | QA / 내부 테스트 |
| `prod` | Play Store 제출 |

## 빌드 & 배포

### 릴리스 AAB 빌드

```bash
make build
# 결과물: app/build/outputs/bundle/prodRelease/app-prod-release.aab
```

### Play Store internal 배포

```bash
make deploy
# 또는:
cd fastlane && bundle exec fastlane android beta
```

> **시크릿 주입 필요**:
> - 키스토어 파일(`.jks`/`.keystore`) — **절대 커밋 금지**
> - `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD` — CI 시크릿 등록
> - `PLAY_STORE_JSON_KEY` — 서비스 계정 JSON — CI 시크릿 등록

### CI (GitHub Actions)

Repository Secrets 에 다음 등록:
- `KEYSTORE_BASE64` (키스토어 Base64 인코딩)
- `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`
- `PLAY_STORE_JSON_KEY`

## 디렉터리 구조

```
{{PROJECT_NAME}}/
├── app/
│   ├── src/
│   │   ├── main/        # 공통 소스
│   │   ├── dev/         # dev 플레이버 소스
│   │   └── prod/        # prod 플레이버 소스
│   └── build.gradle.kts
├── fastlane/
│   ├── Fastfile         # 배포 레인 (beta)
│   └── Appfile
├── .github/workflows/   # CI 파이프라인
├── build.gradle.kts     # 루트 빌드 스크립트
├── settings.gradle.kts
└── Makefile
```
