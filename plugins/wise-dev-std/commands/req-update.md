---
description: >
  개발 진행 중 추가 요구사항을 문서 전체에 전파 / Propagate new requirements to all non-source documents
  during any workflow phase. PRD.md·README.md·README.en.md·COMPLIANCE.md 등 소스코드를 제외한
  모든 문서를 일관성 있게 현행화한다. 소스코드는 절대 수정하지 않는다.
argument-hint: "[요구사항 설명 | feature-description] [--type F|NF|SCOPE|DESIGN|COMPLIANCE]"
allowed-tools: Read, Glob, Grep, Write, Edit
---

# /wise-dev-std:req-update

목표: 개발 어느 단계에서나 개발자가 추가하거나 변경한 요구사항을 **소스코드를 제외한 모든 문서**에
전파해 문서와 실제 요구사항의 일관성을 유지한다.

인자: `$ARGUMENTS`
- `[요구사항 설명]`: 추가·변경할 요구사항 자연어 설명. 비워 두면 대화에서 감지된 내용으로 진행.
- `--type F|NF|SCOPE|DESIGN|COMPLIANCE`: 요구사항 유형 힌트. 미지정 시 living-doc §1.1 로 자동 분류.

## 절차 / Steps

1. **living-doc 스킬을 사용**한다.
2. **현황 파악** — living-doc §2-1 로 문서 존재 여부 확인(Glob).
   `PRD.md`, `README.md`, `README.en.md`, `COMPLIANCE.md`, `SECURITY.md`, `AGENTS.md`,
   `test/dev-env/scenario.md`, `test/impl/*/scenario.md`.
3. **요구사항 정리** — 인자 또는 대화에서 새 요구사항을 추출.
   모호하면 **한 번에 묶어** 질문(기능 명칭, 우선순위, 성공 기준, 유형).
4. **유형 분류** — `--type` 미지정 시 living-doc §1.1 기준으로 자동 분류(F/NF/SCOPE/DESIGN/COMPLIANCE).
5. **영향 파일 결정** — living-doc §1.2 매트릭스로 수정 대상 파일 목록 확정.
6. **문서 업데이트** — living-doc §3 각 파일 규칙 적용:
   - `PRD.md` → §3.1
   - `README.md` → §3.2
   - `README.en.md` → §3.3 (README.md 수정 시 항상 함께)
   - `COMPLIANCE.md` → §3.4 (파일 존재 + COMPLIANCE 유형 시)
   - `AGENTS.md` → §3.5 (명확한 영향 있을 때만)
   - `SECURITY.md` → §3.6 (보안 유형 시)
7. **PRD 변경 이력** — living-doc §4 형식으로 `## 변경 이력` 에 한 줄 추가.
8. **시험 영향 안내** — 변경이 기존 시나리오에 영향을 주면 해당 파일에 재시험 주석 추가.
9. **보고** — 수정 파일 목록 + 각 변경 요약 + "소스코드 미수정" 확인.
10. **안내** — living-doc §2-7 메시지 출력.

## 규칙 / Rules
- **소스코드 수정 절대 금지** — `.ts .tsx .js .py .go .rs .kt .swift .dart .cs .java` 등 수정 금지.
- 추측으로 요구사항 생성 금지 — 사용자 입력 근거만.
- 기존 PRD 항목 무단 삭제 금지.
- `README.md` 수정 시 `README.en.md` 도 항상 함께.
- 파괴적 구조 변경 금지(섹션 순서·기존 링크 보존).
