---
description: "PRD.md와 기본 선택으로 트렌드에 맞는 스택 추천 / Recommend a trend-aligned stack from PRD.md and basic choices. 업종(KSIC) 오버레이 반영."
argument-hint: "[프로파일힌트|node|python|go|rust|bio-rag|mobile|ios|android|flutter|react-native] [업종|finance|healthcare|...] [--trends]"
allowed-tools: Read, Glob, Grep, WebSearch
---

# /wise-dev-std:recommend

**stack-advisor 스킬을 사용**한다 — profiles/domains 전체 로딩, PRD 탐색(없으면 핵심 질문
한 번에), 업종 해석(§1.5, 불명=ict-saas), 결정 매트릭스 점수화, §8 표 출력(모바일이면 §8 모바일 표),
프론트엔드 감지(ui-design-advisor §3 디자인 스택 델타), scaffold/env-init 안내까지
**스킬 §0 작업 순서를 그대로 따른다**.

인자: `$ARGUMENTS`
- 언어/프로파일 힌트(node/python/go/rust/bio-rag) → 후보 가중치 반영.
- **모바일 힌트**(mobile/ios/android/flutter/react-native 또는 PRD 에 앱/스토어/푸시/오프라인) →
  `kind: mobile` 후보(stack-advisor §1.7). 플랫폼·네이티브/크로스·팀언어·백엔드 필요여부 미상이면 한 번에 질문.
- 업종 힌트(finance/healthcare/... 또는 KSIC 1글자 K/Q/G/H/C/O/P/R/J) → 도메인 오버레이.
- `--trends`: **캐시 우선**(`${CLAUDE_PLUGIN_ROOT}/data/trends-cache.yaml`) — FRESH 면 캐시의
  버전 핀·규제 시행일 사용, STALE·미수록 항목만 WebSearch 재확인(stack-advisor §7).

규칙: 추측 금지 — profiles + domains 데이터와 PRD 근거만. 트렌드/규제 반영 시 출처 표기.
한국 규제(korea_regulations) 1순위, 국제 기준 병행.
