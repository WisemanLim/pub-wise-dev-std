---
description: "독립 시험 명령 / Standalone test. scaffold 흐름 없이 현재 소스를 즉시 시험, 범위가 크면 청크 분할."
argument-hint: "[profile-id] [--area dev-env|impl|all] [--chunk N] [--feature keyword]"
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
---

# /wise-dev-std:test

**test-runner 스킬을 사용**한다 — 시나리오 도출·시험 사이클(§3: 시나리오→실행→수정·재시험→결과),
청킹 전략(§5), dev-env 체크리스트(§2-1)를 **스킬 표준 그대로 따른다**.

목표: 표준 흐름(scaffold→env-init) 완료 여부와 **무관하게** 현재 소스에 대해 시험 사이클을 즉시 실행.

인자 / Args: `$ARGUMENTS`
- `[profile-id]`: 생략 시 소스 분석으로 자동 감지
  (`package.json`→vitest/jest, `pyproject.toml`→pytest, `go.mod`→go test, `Cargo.toml`→cargo test;
  `Makefile` 에 `test:` 타겟 있으면 `make test` 우선).
- `--area dev-env|impl|all`: 시험 영역. 기본 `impl`.
- `--chunk N`: 청크당 최대 케이스 수(기본 15). 총 케이스 > N 이면 test-runner §5 로 자동 분할,
  청크별 `test/impl/<Nth>/chunk-<K>/{scenario.md,logs/,result.md}` → 완료 후 `test/impl/<Nth>/result.md` 합산.
- `--feature keyword`: 특정 기능 영역 한정.

커맨드 특이사항:
- `PRD.md` 있으면 PRD 기반 시나리오, 없으면 소스 역추적(행위 기반). `test/` 없으면 자동 생성.
- 시험 완료 후 **living-doc 스킬**로 문서 동기화 — README `## 테스트` 섹션에 최신 차수·판정 반영
  (README.en.md 항상 함께), 버그 수정이 기능 변경을 동반했으면 PRD.md 도 갱신.
- 보고: 청크별 판정 + 전체 판정(PASS/FAIL) + 생성/수정 파일 목록.

규칙: 기존 `test/impl/*` 차수 덮어쓰기 금지(항상 N+1). 파괴적 명령·실시크릿 금지.
네트워크 설치는 사용자 승인 후.
