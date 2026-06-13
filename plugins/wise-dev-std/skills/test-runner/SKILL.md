---
name: test-runner
description: >
  PRD 기반 시험 표준 / PRD-driven testing standard. 사이클: 시험 시나리오 작성 → 시험 진행 →
  오류 발견 시 수정·재시험 → 시험결과 작성. 결과는 test/ 디렉터리 규칙에 저장한다.
  "테스트", "시험", "검증", "QA", "test scenario" 요청 시 사용.
  Cycle: write scenario → run → on failure fix & retest → write results, stored under test/.
---

# Test Runner — 시험 표준 / Testing Standard

표준 환경 구성(scaffold + env-init) 후, 그리고 모든 구현 단계마다 동일한 시험 사이클을 적용한다.
Apply the same test cycle after standard env setup, and on every implementation iteration.

## 1. 디렉터리 규칙 / Directory convention

프로젝트 루트 이하 `test/` 에 저장한다. Stored under `test/` at project root.

```
test/
├── README.md                 # 시험 표준 설명 / testing standard overview
├── dev-env/                  # 표준 환경 구성 검증 (1회) / standard env verification (once)
│   ├── scenario.md
│   ├── result.md
│   └── logs/
└── impl/                     # 구현 시마다 / per implementation iteration
    ├── 1st/
    │   ├── scenario.md
    │   ├── result.md
    │   └── logs/
    ├── 2nd/
    └── ...                   # 3rd, 4th, … (자동 증가 / auto-increment)
```

### 차수 결정 / Iteration numbering
- `test/impl/` 의 기존 서브디렉터리(`1st`,`2nd`,…)를 스캔해 최대 N 을 찾고, 새 시험은 `(N+1)th`.
  Scan existing `test/impl/*`, find max N, new run = `(N+1)th`.
- 서수 표기 / ordinal: 1→`1st`, 2→`2nd`, 3→`3rd`, 4..20→`Nth`, 그 외 일반 규칙.
- 기존 차수 디렉터리는 **덮어쓰지 않는다** / never overwrite an existing iteration dir.

## 2. 두 가지 시험 영역 / Two test areas

### 2-1. dev-env (표준 환경 검증 / env verification — once)
scaffold + env-init 완료 후 1회. After scaffold + env-init.

**서버 프로파일 (`kind: service`)**:
- 의존성 설치 가능 여부 / deps installable (`uv sync` / `pnpm i` / `go mod download` / `cargo build`)
- 컨테이너 기동 / containers up (`make up` 또는 `docker compose up -d`)
- DB 연결 / DB connectivity (local=sqlite, dev+=postgres)
- 헬스 체크 / health endpoint (`make dev` 후 `/health` 또는 루트 응답)
- 표준 진입점 / standard targets (`make test` 동작)

**모바일 프로파일 (`kind: mobile`)** — compose/DB 케이스 대신:
- 툴체인 확인 / toolchain (`flutter doctor` · `xcodebuild -version` · `sdkmanager --list` · `node`+`expo --version`)
- 의존성 설치 / deps (`flutter pub get` · `pnpm i` · `pod install` · Gradle sync)
- 시뮬레이터·에뮬레이터 부팅 / boot simulator·emulator (iOS Simulator · Android Emulator)
- 디버그 빌드·실행 성공 / debug build & run (`make dev` → 앱이 시뮬레이터에 뜨고 기대 화면 렌더)
- 표준 진입점 / standard targets (`make test` 동작: flutter test / xcodebuild test / gradlew test / jest)

### 2-2. impl (구현 시험 / implementation tests — every iteration)
구현 작업마다 `test/impl/<Nth>/`. For each implementation step.
- PRD 요구사항 → 시나리오 / requirements → scenarios
- 단위 + 통합 + (필요 시) e2e / unit + integration + e2e if applicable

## 3. 시험 사이클 / Test cycle (PRD 기반)

1. **시나리오 작성 / Write scenario** → `scenario.md`
   - PRD 의 요구사항·수용기준을 케이스로 분해 / decompose PRD acceptance criteria into cases.
   - 케이스 표 / case table: `| id | 목적 purpose | 입력 input | 기대결과 expected | 우선순위 |`
2. **시험 진행 / Run** → `logs/` 에 원본 출력 저장 / save raw output
   - 프로파일 `makefile_targets.test` 또는 직접 러너 / use `make test` or direct runner
     (Vitest/Playwright · pytest · go test · cargo test ·
      모바일: flutter test+integration_test · XCTest/XCUITest · JUnit+Espresso · Jest+Detox/Maestro).
3. **오류 시 수정·재시험 / On failure: fix & retest** (loop)
   - 근본 원인 분석 → 코드 수정 → 재실행. Root cause → fix → rerun.
   - 각 라운드 기록 / record each round: `round N: <변경 changed> → <결과 result>`.
   - 통과 또는 한계 도달까지 반복 / repeat until pass or documented limit.
4. **시험결과 작성 / Write results** → `result.md`
   - 케이스별 pass/fail, 발견 오류, 수정 내역, 재시험 라운드, 최종 판정.
   - per-case pass/fail, bugs found, fixes, retest rounds, final verdict.

## 4. result.md 템플릿 / template

```markdown
# 시험 결과 / Test Result — <area> <Nth>
- 일자 Date / 대상 Target(profile) / 커밋 Commit
## 요약 / Summary
- 전체 Total: N, 통과 Pass: N, 실패 Fail: N, 최종 Verdict: PASS|FAIL
## 케이스 / Cases
| id | 결과 result | 비고 note |
## 발견 오류 및 수정 / Bugs & Fixes
| round | 오류 bug | 원인 cause | 수정 fix | 재시험 retest |
## 첨부 / Logs
- logs/ 참조
```

## 5. 안전 / Safety
- 시험은 코드 수정을 동반할 수 있다(3단계). 단, 파괴적 명령(DB drop, prod 배포)은 금지.
  Tests may edit code (step 3); destructive ops (DB drop, prod deploy) are forbidden.
- 시크릿·실데이터 사용 금지, 시험 DB/픽스처만 / no secrets or real data, test DB/fixtures only.
- 네트워크 설치는 사용자 승인 후 / network installs only after user approval.
