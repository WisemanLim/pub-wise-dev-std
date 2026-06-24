---
description: >
  프론트엔드 UI/UX 디자인 고려사항 안내 / Frontend UI/UX design guidance.
  목적별 레퍼런스 사이트 추천(글로벌 트렌드·UI 패턴·코드 예제·국내 레퍼런스), 디자인 시스템·
  애니메이션·접근성 스택 델타 제안. PRD 디자인 섹션 보강 또는 recommend 이후 디자인 스택 확정.
argument-hint: "[web|mobile|ios|android|flutter] [dashboard|saas|consumer|public] [--prd]"
allowed-tools: Read, Glob
---

# /wise-dev-std:ui-design

목표: 프론트엔드가 포함된 프로젝트에서 **UI/UX 디자인 방향·레퍼런스·디자인 시스템 스택**을 안내한다.

인자: `$ARGUMENTS`
- `[플랫폼]`: `web` / `mobile` / `ios` / `android` / `flutter` — 미지정 시 PRD 또는 추천 결과에서 감지.
- `[서비스 유형]`: `dashboard`(업무용) / `saas`(B2B SaaS) / `consumer`(소비자앱) / `public`(공공/관공서)
- `--prd`: PRD.md 에 `### 디자인 방향` 섹션을 직접 추가·보강.

## 절차 / Steps

1. **ui-design-advisor 스킬을 사용**한다.
2. `PRD.md`(또는 `prd.md`/`docs/PRD.md`) 가 있으면 읽어 플랫폼·서비스 유형·업종을 파악한다.
   없으면 인자에서 플랫폼·유형을 사용. 여전히 불명이면 **한 번에** 질문한다(플랫폼, 목표 분위기, 핵심 화면).
3. **ui-design-advisor §1** — 목적에 맞는 레퍼런스 사이트를 §2 상황별 표로 **3~5개** 추천.
   국내 서비스(govtech·finance·healthcare·commerce)면 §1.4 한국 레퍼런스를 1순위로.
4. **ui-design-advisor §3** — 감지된 플랫폼에 맞는 **디자인 스택 델타** 표로 출력
   (컴포넌트 라이브러리·애니메이션·아이콘·폰트·상태관리 등).
5. **ui-design-advisor §4** — 접근성 기준 안내. 공공/의료/금융이면 KWCAG 2.1 추가.
6. `--prd` 플래그가 있거나 사용자가 PRD 보강을 원하면:
   - PRD.md 의 `## 4. 사용자 경험` 하위에 **ui-design-advisor §5 템플릿**을 채워 추가.
   - 사용자가 확정한 레퍼런스·분위기·컴포넌트 패턴·접근성 기준을 기재.
7. **안내** — ui-design-advisor §6 메시지 출력.

## 규칙 / Rules
- 추측 금지. 플랫폼·유형 불명이면 질문 먼저.
- 레퍼런스 사이트는 §1 목록에서만 추천 — 목록 외 URL 임의 생성 금지.
- 디자인 스택 델타는 stack-advisor 의 프로파일 결정을 **교체하지 않고** 얹는 방식.
- `--prd` 없이는 PRD.md 를 수정하지 않는다.
- 업종이 있으면 domains/*.yaml 의 `korea_regulations` 를 확인해 접근성·인증 요구를 반영한다.
