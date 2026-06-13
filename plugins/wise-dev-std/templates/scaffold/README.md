# 정적 스캐폴드 템플릿 / Static scaffold templates

`templates/scaffold/<profile-id>/` 는 해당 프로파일의 **결정적(deterministic) 보일러플레이트**다.
`project-scaffolder` 가 스캐폴딩 시 **이 디렉터리가 있으면 생성(LLM) 대신 복사**해 출력 일관성을 보장한다.
없으면 종전처럼 프로파일 `scaffold.files` 규칙으로 생성(fallback).

## 규칙 / Rules
- 디렉터리 구조 = 대상 프로젝트 루트 기준 상대경로 그대로 미러링(예: `app/main.py`, `.github/workflows/ci.yml`).
- 치환 토큰 / placeholder: **`{{PROJECT_NAME}}`** — 스캐폴더가 대상 디렉터리명(또는 사용자 지정 프로젝트명)으로 치환.
  (kebab/스네이크 등 언어 관례가 필요하면 스캐폴더가 정규화.)
- 시크릿·서명 자격은 **절대 포함 금지** — `.env.local` 은 placeholder, 모바일 서명키는 주석 안내만.
- 기존 파일 보존: 대상에 동일 파일이 있으면 덮어쓰지 않고 `*.generated` 로(스캐폴더 §2.6 규칙 동일).

## 커버리지 / Coverage
- 서버 / server: `node-next-nest`, `python-fastapi`, `go-gin`, `rust-axum`
- 모바일 / mobile: `ios-swiftui`, `android-compose`, `flutter-app`, `react-native-app`

각 세트는 핵심 결정 파일(Makefile · compose(서버) · 매니페스트 · 진입점 · `.env.local`/플레이버 · CI · Dockerfile/Fastfile)을 포함한다.
서버 세트는 **local 멀티프로세스 매니저 설정**도 포함한다 — node `ecosystem.config.cjs`(PM2), python/go/rust `Procfile.dev`(honcho/goreman/overmind). `make run/stop/logs` 로 호스트 직접 실행 시 web+worker 를 관리(compose `app` 프로파일과 별개).
**`README.md`(한국어) · `README.en.md`(영문)** 도 각 세트에 포함된다.
두 파일은 기술 스택, 사전 요구사항, 빠른 시작, `make` 전체 타겟 설명, 환경 변수, 빌드·배포·실행 절차, 디렉터리 구조를 담으며 스캐폴딩 플러그인/프로파일 정보를 문서 상단에 명시한다.
나머지 디렉터리(`scaffold.tree`)와 환경 4종(`env-init`)·도메인 `COMPLIANCE.md` 는 종전 규칙으로 보완한다.
