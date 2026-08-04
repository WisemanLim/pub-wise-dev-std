# {{PROJECT_NAME}} — rust-axum (정적 템플릿 / static scaffold template)
.PHONY: dev test build deploy up down dc-logs dc-ps ps preflight \
        local-all local-logs local-stop local-restart \
        dev-all dev-build dev-logs dev-stop dev-restart \
        staging-all staging-build staging-logs staging-stop staging-restart \
        prod-all prod-logs prod-stop prod-restart \
        local-down dev-down staging-down prod-down
ENV ?= local
ENV_FILE := $(wildcard .env.$(ENV))
DC := docker compose $(if $(ENV_FILE),--env-file $(ENV_FILE),)   # .env.$(ENV) 존재 시 포트/IP/계정 주입
OVERMIND ?= overmind
OVERMIND_PIDFILE := .make/overmind.pid
OVERMIND_LOGFILE := .make/overmind.log
# local 모드에서 기동할 compose 서비스만 지정 (비워두면 전체 infra).
# SQLite 사용 시 postgres 불필요 → 예: LOCAL_INFRA=redis make local-all
LOCAL_INFRA ?=

## --- 사전 호환성 점검 / Preflight (env-init 전 실행 권장) ---
preflight:  ## 런타임·도구 버전 호환성 점검
	@echo "=== Preflight: rust-axum ==="
	@command -v rustc  >/dev/null 2>&1 || (echo "FAIL: Rust 미설치 — curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh" && exit 1)
	@command -v cargo  >/dev/null 2>&1 || (echo "FAIL: cargo 미설치" && exit 1)
	@command -v docker >/dev/null 2>&1 || (echo "FAIL: Docker 미설치" && exit 1)
	@$(DC) version >/dev/null 2>&1 || (echo "FAIL: docker compose v2 필요 (docker-compose v1 아님)" && exit 1)
	@rustc --version | awk '{print "Rust: " $$2}'
	@command -v overmind >/dev/null 2>&1 || echo "WARN: overmind 미설치 — brew install overmind (make local-all 필요 시, tmux 필요)"
	@command -v cargo-watch >/dev/null 2>&1 || echo "WARN: cargo-watch 미설치 — cargo install cargo-watch (핫리로드 필요 시)"
	@echo "=== Preflight OK ==="

## --- infra (DB/캐시, app 제외) ---
up:    ## docker infra 기동 (postgres/redis — app 컨테이너 제외)
	$(DC) up -d
down:  ## infra 전체 정리
	$(DC) --profile app down --remove-orphans

## --- docker-compose 공통 유틸 ---
dc-logs:  ## $(DC) 로그 추적 (SVC=<service> 로 특정 서비스 지정)
	$(DC) logs -f $(SVC)
dc-ps:    ## $(DC) 컨테이너 상태
	$(DC) ps

## --- local 직접 실행 (포그라운드, 단일 프로세스) ---
dev:    ; cargo run
test:   ; cargo test
build:  ; $(DC) --profile app build
deploy: ; helm upgrade --install {{PROJECT_NAME}} ./deploy/helm

ps:  ## overmind 프로세스 상태
	$(OVERMIND) ps || echo "먼저 make local-all"

## --- local-all: infra + overmind(server+worker) 한 번에 기동 (백그라운드, 핫리로드) ---
local-all:      ## [local] infra(docker) + overmind 일괄 기동 (백그라운드)
	$(DC) up -d $(LOCAL_INFRA)
	@mkdir -p .make
	@if [ -f $(OVERMIND_PIDFILE) ] && kill -0 $$(cat $(OVERMIND_PIDFILE)) 2>/dev/null; then \
	  echo "overmind 이미 실행 중 (pid $$(cat $(OVERMIND_PIDFILE)))"; \
	else \
	  nohup $(OVERMIND) start -f Procfile.dev > $(OVERMIND_LOGFILE) 2>&1 & echo $$! > $(OVERMIND_PIDFILE); \
	  echo "overmind 백그라운드 기동 (pid $$(cat $(OVERMIND_PIDFILE)), 로그: $(OVERMIND_LOGFILE))"; \
	fi
local-logs:     ## [local] 통합 로그 추적 (Ctrl-C 로 tail 종료 — 프로세스는 유지)
	@touch $(OVERMIND_LOGFILE) && tail -f $(OVERMIND_LOGFILE)
local-stop:     ## [local] overmind 종료 + infra 정리
	$(OVERMIND) stop || true
	@if [ -f $(OVERMIND_PIDFILE) ]; then kill $$(cat $(OVERMIND_PIDFILE)) 2>/dev/null || true; rm -f $(OVERMIND_PIDFILE); fi
	$(DC) down --remove-orphans
local-restart:  ## [local] overmind 재기동 (infra 유지)
	$(OVERMIND) restart web || true

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
