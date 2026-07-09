---
description: "심층 분석 + 라인 단위 코드 리뷰 동시 실행 / Run in-depth analysis AND line-by-line code review together. 결과는 .review/ 저장. implement 후 권장."
argument-hint: "[target-paths...] [--level 0|1|2|3|4] [--only depth|code|both] [--pdf true|false] [-O] [--depth-result <name>] [--code-result <name>] [--include <globs>] [--exclude <globs>] [--max-files <N>]"
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, AskUserQuestion, WebSearch, Agent
---

# /wise-dev-std:review

목표: 구현 완료된 코드에 대해 **두 리뷰를 한 번에** 산출한다. 방법론·출력 레이아웃은 각 스킬이 단일 기준.
1. **심층 분석** — `depth-reviewer` 스킬(스택·라이선스·보안·유지보수·아키텍처·법적·등급). 항상 **상세**.
2. **코드 리뷰** — `code-reviewer` 스킬(라인 단위, 레벨 튜닝). **기본 Level 2**.

## 인자 / Args: `$ARGUMENTS`
- `[target-paths...]`: 분석 대상(공백 구분). 없으면 현재 디렉터리.
- `--level 0|1|2|3|4`: 코드 리뷰 독자 레벨. 미지정 시 아래 §레벨 결정.
- `--only depth|code|both`: 기본 `both`.
- `--pdf true|false`: 보고서 PDF 변환(기본 false) — 각 스킬의 PDF 규칙대로.
- `-O` / `--overall`: 다중 타깃 집계 모드(두 스킬 모두).
- `--depth-result <name>`: 심층 보고서 베이스(기본 `REVIEW-InDepth`) → `.review/<name>.md`.
- `--code-result <name>`: 코드 리뷰 베이스(기본 `CODE-REVIEW-Lv<N>`) → `.review/<name>/`.
- `--include/--exclude/--max-files/--max-lines-per-file/--entry-only`: code-reviewer 로 전달.

## 레벨 결정 / Level resolution
1. `--level` 주어지면 그대로(질문 없음).
2. 없으면 기본 추천 = **Level 2**. 컨텍스트 신호로 조정: AGENTS.md/PRD 에
   "주니어·교육·온보딩"→L1, "전원 시니어·아키텍처 리뷰"→L3~4, "비개발자·기획 공유"→L0.
3. 추천 레벨을 **AskUserQuestion 1회 확인**(추천을 첫 옵션 "(추천)"). 비대화 환경/생략 → L2.
4. 결정 레벨을 `CODE-REVIEW-Lv<N>` 의 `<N>` 에 반영.

## 절차 / Steps
1. 인자 파싱. 대상이 비어있거나 소스 없으면 경로를 묻는다.
2. 컨텍스트 수집 — 루트 `PRD.md`·`AGENTS.md`·프로파일 흔적 있으면 두 스킬에 근거로 제공.
3. 레벨 결정(only=depth 면 생략).
4. 실행 — `both`: 서로 독립이므로 **Agent 서브에이전트 2개 병렬 권장**(어려우면 심층→코드 순차).
   `depth`/`code`: 해당 스킬만.
5. 저장 — `.review/<depth-result>.md` + `.review/<code-result>/`(INDEX.md + 파일별 .md).
   `-O` 면 집계 디렉터리. 동일 경로 덮어쓰기.
6. 보고 — 두 보고서 경로 + 각 1문단 요약(심층: 종합 판정 🟢🔵🟡🟠🔴 + top 위험 /
   코드: 레벨·파일 수·top-3 위험, `-O` 면 교차 리더보드).

규칙: 각 스킬의 Rules(실파일 근거만·한국어 우선 영어 병기·마케팅 톤 금지)를 그대로 따른다.
파괴적 명령·실시크릿·네트워크 설치 금지(읽기·분석·파일 쓰기만).
