---
description: >
  구현 완료 코드 심층 분석 + 라인 단위 코드 리뷰 동시 실행 / Run in-depth project analysis AND
  line-by-line code review together. depth-reviewer(상세) + code-reviewer(기본 Level 2, 확인/자동추천).
  결과는 .review/ 에 저장. implement 후 권장.
argument-hint: "[target-paths...] [--level 0|1|2|3|4] [--only depth|code|both] [--pdf true|false] [-O] [--depth-result <name>] [--code-result <name>] [--include <globs>] [--exclude <globs>] [--max-files <N>]"
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, AskUserQuestion, WebSearch, Agent
---

# /wise-dev-std:review

목표 / Goal: 구현 완료된 코드에 대해 **두 가지 리뷰를 한 번에** 산출한다.
1. **심층 분석 / In-depth** — `depth-reviewer` 스킬(스택·라이선스·보안·유지보수·아키텍처·법적·등급). 항상 **상세**.
2. **코드 리뷰 / Code review** — `code-reviewer` 스킬(라인 단위, 레벨 튜닝). **기본 Level 2**.

`recommend → scaffold → env-init → standardize → implement` 다음 단계로 권장. PRD/프로파일 컨텍스트가 있으면 근거로 활용.

## 인자 / Args: `$ARGUMENTS`
- `[target-paths...]`: 분석 대상(공백 구분). 없으면 현재 작업 디렉터리.
- `--level 0|1|2|3|4`: 코드 리뷰 독자 레벨. **미지정 시 기본 2** + 아래 §레벨 결정 로직.
- `--only depth|code|both`: 실행 대상. 기본 `both`(동시 실행). `depth`=심층만, `code`=코드 리뷰만.
- `--pdf true|false`: 두 보고서 PDF 변환(기본 false).
- `-O` / `--overall`: 다중 타깃 집계 모드(두 스킬 모두 적용).
- `--depth-result <name>`: 심층 보고서 베이스(기본 `REVIEW-InDepth`) → `.review/<name>.md`.
- `--code-result <name>`: 코드 리뷰 베이스(기본 `CODE-REVIEW-Lv<N>`) → `.review/<name>/`.
- `--include/--exclude/--max-files/--max-lines-per-file/--entry-only`: code-reviewer 로 전달.

## 레벨 결정 로직 / Level resolution (code-reviewer)
1. `--level` 이 주어지면 **그대로 사용**(질문 없음).
2. 없으면 **일반 사용환경 기준 자동 추천**:
   - 기본 추천 = **Level 2**(주니어 인수인계 수준 — 일반적 팀 베이스라인).
   - 컨텍스트 신호로 추천 조정(있을 때만): `AGENTS.md`/PRD 에 "주니어·교육·온보딩" → L1, "전원 시니어·아키텍처 리뷰" → L3~4,
     "비개발자·기획 공유" → L0. 신호 없으면 L2 유지.
3. 추천 레벨을 **AskUserQuestion 으로 1회 확인**한다(추천을 첫 번째 옵션 "(추천)" 으로). 옵션: L0/L1/L2/L3/L4 의미 요약.
   - 사용자가 다른 레벨 선택 → 그 레벨로. 비대화 환경이거나 사용자가 생략 → **L2 로 진행**.
4. 결정된 레벨을 `code-result` 기본명 `CODE-REVIEW-Lv<N>` 의 `<N>` 에 반영.

## 절차 / Steps
1. **인자 파싱** — targets/level/only/pdf/overall/result-name/필터. targets 없으면 cwd.
   대상이 비어있거나 소스가 없으면 사용자에게 경로를 묻는다.
2. **컨텍스트 수집** — 루트 `PRD.md`·`AGENTS.md`·프로파일 흔적(`profiles` 산출물) 있으면 읽어 두 스킬에 근거로 제공.
3. **레벨 결정** — §레벨 결정 로직 (only=depth 면 생략).
4. **동시 실행 / Run both** — `only` 에 따라:
   - `both`(기본): **두 리뷰를 함께 수행**. 서로 독립이므로 **Agent 서브에이전트 2개로 병렬 실행 권장**
     (1=depth-reviewer 상세, 2=code-reviewer at level). 병렬이 어려우면 순차(심층 → 코드).
   - `depth`: depth-reviewer 만. `code`: code-reviewer 만.
5. **저장** — `.review/` 아래:
   - 심층: `.review/<depth-result>.md` (다중 `-O` 면 집계 디렉터리).
   - 코드: `.review/<code-result>/` 트리(INDEX.md + Abstract + 파일별 .md).
   - `.review/**/logs/` 등 비커밋 권장은 기존 `.gitignore` 정책 따름. 동일 경로 덮어쓰기.
6. **PDF** — `--pdf true` 면 각 스킬의 PDF 규칙대로 변환(pandoc→md-to-pdf→grip, 없으면 스킵 안내).
7. **보고 / Report** — 두 보고서 경로 + 각 1문단 요약:
   - 심층: 종합 판정(🟢🔵🟡🟠🔴) + top 위험.
   - 코드: 선택 레벨·리뷰 파일 수·top-3 위험. `-O` 면 교차 리더보드 top-3.

## 규칙 / Rules
- 심층은 항상 상세(depth-reviewer 전체 9장). 코드는 레벨 튜닝(기본 L2).
- 실제 파일만 근거. 부재는 "확인 불가 — 파일 부재". 추측·날조 금지.
- 보고서는 한국어 우선·영어 병기. 마케팅 톤 금지.
- 파괴적 명령·실시크릿·네트워크 설치 금지(읽기·분석·파일 쓰기만). PDF 외 외부 전송 없음.
- 두 스킬의 상세 방법론·출력 레이아웃은 각 SKILL.md(`depth-reviewer`, `code-reviewer`)를 그대로 따른다.
