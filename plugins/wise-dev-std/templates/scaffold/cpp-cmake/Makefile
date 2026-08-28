# {{PROJECT_NAME}} — cpp-cmake (정적 템플릿 / static scaffold template)
# 표준 타겟 / standard targets (모든 환경 동일 네이밍):
#   make <env>-all | <env>-build | <env>-logs | <env>-stop | <env>-restart | <env>-ps   env = local | dev | staging | prod
#   make db-migrate | db-seed | db-reset | db-fresh [ENV=<env>]     make test | deploy | preflight | help
.PHONY: help preflight test deploy fmt lint sanitize clean \
        local-all local-build local-logs local-stop local-restart local-ps \
        $(foreach e,dev staging prod,$(e)-all $(e)-build $(e)-logs $(e)-stop $(e)-restart $(e)-ps) \
        db-migrate db-seed db-reset db-fresh
ENV  ?= local
ENVS := dev staging prod
# compose 호출: .env.<env> 있으면 주입, app 프로파일 포함 (컨테이너 전체 스택)
DC   = docker compose $(if $(wildcard .env.$(ENV)),--env-file .env.$(ENV),) --profile app
DCE  = docker compose $(if $(wildcard .env.$*),--env-file .env.$*,) --profile app
# .env.<ENV> 를 셸 환경으로 로드 후 명령 실행 (host 측 migrate/seed 용)
WITH_ENV = { [ -f .env.$(ENV) ] && set -a && . ./.env.$(ENV) && set +a || true; } &&
# local 모드에서 기동할 infra 서비스만 지정 (비우면 전체). SQLite 사용 시 예: LOCAL_INFRA=redis make local-all
LOCAL_INFRA ?=
SQLITE_DB   ?= local.db
BUILD_TYPE ?= Debug        # Debug | Release | RelWithDebInfo
BUILD_DIR  ?= build/$(shell echo $(BUILD_TYPE) | tr '[:upper:]' '[:lower:]')
BINARY     ?= $(BUILD_DIR)/{{PROJECT_NAME}}
GOREMAN    ?= goreman -f Procfile.dev
MIGRATE    ?= echo "MIGRATE 미설정 — Makefile MIGRATE 변수에 마이그레이션 명령 지정"
SEED       ?= echo "SEED 미설정 — Makefile SEED 변수에 시드 명령 지정"
help:  ## 타겟 목록
	@grep -hE '^[a-z][a-z-]*:.*## ' $(MAKEFILE_LIST) | sed -E 's/:[^#]*##/\t/' | awk -F'\t' '{printf "  %-16s %s\n", $$1, $$2}'
	@echo "  <env>-all        [dev|staging|prod] infra + app 컨테이너 기동 (기존 이미지)"
	@echo "  <env>-build      [dev|staging] 이미지 재빌드 후 기동 (prod 미제공 — CI/CD 산출물)"
	@echo "  <env>-logs       [dev|staging|prod] 컨테이너 로그 추적 (SVC=<service>)"
	@echo "  <env>-stop       [dev|staging|prod] app + infra 전체 정리"
	@echo "  <env>-restart    [dev|staging|prod] 컨테이너 재기동 (SVC=<service>)"
	@echo "  <env>-ps         [dev|staging|prod] 컨테이너 상태"
	@echo "  db-* 는 ENV=<env> 로 대상 지정 (기본 local)"

## --- 사전 호환성 점검 / Preflight (env-init 전 실행 권장) ---
preflight:  ## 런타임·도구 버전 호환성 점검
	@echo "=== Preflight: cpp-cmake ==="
	@command -v cmake >/dev/null 2>&1 || (echo "FAIL: CMake 미설치 — brew install cmake 또는 apt install cmake" && exit 1)
	@command -v c++ >/dev/null 2>&1 || command -v g++ >/dev/null 2>&1 || command -v clang++ >/dev/null 2>&1 || \
	  (echo "FAIL: C++ 컴파일러 미설치 — brew install llvm 또는 apt install g++" && exit 1)
	@command -v docker >/dev/null 2>&1 || (echo "FAIL: Docker 미설치" && exit 1)
	@docker compose version >/dev/null 2>&1 || (echo "FAIL: docker compose v2 필요 (docker-compose v1 아님)" && exit 1)
	@cmake --version | awk 'NR==1{split($$3,v,"."); if(v[1]+0<3||(v[1]+0==3&&v[2]+0<21)) print "WARN: CMake 3.21+ 권장 (현재: " $$3 ")"}'
	@command -v ninja >/dev/null 2>&1 || echo "WARN: ninja 미설치 — brew install ninja (빌드 가속)"
	@command -v vcpkg >/dev/null 2>&1 || echo "WARN: vcpkg 미설치 — https://vcpkg.io (VCPKG_ROOT)"
	@command -v goreman >/dev/null 2>&1 || echo "WARN: goreman 미설치 — go install github.com/mattn/goreman@latest (make local-all 필요)"
	@echo "=== Preflight OK ==="

