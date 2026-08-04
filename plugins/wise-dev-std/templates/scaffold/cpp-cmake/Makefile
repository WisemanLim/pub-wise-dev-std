# {{PROJECT_NAME}} — cpp-cmake (정적 템플릿 / static scaffold template)
.PHONY: configure build clean dev test deploy up down dc-logs dc-ps ps \
        local-all local-logs local-stop local-restart \
        dev-all dev-build dev-logs dev-stop dev-restart \
        staging-all staging-build staging-logs staging-stop staging-restart \
        prod-all prod-logs prod-stop prod-restart \
        preflight sanitize fmt lint
ENV        ?= local
BUILD_TYPE ?= Debug        # Debug | Release | RelWithDebInfo
BUILD_DIR  ?= build/$(shell echo $(BUILD_TYPE) | tr '[:upper:]' '[:lower:]')
BINARY     ?= $(BUILD_DIR)/{{PROJECT_NAME}}
GOREMAN    ?= goreman -f Procfile.dev
GOREMAN_PIDFILE := .make/goreman.pid
GOREMAN_LOGFILE := .make/goreman.log
# local 모드에서 기동할 compose 서비스만 지정 (비워두면 전체 infra).
# SQLite 사용 시 postgres 불필요 → 예: LOCAL_INFRA=redis make local-all
LOCAL_INFRA ?=

## --- 사전 호환성 점검 / Preflight (env-init 전 실행 권장) ---
preflight:  ## 런타임·도구 버전 호환성 점검
	@echo "=== Preflight: cpp-cmake ==="
	@command -v cmake    >/dev/null 2>&1 || (echo "FAIL: CMake 미설치 — brew install cmake 또는 apt install cmake" && exit 1)
	@command -v c++      >/dev/null 2>&1 || command -v g++ >/dev/null 2>&1 || command -v clang++ >/dev/null 2>&1 || \
	  (echo "FAIL: C++ 컴파일러 미설치 — brew install llvm 또는 apt install g++" && exit 1)
	@command -v docker   >/dev/null 2>&1 || (echo "FAIL: Docker 미설치" && exit 1)
	@docker compose version >/dev/null 2>&1 || (echo "FAIL: docker compose v2 필요 (docker-compose v1 아님)" && exit 1)
	@cmake --version | awk 'NR==1{split($$3,v,"."); if(v[1]+0<3||(v[1]+0==3&&v[2]+0<21)) \
	  print "WARN: CMake 3.21+ 권장 (현재: " $$3 ") — brew install cmake"}'
	@command -v ninja    >/dev/null 2>&1 || echo "WARN: ninja 미설치 — brew install ninja (빌드 가속 권장)"
	@command -v vcpkg    >/dev/null 2>&1 || echo "WARN: vcpkg 미설치 — https://vcpkg.io (의존성 관리 시 VCPKG_ROOT 설정 필요)"
	@command -v clangd   >/dev/null 2>&1 || echo "INFO: clangd 미설치 — brew install llvm (IDE/LSP 지원)"
	@command -v clang-format >/dev/null 2>&1 || echo "INFO: clang-format 미설치 — brew install llvm (make fmt 필요 시)"
	@command -v goreman  >/dev/null 2>&1 || echo "WARN: goreman 미설치 — go install github.com/mattn/goreman@latest (make local-all 필요 시)"
	@echo "=== Preflight OK ==="

## --- CMake 빌드 ---
configure:  ## CMake 구성 (BUILD_TYPE=Debug|Release, CMakePresets.json 사용)
	cmake --preset $(shell echo $(BUILD_TYPE) | tr '[:upper:]' '[:lower:]') -B $(BUILD_DIR)

build: configure  ## 컴파일 (cmake --build, 병렬)
	cmake --build $(BUILD_DIR) --parallel

clean:  ## 빌드 결과물 제거
	rm -rf build/

## --- infra (DB/캐시, app 제외) ---
up:    ## docker infra 기동 (postgres/redis — app 컨테이너 제외)
	docker compose up -d
down:  ## infra 전체 정리
	docker compose --profile app down --remove-orphans

## --- docker-compose 공통 유틸 ---
dc-logs:  ## docker compose 로그 추적 (SVC=<service> 로 특정 서비스 지정)
	docker compose logs -f $(SVC)
dc-ps:    ## docker compose 컨테이너 상태
	docker compose ps

## --- local 직접 실행 (포그라운드, 단일 프로세스) ---
dev: build  ## 빌드 후 바이너리 직접 실행 (포그라운드)
	$(BINARY)
test:  ## CTest 실행 (GTest 포함, 병렬)
	cmake --build $(BUILD_DIR) --target test 2>/dev/null || \
	  ctest --test-dir $(BUILD_DIR) --output-on-failure --parallel
deploy: ; helm upgrade --install {{PROJECT_NAME}} ./deploy/helm

## --- 코드 품질 ---
fmt:      ## clang-format 적용 (src/ + include/ 전체, in-place)
	find src include -name '*.cpp' -o -name '*.hpp' -o -name '*.h' 2>/dev/null | \
	  xargs clang-format -i
