# {{PROJECT_NAME}}

C/C++ + CMake 기반 고성능 서비스.

> **스캐폴딩 정보**: `wise-dev-std` 플러그인 / 프로파일 `cpp-cmake` 으로 생성됨.  
> [English README](README.en.md)

## 기술 스택

| 구분 | 도구 |
|------|------|
| 언어 | C++17 / C++20 (GCC 13+ / Clang 17+) |
| HTTP 프레임워크 | [Drogon](https://drogon.org/) (대안: cpp-httplib, Crow) |
| 빌드 시스템 | CMake 3.21+ + CMakePresets.json |
| 패키지 관리 | [vcpkg](https://vcpkg.io/) (manifest 모드) |
| 테스트 | GTest + GMock |
| DB | PostgreSQL 17 (Alpine) |
| 로컬 DB | SQLite (파일 기반, docker 불필요) |
| 캐시 | Redis 7.4 (Alpine) |
| 컨테이너 | Docker / Docker Compose v2 |
| 배포 | Helm 3 (Kubernetes) |
| CI/CD | GitHub Actions |
| 코드 품질 | clang-format + clang-tidy + AddressSanitizer |

## 사전 요구사항

| 도구 | 최소 버전 | 설치 |
|------|-----------|------|
| C++ 컴파일러 | GCC 13 / Clang 17 | `brew install llvm` 또는 `apt install g++` |
| CMake | 3.21+ | `brew install cmake` |
| ninja | — | `brew install ninja` (빌드 가속) |
| vcpkg | 최신 | `git clone https://github.com/microsoft/vcpkg && bootstrap` |
| Docker Desktop | 4.x+ | [docker.com](https://www.docker.com/) |
| goreman | — | `go install github.com/mattn/goreman@latest` (멀티프로세스 시) |

```bash
# 호환성 사전 점검 (env-init 전 필수)
make preflight
```

## 빠른 시작

```bash
# 1. VCPKG_ROOT 환경변수 설정 (vcpkg 사용 시)
export VCPKG_ROOT=$HOME/vcpkg   # 또는 /opt/vcpkg

# 2. 의존성 설치 (vcpkg manifest 모드)
vcpkg install

# 3. 환경 변수 파일 복사
cp .env.local .env

# 4. 인프라 기동 (Postgres :5432 + Redis :6379) — local 은 SQLite 이므로 생략 가능
make up

# 5. 빌드 + 실행 (Debug)
make dev
# → http://localhost:8080
```

## Make 사용법

```
make <target> [BUILD_TYPE=Debug|Release] [LOCAL_INFRA=redis]
```

### 빌드

| 명령 | 설명 |
|------|------|
| `make preflight` | 런타임·도구 버전 호환성 사전 점검 |
| `make configure` | CMake 구성 (CMakePresets.json 사용, compile_commands.json 생성) |
| `make build` | 컴파일 (`cmake --build`, 병렬, configure 자동 선행) |
| `make clean` | 빌드 결과물 전체 제거 (`build/` 삭제) |

### 실행

| 명령 | 설명 |
|------|------|
| `make up` | PostgreSQL + Redis 컨테이너 기동 (infra only) |
| `make down` | 컨테이너 정리 |
| `make dc-logs [SVC=xxx]` | docker compose 로그 추적 |
| `make dc-ps` | docker compose 컨테이너 상태 |
| `make dev` | 빌드 후 바이너리 직접 실행 (포그라운드) |
| `make ps` | goreman 프로세스 상태 |

### 일괄 기동

| 명령 | 설명 |
|------|------|
| `make local-all [LOCAL_INFRA=redis]` | **[local]** infra(docker) + 빌드 + goreman 일괄 기동 (백그라운드) |
| `make local-logs` | **[local]** 통합 로그 추적 (Ctrl-C 로 tail 종료, 프로세스는 유지) |
| `make local-stop` | **[local]** goreman 종료 + infra 정리 |
| `make local-restart` | **[local]** goreman 재기동 (infra 유지) |
| `make dev-all` / `staging-all` / `prod-all` | 환경별 infra+app 컨테이너 기동 (`.env.<env>`, 기존 이미지) |
| `make dev-build` / `staging-build` / `prod-build` | 환경별 이미지 재빌드 후 기동 |
| `make dev-logs` / `staging-logs` / `prod-logs` | 환경별 컨테이너 로그 추적 (`SVC=`로 특정 서비스) |
| `make dev-stop` / `staging-stop` / `prod-stop` | 환경별 app+infra 전체 정리 |
| `make dev-restart` / `staging-restart` / `prod-restart` | 환경별 컨테이너 재기동 |

### 테스트 & 코드 품질

| 명령 | 설명 |
|------|------|
| `make test` | CTest 실행 (GTest, 병렬) |
| `make fmt` | clang-format 적용 (src/ + include/ in-place) |
| `make lint` | clang-tidy 정적 분석 (compile_commands.json 기반) |
| `make sanitize` | AddressSanitizer + UBSan 빌드·실행 (메모리 안전성 점검) |

### 배포

| 명령 | 설명 |
|------|------|
| `make build BUILD_TYPE=Release` | 릴리즈 빌드 |
| `make dev-build` | Docker 이미지 빌드 + 기동 |
| `make deploy` | Helm으로 Kubernetes 배포 |

## 환경 변수

| 파일 | 용도 |
|------|------|
| `.env.local` | 로컬 개발 (SQLite, Git 제외) |
| `.env.dev` | 개발 서버 (PostgreSQL + Redis) |
| `.env.staging` | 스테이징 |
| `.env.prod` | 프로덕션 (시크릿은 CI/Vault 관리) |

주요 변수:

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `DATABASE_URL` | `sqlite:///./local.db` | DB 연결 문자열 |
| `REDIS_URL` | `redis://localhost:6379` | Redis 연결 (필요 시) |
| `SERVER_PORT` | `8080` | HTTP 수신 포트 |
| `LOG_LEVEL` | `debug` | 로그 레벨 |

> **주의**: 실제 시크릿은 `.env.prod` 에 커밋하지 마세요.

## 실행 방법

### A) 로컬 직접 실행 (호스트, SQLite)

```bash
make preflight     # 사전 점검
make dev           # configure → build → run (Debug, SQLite)

# Release 빌드:
make dev BUILD_TYPE=Release
```

### B) 로컬 멀티프로세스 (goreman, Procfile.dev)

server 외에 worker 프로세스를 함께 띄울 때 사용. `Procfile.dev` 의 `web:`/`worker:` 로 정의. goreman 은
**백그라운드 데몬화**(nohup+pidfile, `.make/goreman.pid`)되어 `local-logs`/`local-stop`/`local-restart` 로 제어한다.

```bash
# goreman 설치 (1회)
go install github.com/mattn/goreman@latest

# infra + 빌드 + 멀티프로세스 일괄 기동 (백그라운드)
make local-all LOCAL_INFRA=redis   # SQLite 사용 시 postgres 불필요 → redis 만 기동

# 개별 실행:
make up             # infra 기동
make build          # 컴파일
make local-logs      # 통합 로그 추적
make local-stop      # 전체 종료 (goreman + infra)
```

> C++은 핫리로드 없음. 코드 변경 후 `make build` 재실행 → goreman 자동으로 바이너리 재시작 불가.
> `entr`/`nodemon --exec make local-restart` 로 파일 감시 자동화 가능.

### C) Docker 전체 스택 (dev/staging/prod)

```bash
# 기존 이미지로 기동
make dev-all

# 코드 변경 후 이미지 재빌드 + 기동
make dev-build

# 로그 추적
make dev-logs

# 정리
make dev-stop
```

## 접속 / 포트

| 서비스 | URL | 프로파일 | 비고 |
|--------|-----|----------|------|
| API 서버 | http://localhost:8080 | 모든 환경 | `SERVER_PORT` 변수로 변경 |
| PostgreSQL | localhost:5432 | dev/staging | compose infra |
| Redis | localhost:6379 | dev/staging | compose infra (local 선택) |

## 빌드 옵션

```bash
# Debug (기본, -g, 어서션 활성화)
make build

# Release (-O3, NDEBUG, LTO)
make build BUILD_TYPE=Release

# RelWithDebInfo (릴리즈 최적화 + 디버그 심벌)
make build BUILD_TYPE=RelWithDebInfo

# 메모리 안전성 검사 (AddressSanitizer + UBSan)
make sanitize
```

## 코드 품질

```bash
# 포맷 일괄 적용
make fmt

# 정적 분석 (make configure 로 compile_commands.json 생성 후)
make lint

# 메모리 안전성 런타임 검사
make sanitize
```

## 테스트

```bash
make test                           # CTest 전체 실행 (병렬)
make test BUILD_TYPE=Release        # Release 모드 테스트

# 직접 실행:
ctest --test-dir build/debug --output-on-failure -R <test_pattern>
```

## 빌드 & 배포

### Docker 이미지 빌드

```bash
make dev-build                      # 이미지 빌드 + 기동 (dev 환경)
# 또는:
docker compose --profile app build
docker compose --profile app up -d
```

> Dockerfile: ubuntu:24.04(build stage) → debian:bookworm-slim(runtime).
> 빌드 의존성(vcpkg/CMake)은 runtime 이미지에서 제외.

### Kubernetes (Helm)

```bash
make deploy
# 또는:
helm upgrade --install {{PROJECT_NAME}} ./deploy/helm \
  --set image.tag=$(git rev-parse --short HEAD)
```

## 디렉터리 구조

```
{{PROJECT_NAME}}/
├── src/
│   ├── main.cpp              # 진입점 (Drogon 앱 초기화)
│   ├── handlers/             # HTTP 핸들러
│   ├── services/             # 비즈니스 로직
│   └── models/               # 도메인 모델
├── include/
│   └── {{PROJECT_NAME}}/     # 공개 헤더
├── test/                     # 모든 테스트는 test/ 로 통일
│   ├── unit/                 # GTest 유닛 테스트
│   ├── dev-env/              # 시험표준: 환경 검증 시나리오
│   └── impl/                 # 시험표준: 구현 이터레이션별 시나리오·결과
├── deploy/helm/              # Helm 차트
├── .github/workflows/        # CI 파이프라인
├── CMakeLists.txt            # CMake 루트
├── CMakePresets.json         # 빌드 프리셋 (debug/release)
├── vcpkg.json                # 의존성 매니페스트
├── Procfile.dev              # goreman 멀티프로세스 정의
├── docker-compose.yml        # 인프라 + app(profiles:app)
├── Dockerfile                # 멀티스테이지 (build → slim runtime)
├── .clang-format             # 포맷 규칙
├── .env.local                # 로컬 환경변수 (SQLite)
└── Makefile
```

## 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| `cmake: No such preset` | CMakePresets.json 없음 또는 CMake < 3.21 | `make preflight` 로 버전 확인 |
| `VCPKG_ROOT not set` | vcpkg 환경변수 미설정 | `export VCPKG_ROOT=/path/to/vcpkg` |
| `vcpkg install` 실패 | 시스템 라이브러리 미설치 | `apt install build-essential libssl-dev libpq-dev` |
| `undefined reference to ...` | 링크 의존성 누락 | `CMakeLists.txt` 의 `target_link_libraries` 확인 |
| 바이너리 실행 안 됨 | `make build` 미실행 | `make build` 후 재시도 |
| AddressSanitizer 크래시 | 메모리 버그 감지 | `make sanitize` 출력 스택 트레이스 확인 |
| Docker 이미지 빌드 느림 | vcpkg 소스 컴파일 | Docker BuildKit 캐시 레이어 활용 (`DOCKER_BUILDKIT=1`) |

## 다음 단계

- PRD 구현: `/wise-dev-std:implement`
- 코드 리뷰: `/wise-dev-std:review`
- 요구사항 추가: `/wise-dev-std:req-update`
