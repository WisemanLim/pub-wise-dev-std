---
description: >
  독립 시험 명령 / Standalone test command. PRD·scaffold 흐름 없이 현재 소스에 대해 implement 수준의
  시험을 즉시 진행한다. 시험 범위가 클 경우 자동으로 청크(chunk) 단위로 나눠 여러 차례에 걸쳐 실행한다.
  구현 후 누락된 시험, 기존 소스 검증, 독립 QA 실행 시 사용.
  "시험 해줘", "테스트 돌려줘", "test", "누락된 테스트", "test missing", "시험 범위 넓음" 요청 시 사용.
argument-hint: "[profile-id] [--area dev-env|impl|all] [--chunk N] [--feature keyword]"
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
---

# /wise-dev-std:test

목표: 표준 흐름(scaffold→env-init) 완료 여부와 무관하게 현재 소스에 대해 **implement 수준의 시험 사이클**을
즉시 실행한다. 시험 범위가 클 경우 청크(chunk)로 나눠 빠르게 처리하고 결과를 합산한다.

인자 / Args: `$ARGUMENTS`
- `[profile-id]`: 프로파일(생략 시 소스 분석으로 자동 감지).
- `--area dev-env|impl|all`: 시험 영역. 기본 `impl`.
- `--chunk N`: 청크당 최대 시험 케이스 수(기본 15). 총 케이스 수 > N 이면 자동 분할.
- `--feature keyword`: 특정 기능 영역 한정(예: `--feature auth`).

## 사전 조건 (자동 판단)

- scaffold/env-init 완료 여부 **필수 아님** — 소스가 존재하면 바로 시험 가능.
- `PRD.md` 있으면 PRD 기반 시나리오 생성. 없으면 소스 역추적으로 시나리오 도출.
- `test/` 디렉터리 없으면 자동 생성.

## 절차 / Steps

1. **환경 감지** — 소스 분석으로 프로파일·런타임·테스트 프레임워크 자동 감지.
   - `package.json` scripts → vitest/jest; `pyproject.toml` → pytest; `go.mod` → go test; `Cargo.toml` → cargo test.
   - `Makefile` 에 `test:` 타겟 있으면 우선 사용 (`make test`).
2. **시험 범위 결정** — **test-runner 스킬을 사용**.
   - `PRD.md` 있으면 요구사항 → 케이스 분해 (test-runner §3.1).
   - `PRD.md` 없으면 소스 라우터·함수·모델에서 케이스 도출 (행위 기반).
   - **총 케이스 수(TC) 집계**: 청킹 결정 기준.
3. **청킹 결정** — test-runner 스킬 §5 청킹 전략 적용:
   - TC ≤ `--chunk N` (기본 15) → 단일 차수(`test/impl/<Nth>/`)로 실행.
   - TC > N → 기능 영역(feature area) 또는 모듈 경계 기준으로 청크 분할.
     분할 수: ⌈TC / N⌉ 청크. 각 청크 번호: `chunk-1`, `chunk-2`, …
4. **청크별 시험 실행** — test-runner §3 사이클을 청크마다 순서대로 반복:
   a. 시나리오 작성 → `test/impl/<Nth>/chunk-<K>/scenario.md`
   b. 시험 실행 → `test/impl/<Nth>/chunk-<K>/logs/`
   c. 오류 시 수정·재시험 (근본 원인 분석 → 코드 수정 → 재실행)
   d. 결과 기록 → `test/impl/<Nth>/chunk-<K>/result.md`
   단일 실행인 경우 청크 디렉터리 없이 `test/impl/<Nth>/` 직접 사용.
5. **결과 합산** — 모든 청크 완료 후 `test/impl/<Nth>/result.md` 에 종합 결과 작성:
   - 총 케이스 수, 청크별 PASS/FAIL, 발견 오류 수, 전체 판정(PASS/FAIL).
6. **문서 동기화** — 시험 완료 후 **living-doc 스킬을 사용**해 문서 현행화:
   - 시험에서 발견된 버그 수정이 기능 변경을 동반했으면 PRD.md 도 갱신.
   - README.md `## 테스트` 섹션에 최신 시험 차수·판정을 반영.
   - README.en.md 동기화 (README.md 수정 시 항상 함께).
7. **보고** — 청크별 판정 + 전체 판정(PASS/FAIL) + 생성/수정 파일 목록.

## 규칙 / Rules
- test-runner 표준(시나리오→실행→수정→결과) 을 그대로 따른다.
- 기존 `test/impl/*` 차수 덮어쓰기 금지 — 항상 신규 차수(N+1) 사용.
- 파괴적 명령(DB drop, prod 배포)·실시크릿 사용 금지.
- 네트워크 설치는 사용자 승인 후.
- `--feature` 로 범위를 좁혀도 결과 파일은 동일 디렉터리 규칙 적용.
- `--area dev-env` 시 test-runner §2-1 dev-env 체크리스트를 따른다.
