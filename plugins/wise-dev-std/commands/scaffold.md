---
description: "확정된 프로파일로 프로젝트 기본 구조 생성 / Scaffold the base project structure from a profile. custom 인자로 대화형 선택, 업종 지정 시 COMPLIANCE.md 생성."
argument-hint: "custom | <profile-id> [--domain <domain-id>] [target-dir]"
allowed-tools: Read, Glob, Write, Edit, Bash
---

# /wise-dev-std:scaffold

목표: 선택한 스택 프로파일로 실제 프로젝트 골격 생성. 업종(도메인) 지정 시 규제·데이터등급 `COMPLIANCE.md` 포함.

**project-scaffolder 스킬을 사용**한다 — 파일 생성 규칙(Makefile/compose/Dockerfile/매니페스트/
`.env.*`/CI/test/·모바일 §2.5)은 스킬 §1~§2.7 을 그대로 따른다.

인자: `$ARGUMENTS`
- `custom`: 대화형 메뉴로 스택을 단계별 선택 —
  **스킬 `references/custom-flow.md`** 의 STEP 1~6 + 결정 요약 + 프로파일 매핑을 그대로 실행.
- `<profile-id>`: node-next-nest | python-fastapi | go-gin | rust-axum | cpp-cmake |
  bio-rag-research | ios-swiftui | android-compose | flutter-app | react-native-app | (추가된 id)
- `--domain <domain-id>`: (선택) finance | healthcare | commerce | logistics | manufacturing | govtech |
  edtech | media-gaming | ict-saas | (추가된 도메인). 없으면 PRD/recommend 결과에서 추정.
- `[target-dir]`: 생성 위치(기본 = 현재 디렉터리).

## 실행 / Steps

1. profile-id 없으면 (custom 아닌 경우) `/wise-dev-std:recommend` 먼저 실행하도록 안내.
2. `${CLAUDE_PLUGIN_ROOT}/profiles/<id>.yaml` 읽기(`extends` 병합). `--domain` 있으면
   `${CLAUDE_PLUGIN_ROOT}/domains/<domain-id>.yaml` 도 읽기.
3. target-dir 가 비어있지 않으면 사용자 확인. 기존 동일 파일은 덮어쓰지 않고 `*.generated` 로.
4. **스킬 §1 절차대로 생성** — 정적 템플릿(`templates/scaffold/<id>/`) 우선 복사 + `{{PROJECT_NAME}}` 치환,
   나머지만 §2(서비스) 또는 §2.5(모바일) 규칙으로 보완. 템플릿의 `README.md`·`README.en.md` 도 복사·치환
   (없으면 스택·요구사항·빠른시작·make 타겟·환경변수·빌드/배포·디렉터리 구조를 담아 생성,
   상단에 `wise-dev-std / <id>` 명시).
5. **`.gitignore` 조립** — 스킬 **§2.7** 규칙(조립 순서·모바일 매핑·멱등 센티넬).
6. **`.env.*` 생성** — 스킬 **§1-4 + §2 `.env` 항** 규칙
   (native-mobile/java-spring/csharp-dotnet 은 생성 금지 — 각 플랫폼 방식 사용).
7. 도메인 지정 시 `COMPLIANCE.md` 생성 + `stack_overrides` 추가 서비스를 compose 주석 스텁으로(서버 한정).
8. 생성 후 `find <target> -maxdepth 2` 로 트리 출력, 표준 타겟 안내: `make preflight` → `make local-build` → `make local-all`
   (`make help` 로 전체 목록; 모바일=`make setup` → `make local-all`).

## 트러블슈팅

모바일 스캐폴딩 직후 `make local-all` 실패 시: `make setup` 먼저 → 스킬 **`references/troubleshoot-mobile.md`**
(Android Gradle/JDK 호환표·kapt→KSP, iOS xcodebuild/SPM/서명) 참조.

안전: 설치/네트워크 명령 실행 금지(파일 생성만). 자격증명·서명키 생성 금지.
규제 데이터등급(규제대상)은 비-프로덕션 반입 금지를 COMPLIANCE.md 에 명시.
