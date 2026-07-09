---
description: "개발 중 추가 요구사항을 소스 제외 모든 문서에 전파 / Propagate new requirements to all non-source documents."
argument-hint: "[요구사항 설명 | feature-description] [--type F|NF|SCOPE|DESIGN|COMPLIANCE]"
allowed-tools: Read, Glob, Grep, Write, Edit
---

# /wise-dev-std:req-update

**living-doc 스킬을 사용**한다 — 문서 현황 파악, 유형 분류(§1.1), 영향 파일 결정(§1.2),
파일별 갱신 규칙(§3), PRD 변경 이력(§4), 시험 영향 안내, 보고·안내까지
**스킬 §2 작업 순서를 그대로 따른다**.

인자: `$ARGUMENTS`
- `[요구사항 설명]`: 자연어 설명. 비워 두면 대화에서 감지된 내용으로 진행.
  모호하면 한 번에 묶어 질문(기능 명칭, 우선순위, 성공 기준, 유형).
- `--type F|NF|SCOPE|DESIGN|COMPLIANCE`: 유형 힌트. 미지정 시 §1.1 자동 분류.

규칙: living-doc §5 준수 — **소스코드 수정 절대 금지**, 추측으로 요구사항 생성 금지,
기존 PRD 항목 무단 삭제 금지, README.md 수정 시 README.en.md 항상 함께.
