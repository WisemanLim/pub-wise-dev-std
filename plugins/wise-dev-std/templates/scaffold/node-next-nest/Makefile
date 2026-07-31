# {{PROJECT_NAME}} — node-next-nest (정적 템플릿 / static scaffold template)
.PHONY: dev test build deploy up down dc-logs dc-ps ps preflight \
        local-all local-logs local-stop local-restart \
        dev-all dev-build dev-logs dev-stop dev-restart \
        staging-all staging-build staging-logs staging-stop staging-restart \
        prod-all prod-build prod-logs prod-stop prod-restart
ENV ?= local
ENV_FILE := $(wildcard .env.$(ENV))
DC := docker compose $(if $(ENV_FILE),--env-file $(ENV_FILE),)   # .env.$(ENV) 존재 시 포트/IP/계정 주입
PM ?= pnpm exec pm2
# local 모드에서 기동할 compose 서비스만 지정 (비워두면 전체 infra).
# SQLite 사용 시 postgres 불필요 → 예: LOCAL_INFRA=redis make local-all
LOCAL_INFRA ?=

## --- 사전 호환성 점검 / Preflight (env-init 전 실행 권장) ---
preflight:  ## 런타임·도구 버전 호환성 점검
	@echo "=== Preflight: node-next-nest ==="
	@command -v node   >/dev/null 2>&1 || (echo "FAIL: Node.js 미설치" && exit 1)
	@command -v pnpm   >/dev/null 2>&1 || (echo "FAIL: pnpm 미설치 — corepack enable 또는 npm i -g pnpm" && exit 1)
	@command -v docker >/dev/null 2>&1 || (echo "FAIL: Docker 미설치" && exit 1)
	@$(DC) version >/dev/null 2>&1 || (echo "FAIL: docker compose v2 필요 (docker-compose v1 아님)" && exit 1)
	@node -e "const v=+process.version.slice(1).split('.')[0]; if(v<22){console.error('FAIL: Node '+process.version+' — 22+ 필요 (corepack/pnpm 호환)');process.exit(1)}" || exit 1
	@pnpm --version | awk -F. '{if($$1+0<9) print "WARN: pnpm " $$0 " — 9+ 권장"}'
	@echo "=== Preflight OK ==="

## --- infra (DB/캐시, app 제외) ---
up:    ## docker infra 기동 (postgres/redis — app 컨테이너 제외)
	$(DC) up -d
down:  ## infra 정리
	$(DC) down --remove-orphans

## --- docker-compose 공통 유틸 ---
dc-logs:  ## $(DC) 로그 추적 (SVC=<service> 로 특정 서비스 지정)
	$(DC) logs -f $(SVC)
dc-ps:    ## $(DC) 컨테이너 상태
	$(DC) ps

## --- local 직접 실행 (포그라운드, 단일 프로세스) ---
dev:    ## 호스트 직접 실행 (포그라운드) / host run (워크스페이스 인식)
	pnpm -r dev
test:   ; pnpm -r test
build:  ; pnpm -r build
deploy: ; helm upgrade --install {{PROJECT_NAME}} ./deploy/helm

ps:  ## PM2 프로세스 상태
	$(PM) ls

## --- local-all: infra + PM2 한 번에 기동 (백그라운드 데몬) ---
local-all:      ## [local] infra(docker) + PM2 일괄 기동 / docker up + managed procs
	$(DC) up -d $(LOCAL_INFRA)
	$(PM) start ecosystem.config.cjs
local-logs:     ## [local] PM2 통합 로그 추적 (Ctrl-C 로 tail 종료 — 프로세스는 유지)
	$(PM) logs
local-stop:     ## [local] PM2 종료 + infra 정리
	$(PM) delete ecosystem.config.cjs || true
	$(DC) down --remove-orphans
local-restart:  ## [local] PM2 재기동 (infra 유지)
	$(PM) restart ecosystem.config.cjs

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
prod-build:    ## [prod] 이미지 빌드 후 기동
	docker compose --env-file .env.prod --profile app up -d --build
prod-logs:     ## [prod] 컨테이너 로그 추적 (SVC=<service>)
	docker compose --env-file .env.prod --profile app logs -f $(SVC)
prod-stop:     ## [prod] app + infra 전체 정리
	docker compose --env-file .env.prod --profile app down --remove-orphans
prod-restart:  ## [prod] 컨테이너 재기동 (SVC=<service>, 비우면 전체)
	docker compose --env-file .env.prod --profile app restart $(SVC)
