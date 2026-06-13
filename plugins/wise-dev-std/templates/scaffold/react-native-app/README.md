# {{PROJECT_NAME}}

Expo + React Native 기반 크로스플랫폼 앱 (iOS + Android).

> **스캐폴딩 정보**: `wise-dev-std` 플러그인 / 프로파일 `react-native-app` 으로 생성됨.

## 기술 스택

| 구분 | 도구 |
|------|------|
| 언어 | TypeScript |
| 프레임워크 | [React Native](https://reactnative.dev/) + [Expo](https://expo.dev/) |
| 패키지 매니저 | pnpm |
| 빌드/배포 | [EAS (Expo Application Services)](https://expo.dev/eas) |
| OTA 업데이트 | EAS Update |
| CI/CD | GitHub Actions |

## 사전 요구사항

- Node.js 22+
- pnpm 9+ (`npm i -g pnpm`)
- Expo CLI (`pnpm add -g expo-cli` 또는 `npx expo`)
- EAS CLI (`pnpm add -g eas-cli`)
- Xcode 16+ _(iOS 실기기/시뮬레이터 빌드 시 macOS 필요)_
- Android Studio _(Android 에뮬레이터 시)_

```bash
# EAS 로그인
eas login
```

## 빠른 시작

```bash
# 1. 의존성 설치
pnpm install

# 2. Expo Dev Client 실행 (Metro 번들러)
make dev
# → QR 코드로 Expo Go 앱(iOS/Android)에서 스캔
```

## Make 사용법

| 명령 | 설명 |
|------|------|
| `make dev` | Expo 개발 서버 실행 (`pnpm expo start`) |
| `make ios` | iOS 시뮬레이터에서 실행 (`pnpm expo run:ios`) |
| `make android` | Android 에뮬레이터에서 실행 (`pnpm expo run:android`) |
| `make test` | Jest 테스트 + TypeScript 검사 |
| `make build` | EAS 전 플랫폼 빌드 (`eas build -p all --profile production`) |
| `make deploy` | EAS 전 플랫폼 스토어 제출 (`eas submit -p all`) |

### EAS 직접 사용

```bash
# 프로파일별 빌드:
eas build -p ios --profile preview       # 내부 테스트
eas build -p android --profile staging

# OTA 업데이트:
eas update --branch production --message "hotfix"

# 스토어 제출:
eas submit -p ios
eas submit -p android
```

## 환경 변수

| 파일 | 용도 |
|------|------|
| `.env.local` | 로컬 개발 (Expo `extra` 에서 사용) |
| `.env.dev` | 개발 서버 |
| `.env.staging` | 스테이징 |
| `.env.prod` | 프로덕션 |

`app.json` / `app.config.ts` 의 `extra` 필드에서 환경변수 로드.

> **주의**: 실제 API 키, 시크릿은 절대 커밋하지 마세요. EAS Secrets 사용.

## 빌드 & 배포

### EAS 빌드

```bash
make build
# 또는 플랫폼별:
eas build -p ios --profile production
eas build -p android --profile production
```

### 스토어 제출

```bash
make deploy
# 또는:
eas submit -p ios     # App Store Connect
eas submit -p android # Play Store
```

### OTA 업데이트 (JS 번들만)

```bash
eas update --branch production --message "버그 수정"
```

> **시크릿 등록**: `eas secret:push --env-file .env.prod`

## 디렉터리 구조

```
{{PROJECT_NAME}}/
├── src/
│   ├── app/             # Expo Router 페이지
│   ├── components/      # 공유 컴포넌트
│   ├── hooks/           # 커스텀 훅
│   └── utils/           # 유틸리티
├── .github/workflows/   # CI 파이프라인
├── app.json             # Expo 설정
├── eas.json             # EAS 빌드 프로파일
├── package.json
├── tsconfig.json
└── Makefile
```
