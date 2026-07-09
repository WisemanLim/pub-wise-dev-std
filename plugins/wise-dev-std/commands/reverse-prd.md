---
description: "구현된 소스를 분석해 PRD.md 역도출 / Derive PRD.md from existing source code without a prior PRD."
argument-hint: "[path] [--full] [--yes]"
allowed-tools: Read, Glob, Grep, Write, Edit
---

# /wise-dev-std:reverse-prd

**reverse-prd 스킬을 사용**한다 — 기존 PRD 확인(있으면 gap 보강 모드), 소스 분석(§1.1~§1.6:
탐색→기능→데이터모델→비기능→사용자 흐름→도메인 힌트), 미확인 항목 질문(§2),
PRD 생성(prd-advisor §3 템플릿 + §3 기술 현황), 자가 점검, 안내(§4)까지
**스킬 §0→§4 작업 순서를 그대로 따른다**.

인자 / Args: `$ARGUMENTS`
- `[path]`: 분석 대상 디렉터리(기본: 현재 디렉터리).
- `--full`: prd-advisor §6 풀스펙 섹션 추가.
- `--yes`: 질문 없이 미확인 항목을 `미확인:` 태그로 즉시 생성.

규칙: 코드에서 확인 불가한 값은 `미확인:` — 추측 금지. 기존 PRD 덮어쓰기 금지.
소스코드 수정 금지(분석만). 도메인 데이터는 domains/*.yaml 근거만. 파일 생성만 — 네트워크·설치 금지.