## --- 공통 / common ---
test:    ## 테스트 실행
	cmake --build $(BUILD_DIR) --target test 2>/dev/null || \
	  ctest --test-dir $(BUILD_DIR) --output-on-failure --parallel
deploy:  ## K8s 배포 (Helm)
	helm upgrade --install {{PROJECT_NAME}} ./deploy/helm

## --- local: infra(docker) + 호스트 프로세스 매니저 (goreman) ---
local-build:    ## [local] 의존성 설치/호스트 빌드
	cmake --preset $(shell echo $(BUILD_TYPE) | tr '[:upper:]' '[:lower:]') -B $(BUILD_DIR) && cmake --build $(BUILD_DIR) --parallel
GOREMAN_PIDFILE := .make/goreman.pid
GOREMAN_LOGFILE := .make/goreman.log
local-all:      ## [local] infra(docker) + goreman 일괄 기동 (백그라운드)
	docker compose $(if $(wildcard .env.local),--env-file .env.local,) up -d $(LOCAL_INFRA)
	$(MAKE) local-build
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
	docker compose $(if $(wildcard .env.local),--env-file .env.local,) down --remove-orphans
local-restart:  ## [local] goreman 재기동 (infra 유지)
	@goreman run restart-all 2>/dev/null || true
local-ps:       ## [local] 프로세스 상태
	@goreman run status 2>/dev/null || echo "먼저 make local-all"

## --- 코드 품질 (cpp 전용) ---
fmt:      ## clang-format 적용 (src/ include/)
	find src include -name '*.cpp' -o -name '*.hpp' -o -name '*.h' 2>/dev/null | xargs clang-format -i
lint:     ## clang-tidy 정적 분석 (make local-build 후)
	run-clang-tidy -p $(BUILD_DIR) src/ 2>/dev/null || echo "run-clang-tidy 없음 — brew install llvm"
sanitize: ## ASan + UBSan 빌드·실행
	cmake -B build/sanitize -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS="-fsanitize=address,undefined -fno-omit-frame-pointer"
	cmake --build build/sanitize --parallel && build/sanitize/{{PROJECT_NAME}}
clean:    ## 빌드 결과물 제거
	rm -rf build/

## --- dev/staging/prod: Docker 전체 스택 (.env.<env> + app 프로파일) ---
$(ENVS:%=%-all):     %-all:      # [<env>] infra + app 컨테이너 기동 (기존 이미지)
	$(DCE) up -d
$(filter-out prod-build,$(ENVS:%=%-build)): %-build:  # [dev|staging] 이미지 재빌드 후 기동 (prod 는 CI/CD 산출물 — 미제공)
	$(DCE) up -d --build
$(ENVS:%=%-logs):    %-logs:     # [<env>] 컨테이너 로그 추적 (SVC=<service>)
	$(DCE) logs -f $(SVC)
$(ENVS:%=%-stop):    %-stop:     # [<env>] app + infra 전체 정리
	$(DCE) down --remove-orphans
$(ENVS:%=%-restart): %-restart:  # [<env>] 컨테이너 재기동 (SVC=<service>, 비우면 전체)
	$(DCE) restart $(SVC)
$(ENVS:%=%-ps):      %-ps:       # [<env>] 컨테이너 상태
	$(DCE) ps
prod-build:
	@echo "prod-build 미제공 — prod 이미지는 CI/CD 파이프라인 산출물을 사용 (make prod-all)"; exit 1

## --- DB (ENV=local|dev|staging|prod, 기본 local) ---
db-migrate:  ## 마이그레이션 적용 (MIGRATE 변수)
	$(WITH_ENV) $(MIGRATE)
db-seed:     ## 시드 데이터 적재 (SEED 변수)
	$(WITH_ENV) $(SEED)
db-reset:    ## DB 스키마 초기화 + 마이그레이션 (local=SQLite 파일 삭제 · 그 외=postgres schema 재생성) — 데이터 삭제!
ifeq ($(ENV),prod)
	@echo "prod DB reset 금지"; exit 1
else ifeq ($(ENV),local)
	rm -f $(SQLITE_DB)
else
	$(DC) exec -T postgres sh -c 'psql -U "$$POSTGRES_USER" -d "$$POSTGRES_DB" -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"'
endif
	$(MAKE) db-migrate ENV=$(ENV)
db-fresh: db-reset  ## db-reset + 시드 적재
	$(MAKE) db-seed ENV=$(ENV)
