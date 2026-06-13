---
description: >
  설문으로 프로젝트 루트 PRD.md 초안 생성 / Draft PRD.md at project root via a short survey.
  애자일 One-Page PRD 기본, --full 시 풀스펙(아키텍처·NFR·데이터·규제) 확장. 업종(KSIC) 입력 시
  domains/*.yaml 로 성공지표·비기능요구사항 후보 자동 제안. 흐름 4-1 의 "PRD.md 를 둔다" 자동화.
argument-hint: "[프로젝트이름] [업종|finance|healthcare|commerce|...] [--full]"
allowed-tools: Read, Glob, Grep, Write
---

# /wise-dev-std:prd

목표 / Goal: PRD 작성이 어려운 사용자를 위해 **간단한 설문**으로 프로젝트 루트에 `PRD.md` 초안을
생성한다. 이후 recommend → scaffold → … 기본 흐름의 입력이 된다.
Draft `PRD.md` from a short survey so the rest of the flow can consume it.

인자 / Args: `$ARGUMENTS`
- `[프로젝트이름]`: PRD 제목에 사용 / used as the PRD title.
- `[업종]`: KSIC 대분류 키워드(finance/healthcare/commerce/logistics/manufacturing/govtech/edtech/
  media-gaming/ict-saas 또는 1글자 K/Q/G/H/C/O/P/R/J). 성공지표·NFR 후보 제안에 사용.
- `--full`: One-Page → 풀스펙(아키텍처·NFR·데이터·규제·Epic) 2단계 확장.

## 절차 / Steps

1. **prd-advisor 스킬을 사용**한다.
2. 루트에 `PRD.md`/`prd.md`/`docs/PRD.md` 가 이미 있으면 **덮어쓰지 말고** 보강/갱신 여부를 먼저 묻는다.
3. prd-advisor §2 의 **5 핵심 질문**(Why·Who·What·How·Success)을 **한 번에 묶어** 질문한다.
   비기술 직군도 답할 수 있는 자연어로. (인자에서 받은 이름/업종은 다시 묻지 않는다.)
4. **업종 해석** — 답/인자에 업종 키워드가 있으면 stack-advisor §1.5 매핑으로 도메인 오버레이를 고르고,
   `${CLAUDE_PLUGIN_ROOT}/domains/<id>.yaml` 을 읽어 성공지표·비기능요구사항·검증기준 후보를 **제안**한다
   (불명/순수 SW = `ict-saas`). 사용자가 확정.
5. **초안 생성** — prd-advisor §3 One-Page 템플릿을 §4 규칙으로 채워 루트 `PRD.md` 작성.
   모르는 값은 `가정:` 표시. `--full` 이면 §6 풀스펙 섹션을 덧붙인다.
6. **자가 점검** — §7 리뷰 체크리스트 결과를 한 줄 보고.
7. **안내** — "검토·수정 후 `/wise-dev-std:recommend` 로 스택·업종 추천을 이어가세요."

## 규칙 / Rules
- 추측 금지 — 모르는 값은 `가정:` 으로 명시(문서 §4: AI 는 보조 브레인, 판단은 사용자).
- 기존 PRD 덮어쓰기 금지 / never overwrite an existing PRD.
- 업종 데이터는 `domains/*.yaml` 근거 + 출처 인용. 새로 지어내지 않는다.
- 파일만 생성 / file-only. 네트워크·설치 명령 실행 금지.
