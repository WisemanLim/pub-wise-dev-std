# {{PROJECT_NAME}}

SwiftUI 기반 iOS 네이티브 앱.

> **스캐폴딩 정보**: `wise-dev-std` 플러그인 / 프로파일 `ios-swiftui` 으로 생성됨.  
> Fastlane 배포 참고: `.ref-doc "Cli로 ios app을 testflight 배포"`

## 기술 스택

| 구분 | 도구 |
|------|------|
| 언어 | Swift 6+ |
| UI 프레임워크 | SwiftUI |
| 패키지 관리 | Swift Package Manager (SPM) |
| 빌드 | Xcode 16+ |
| 배포 자동화 | [Fastlane](https://fastlane.tools/) |
| 배포 채널 | TestFlight (beta) → App Store |
| CI/CD | GitHub Actions (macOS runner) |

## 사전 요구사항

- macOS (최신 안정 버전)
- Xcode 16+ (App Store 에서 설치)
- Ruby & Bundler (`gem install bundler`)
- Fastlane (`bundle exec fastlane` 또는 `gem install fastlane`)
- Apple Developer Program 계정

```bash
# Fastlane 의존성 설치
bundle install
```

## 빠른 시작

```bash
# 1. 의존성 (SPM) 해결 — Xcode 첫 실행 시 자동
open {{PROJECT_NAME}}.xcodeproj

# 2. 시뮬레이터에서 빌드/실행
make dev
```

## Make 사용법

```
make <target> [SCHEME=<scheme>] [DEST=<destination>]
```

| 명령 | 설명 |
|------|------|
| `make dev` | 시뮬레이터 빌드 (기본: iPhone 15) |
| `make test` | 시뮬레이터 단위/UI 테스트 |
| `make build` | Fastlane `build` lane — 아카이브(.ipa) 생성 |
| `make deploy` | Fastlane `beta` lane — TestFlight 업로드 |

### 시뮬레이터 변경

```bash
make dev DEST='platform=iOS Simulator,name=iPhone 16 Pro'
make test SCHEME=AppTests DEST='platform=iOS Simulator,name=iPad Pro 13-inch'
```

### xcodebuild 직접 사용

```bash
xcodebuild -scheme App \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -configuration Debug \
  build
```

## 빌드 & 배포

### 아카이브 빌드 (로컬)

```bash
make build
# 또는:
cd fastlane && bundle exec fastlane ios build
```

### TestFlight 배포

```bash
make deploy
# 또는:
cd fastlane && bundle exec fastlane ios beta
```

> **시크릿 주입 필요**: Fastlane `match` (인증서/프로비저닝) 또는 수동 서명 설정.  
> 실 서명 키(.p12), 프로비저닝 프로파일은 **절대 커밋 금지** — CI 시크릿/Keychain 사용.

### CI (GitHub Actions)

- `fastlane/Fastfile` 의 `beta` lane 을 macOS runner 에서 실행.
- `APP_STORE_CONNECT_API_KEY_*` 환경변수를 Repository Secrets 에 등록.

## 플레이버 / 빌드 구성

| 구성 | 용도 |
|------|------|
| `Debug` | 로컬 개발 |
| `Staging` | QA / 내부 테스트 |
| `Release` | 스토어 제출 |

각 구성별 `Config/` 디렉터리에 환경 변수(`xcconfig`) 파일로 관리.

## 디렉터리 구조

```
{{PROJECT_NAME}}/
├── App/
│   ├── Sources/         # SwiftUI 소스
│   └── Resources/       # Assets, Localizable.strings
├── Config/              # xcconfig 환경 설정
├── fastlane/
│   ├── Fastfile         # 배포 레인 (build/beta)
│   └── Appfile
├── .github/workflows/   # CI 파이프라인
├── Package.swift        # SPM 의존성
└── Makefile
```
