# {{PROJECT_NAME}}

Flutter 크로스플랫폼 앱 (iOS + Android).

> **스캐폴딩 정보**: `wise-dev-std` 플러그인 / 프로파일 `flutter-app` 으로 생성됨.  
> Fastlane 배포 참고: `.ref-doc "Cli로 ios app을 testflight 배포"`

## 기술 스택

| 구분 | 도구 |
|------|------|
| 언어 | Dart |
| 프레임워크 | [Flutter](https://flutter.dev/) (stable) |
| 상태관리 | (프로젝트 요구사항에 맞게 선택) |
| 배포 자동화 | [Fastlane](https://fastlane.tools/) |
| iOS 배포 | TestFlight (beta) → App Store |
| Android 배포 | Play Store internal → production |
| CI/CD | GitHub Actions |

## 사전 요구사항

- Flutter SDK (stable) — [flutter.dev/install](https://flutter.dev/docs/get-started/install)
- Xcode 16+ _(iOS 빌드 시 macOS 필요)_
- Android Studio + JDK 17 _(Android 빌드 시)_
- Ruby & Bundler (`gem install bundler`)
- Fastlane (`bundle install`)

```bash
# Flutter 환경 확인
flutter doctor

# Fastlane 의존성 설치
bundle install
```

## 빠른 시작

```bash
# 의존성 설치
flutter pub get

# 기본 기기/에뮬레이터에서 실행
make dev

# iOS 시뮬레이터
make ios

# Android 에뮬레이터
make android
```

## Make 사용법

| 명령 | 설명 |
|------|------|
| `make dev` | 기본 기기에서 실행 (`flutter run`) |
| `make ios` | iOS 시뮬레이터에서 실행 (`flutter run -d ios`) |
| `make android` | Android 에뮬레이터에서 실행 (`flutter run -d android`) |
| `make test` | 단위/위젯 테스트 + 분석 (`flutter test && flutter analyze`) |
| `make build` | iOS IPA + Android AAB 빌드 |
| `make deploy` | Fastlane Android `beta` lane (Play internal) |

### 플랫폼별 배포

```bash
# iOS TestFlight:
cd fastlane && bundle exec fastlane ios beta

# Android Play Store internal:
make deploy
# 또는:
cd fastlane && bundle exec fastlane android beta
```

### Flutter 직접 명령

```bash
flutter pub get                          # 의존성 설치
flutter pub upgrade                      # 의존성 업그레이드
flutter build ipa                        # iOS IPA
flutter build appbundle                  # Android AAB
flutter test --coverage                  # 커버리지 포함 테스트
flutter analyze                          # 정적 분석
dart format .                            # 포맷
```

## 빌드 & 배포

### iOS 빌드 (macOS 필요)

```bash
flutter build ipa --release
# 또는 Fastlane:
cd fastlane && bundle exec fastlane ios beta
```

> **시크릿 주입 필요**: Fastlane `match` 또는 수동 서명.  
> 서명 키(.p12), 프로비저닝 프로파일 **절대 커밋 금지**.

### Android 빌드

```bash
flutter build appbundle --release
# 결과물: build/app/outputs/bundle/release/app-release.aab

# Fastlane 업로드:
cd fastlane && bundle exec fastlane android beta
```

> **시크릿 주입 필요**: 키스토어(`.jks`), `PLAY_STORE_JSON_KEY` — CI 시크릿 등록.

## 디렉터리 구조

```
{{PROJECT_NAME}}/
├── lib/
│   ├── main.dart        # 진입점
│   ├── app/             # 앱 설정 (라우터, 테마)
│   ├── features/        # 기능별 모듈
│   └── shared/          # 공유 위젯/유틸
├── test/                # 단위/위젯 테스트
├── integration_test/    # 통합 테스트
├── fastlane/
│   ├── Fastfile         # iOS/Android 배포 레인
│   └── Appfile
├── .github/workflows/   # CI 파이프라인
├── pubspec.yaml
└── Makefile
```
