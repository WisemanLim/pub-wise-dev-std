# {{PROJECT_NAME}} — cpp-cmake (정적 템플릿 / static scaffold template)
.PHONY: configure build clean dev test deploy up down dc-logs dc-ps \
        run stop restart logs ps local-all local-down dev-all dev-build dev-down \
        preflight sanitize fmt lint
ENV        ?= local
BUILD_TYPE ?= Debug        # Debug | Release | RelWithDebInfo
BUILD_DIR  ?= build/$(shell echo $(BUILD_TYPE) | tr '[:upper:]' '[:lower:]')
BINARY     ?= $(BUILD_DIR)/{{PROJECT_NAME}}
GOREMAN    ?= goreman -f Procfile.dev
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
	@command -v goreman  >/dev/null 2>&1 || echo "WARN: goreman 미설치 — go install github.com/mattn/goreman@latest (make run 필요 시)"
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

## --- local 멀티프로세스 (goreman, Procfile.dev) ---
run: build  ## goreman으로 server(+worker) 동시 기동 (빌드 포함)
	$(GOREMAN) start
stop:    ; goreman run stop-all || true
restart: ; goreman run restart-all || true
logs:    ; @echo "통합 로그는 make run 콘솔. 개별 상태: goreman run status"
ps:      ; goreman run status || echo "먼저 make run (별도 터미널)"

## --- local-all: infra + goreman 한 번에 기동 ---
local-all:   ## [local] infra(docker) + 빌드 + goreman 일괄 기동 / Ctrl-C 로 종료
	docker compose up -d $(LOCAL_INFRA)
	$(MAKE) build
	$(GOREMAN) start
local-down:  ## [local] goreman 종료 + infra 정리
	goreman run stop-all || true
	docker compose down --remove-orphans

## --- dev/staging/prod: Docker 전체 스택 ---
dev-all:    ## [dev] infra + app 컨테이너 기동 (기존 이미지 사용)
	docker compose --profile app up -d
dev-build:  ## [dev] 이미지 빌드 후 기동 (코드 변경 후 재빌드 포함)
	docker compose --profile app up -d --build
dev-down:   ## [dev] app + infra 전체 정리
	docker compose --profile app down --remove-orphans
