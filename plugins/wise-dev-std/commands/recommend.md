---
description: "PRD.md와 기본 선택으로 트렌드에 맞는 스택 추천 / Recommend a trend-aligned stack (language/package-manager/framework/DB/run-method) from PRD.md and basic choices. 업종(KSIC) 입력 시 규제·데이터등급 오버레이 반영."
argument-hint: "[프로파일힌트|node|python|go|rust|bio-rag|mobile|ios|android|flutter|react-native] [업종|finance|healthcare|...] [--trends]"
allowed-tools: Read, Glob, Grep, WebSearch
---

# /wise-dev-std:recommend

목표: 현재 디렉터리의 `PRD.md`(있으면)와 사용자 선택을 바탕으로 **프로파일 × 업종(도메인)** 표준 스택을 추천.

인자: `$ARGUMENTS`
- 언어/프로파일 힌트(node/python/go/rust/bio-rag) → 후보 가중치에 반영.
- **모바일 힌트**(mobile/ios/android/flutter/react-native 또는 PRD 에 앱/스토어/푸시/오프라인) →
  `kind: mobile` 프로파일을 후보로(stack-advisor §1.7). 플랫폼/네이티브-크로스/팀언어/백엔드 필요여부 미상이면 한 번에 질문.
- 업종 힌트(finance/healthcare/commerce/logistics/manufacturing/govtech/edtech/media-gaming/ict-saas 또는
  KSIC 대분류 1글자 K/Q/G/H/C/O/P/R/J) → 도메인 오버레이 선택에 반영.
- `--trends` 포함 시 **캐시 우선**(`${CLAUDE_PLUGIN_ROOT}/data/trends-cache.yaml`): FRESH 면 캐시의 버전 핀·규제 시행일 사용,
  STALE(TTL 초과)·미수록 항목만 WebSearch 로 최신 메이저/LTS + **업종 규제 시행일** 재확인 후 반영(stack-advisor §7).

실행:
1. **stack-advisor 스킬을 사용**한다.
2. `${CLAUDE_PLUGIN_ROOT}/profiles/*.yaml` 와 `${CLAUDE_PLUGIN_ROOT}/domains/*.yaml` 전부 읽기.
3. `PRD.md`/`prd.md`/`docs/PRD.md` 탐색·읽기. 없으면 사용자에게 요구사항 핵심을 한 번에 질문
   (1순위 언어, FE/BE 범위, 팀 규모 S/M/L, **업종(KSIC 대분류)**, 직접실행 vs docker).
4. **업종 해석** — stack-advisor §1.5 매핑표로 도메인 오버레이를 고른다(불명/순수 SW = `ict-saas`).
5. 결정 매트릭스로 점수화(도메인 `recommended_profiles` 가점 포함) → 1순위 + 대안 프로파일 선정.
6. stack-advisor §8 표 형식으로 출력 + **도메인 오버레이 요약**(규제·데이터등급·인프라·시험·출처).
   추천 프로파일이 `kind: mobile` 이면 **§8 모바일 표**(DB/compose 제외, 플랫폼·플레이버·Fastlane 포함)로 출력하고,
   API 가 필요하면 서버 프로파일을 함께 제안(모노레포는 `extends`).
7. 마지막에 안내: "확정 시 `/wise-dev-std:scaffold <id>` 로 구조 생성(도메인 → `COMPLIANCE.md`),
   `/wise-dev-std:env-init` 로 환경파일 생성."

규칙: 추측 금지. profiles + domains 데이터와 PRD 근거만 사용. 트렌드/규제 반영 시 출처 표기.
한국 규제(`korea_regulations`)가 1순위 근거, 국제 기준은 병행.
