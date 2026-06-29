---
description: >
  구현된 소스를 분석해 PRD.md 역도출 / Derive PRD.md from existing source code without a prior PRD.
  라우터·모델·설정·테스트를 읽어 기능·비기능·아키텍처 요구사항을 재구성한다.
  PRD 없이 구현된 프로젝트에서 역방향으로 요구사항을 도출할 때 사용.
argument-hint: "[path] [--full] [--yes]"
allowed-tools: Read, Glob, Grep, Write, Edit
---

# /wise-dev-std:reverse-prd

목표: PRD 없이 구현된 프로젝트 소스코드를 분석해 `PRD.md` 를 역도출한다.
Derive `PRD.md` by reverse-engineering functional requirements from existing source code.

인자 / Args: `$ARGUMENTS`
- `[path]`: 분석 대상 디렉터리 (기본값: 현재 작업 디렉터리).
- `--full`: One-Page + §7 기술메모 + §8 Epic 섹션까지 포함 (prd-advisor §6 풀스펙).
- `--yes`: 미확인 항목 질문 없이 즉시 `미확인:` 태그로 생성.

## 절차 / Steps

1. **reverse-prd 스킬을 사용**한다.
2. **사전 확인** — `PRD.md`/`prd.md`/`docs/PRD.md` 존재 시 덮어쓰지 않고 보강/갱신 여부 질문.
   기존 PRD 가 있으면 역도출 결과로 **차이(gap) 항목만 보강**하는 모드로 전환.
3. **소스 분석** — reverse-prd 스킬 §1 순서대로:
   a. §1.1 프로젝트 탐색 — 언어·프레임워크·진입점·서비스 구성·환경 변수·기존 문서
   b. §1.2 기능 요구사항 추출 — 라우터·컨트롤러·핸들러 전수 분석
   c. §1.3 데이터 모델 분석 — ORM·스키마·마이그레이션
   d. §1.4 비기능 요구사항 추출 — 환경 변수·미들웨어·인프라 설정
   e. §1.5 사용자 흐름 복원 — 테스트 파일 또는 라우터 체인
   f. §1.6 도메인·업종 힌트 탐지 → `domains/*.yaml` 오버레이 자동 제안
4. **미확인 항목 처리** — `--yes` 없으면 §2 규칙으로 한 번에 묶어 질문.
5. **PRD 생성** — prd-advisor §3 One-Page 템플릿 + reverse-prd §3 `## 7. 기술 현황` + 변경 이력.
   `--full` 이면 prd-advisor §6 풀스펙 섹션 추가.
6. **자가 점검** — prd-advisor §7 리뷰 체크리스트. 미충족 항목은 `미확인:` 으로 표시.
7. **안내** — reverse-prd 스킬 §4 메시지 출력.

## 규칙 / Rules
- 코드에서 확인 불가한 값은 `미확인:` 태그 — 절대 추측으로 채우지 않는다.
- 기존 PRD 덮어쓰기 금지 / never overwrite existing PRD.
- 소스코드 수정 금지 — 분석(Read, Glob, Grep)만 허용.
- 도메인 데이터는 `domains/*.yaml` 근거만 사용 / no invention.
- 파일만 생성 / file-only. 네트워크·설치 명령 실행 금지.
