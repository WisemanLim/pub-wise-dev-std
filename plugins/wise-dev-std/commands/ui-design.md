---
description: "프론트엔드 UI/UX 디자인 안내 / Frontend UI/UX design guidance. 레퍼런스 사이트·디자인 시스템·접근성 스택 델타 제안."
argument-hint: "[web|mobile|ios|android|flutter] [dashboard|saas|consumer|public] [--prd]"
allowed-tools: Read, Glob
---

# /wise-dev-std:ui-design

**ui-design-advisor 스킬을 사용**한다 — PRD 에서 플랫폼·유형·업종 파악(불명이면 한 번에 질문),
레퍼런스 사이트 3~5개 추천(§1·§2, 국내 서비스는 §1.4 한국 레퍼런스 1순위),
디자인 스택 델타(§3), 접근성 기준(§4, 공공/의료/금융은 KWCAG), PRD 보강(§5 템플릿),
안내(§6)까지 **스킬 작업 순서를 그대로 따른다**.

인자: `$ARGUMENTS`
- `[플랫폼]`: web / mobile / ios / android / flutter — 미지정 시 PRD·추천 결과에서 감지.
- `[서비스 유형]`: dashboard(업무용) / saas(B2B) / consumer(소비자앱) / public(공공).
- `--prd`: PRD.md `## 4. 사용자 경험` 하위에 §5 템플릿으로 `### 디자인 방향` 추가·보강.

규칙: 추측 금지(불명이면 질문 먼저). 레퍼런스는 §1 목록에서만 — 임의 URL 생성 금지.
디자인 델타는 프로파일 결정을 교체하지 않고 얹는 방식. `--prd` 없이 PRD.md 수정 금지.
업종 있으면 domains/*.yaml `korea_regulations` 의 접근성·인증 요구 반영.
