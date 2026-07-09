---
description: "설문으로 프로젝트 루트 PRD.md 초안 생성 / Draft PRD.md via a short survey. One-Page 기본, --full 확장, 업종 입력 시 지표·NFR 후보 제안."
argument-hint: "[프로젝트이름] [업종|finance|healthcare|commerce|...] [--full]"
allowed-tools: Read, Glob, Grep, Write
---

# /wise-dev-std:prd

**prd-advisor 스킬을 사용**한다 — 기존 PRD 확인, 5 핵심 질문(한 번에 묶어 질문), 업종 오버레이,
One-Page 템플릿(§3)·작성 규칙(§4)·`--full` 풀스펙(§6)·자가 점검(§7)·프론트엔드 감지
(ui-design-advisor 연동)·recommend 안내까지 **스킬 §0 작업 순서를 그대로 따른다**.

인자 / Args: `$ARGUMENTS`
- `[프로젝트이름]`: PRD 제목에 사용.
- `[업종]`: KSIC 키워드(finance/healthcare/commerce/... 또는 1글자 K/Q/G/H/C/O/P/R/J) —
  domains/*.yaml 로 성공지표·NFR 후보 제안.
- `--full`: One-Page → 풀스펙(아키텍처·NFR·데이터·규제·Epic) 확장.

커맨드 특이사항: 인자로 받은 이름·업종은 설문에서 다시 묻지 않는다.

규칙: prd-advisor §4·§8 준수(추측 금지 — `가정:` 표시, 기존 PRD 덮어쓰기 금지,
업종 데이터는 domains/*.yaml 근거만). 파일 생성만 — 네트워크·설치 명령 금지.