lint:     ## clang-tidy 정적 분석 (compile_commands.json 필요 — make configure 후 실행)
	run-clang-tidy -p $(BUILD_DIR) src/ 2>/dev/null || \
	  echo "run-clang-tidy 없음 — brew install llvm"
sanitize: ## AddressSanitizer + UBSan 빌드·실행 (메모리 안전성 점검)
	cmake -B build/sanitize -DCMAKE_BUILD_TYPE=Debug \
	  -DCMAKE_CXX_FLAGS="-fsanitize=address,undefined -fno-omit-frame-pointer"
	cmake --build build/sanitize --parallel
	build/sanitize/{{PROJECT_NAME}}

ps:  ## goreman 프로세스 상태
	@goreman run status || echo "먼저 make local-all"

## --- local-all: infra + 빌드 + goreman(server+worker) 한 번에 기동 (백그라운드) ---
local-all:      ## [local] infra(docker) + 빌드 + goreman 일괄 기동 (백그라운드)
	docker compose up -d $(LOCAL_INFRA)
	$(MAKE) build
	@mkdir -p .make
	@if [ -f $(GOREMAN_PIDFILE) ] && kill -0 $$(cat $(GOREMAN_PIDFILE)) 2>/dev/null; then \
	  echo "goreman 이미 실행 중 (pid $$(cat $(GOREMAN_PIDFILE)))"; \
	else \
	  nohup $(GOREMAN) start > $(GOREMAN_LOGFILE) 2>&1 & echo $$! > $(GOREMAN_PIDFILE); \
	  echo "goreman 백그라운드 기동 (pid $$(cat $(GOREMAN_PIDFILE)), 로그: $(GOREMAN_LOGFILE))"; \
	fi
local-logs:     ## [local] 통합 로그 추적 (Ctrl-C 로 tail 종료 — 프로세스는 유지)
	@touch $(GOREMAN_LOGFILE) && tail -f $(GOREMAN_LOGFILE)
local-stop:     ## [local] goreman 종료 + infra 정리
	@goreman run stop-all 2>/dev/null || true
	@if [ -f $(GOREMAN_PIDFILE) ]; then kill $$(cat $(GOREMAN_PIDFILE)) 2>/dev/null || true; rm -f $(GOREMAN_PIDFILE); fi
	docker compose down --remove-orphans
local-restart:  ## [local] goreman 재기동 (infra 유지)
	@goreman run restart-all 2>/dev/null || true

## --- dev: Docker 전체 스택 (.env.dev) ---
dev-all:      ## [dev] infra + app 컨테이너 기동 (기존 이미지 사용)
	docker compose --env-file .env.dev --profile app up -d
dev-build:    ## [dev] 이미지 빌드 후 기동 (코드 변경 후 재빌드 포함)
	docker compose --env-file .env.dev --profile app up -d --build
dev-logs:     ## [dev] 컨테이너 로그 추적 (SVC=<service>)
	docker compose --env-file .env.dev --profile app logs -f $(SVC)
dev-stop:     ## [dev] app + infra 전체 정리
	docker compose --env-file .env.dev --profile app down --remove-orphans
dev-restart:  ## [dev] 컨테이너 재기동 (SVC=<service>, 비우면 전체)
	docker compose --env-file .env.dev --profile app restart $(SVC)

## --- staging: Docker 전체 스택 (.env.staging) ---
staging-all:      ## [staging] infra + app 컨테이너 기동
	docker compose --env-file .env.staging --profile app up -d
staging-build:    ## [staging] 이미지 빌드 후 기동
	docker compose --env-file .env.staging --profile app up -d --build
staging-logs:     ## [staging] 컨테이너 로그 추적 (SVC=<service>)
	docker compose --env-file .env.staging --profile app logs -f $(SVC)
staging-stop:     ## [staging] app + infra 전체 정리
	docker compose --env-file .env.staging --profile app down --remove-orphans
staging-restart:  ## [staging] 컨테이너 재기동 (SVC=<service>, 비우면 전체)
	docker compose --env-file .env.staging --profile app restart $(SVC)

## --- prod: Docker 전체 스택 (.env.prod) ---
prod-all:      ## [prod] infra + app 컨테이너 기동
	docker compose --env-file .env.prod --profile app up -d
prod-logs:     ## [prod] 컨테이너 로그 추적 (SVC=<service>)
	docker compose --env-file .env.prod --profile app logs -f $(SVC)
prod-stop:     ## [prod] app + infra 전체 정리
	docker compose --env-file .env.prod --profile app down --remove-orphans
prod-restart:  ## [prod] 컨테이너 재기동 (SVC=<service>, 비우면 전체)
	docker compose --env-file .env.prod --profile app restart $(SVC)

## --- 하위호환 별칭 / backward-compat aliases (recipe 없이 선행 타겟만 실행) ---
local-down:      local-stop      ## [local] local-stop 별칭 (하위호환)
dev-down:        dev-stop        ## [dev] dev-stop 별칭 (하위호환)
staging-down:    staging-stop    ## [staging] staging-stop 별칭 (하위호환)
prod-down:       prod-stop       ## [prod] prod-stop 별칭 (하위호환)
