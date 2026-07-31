# {{PROJECT_NAME}} — custom stack (정적 템플릿 / static scaffold template)
# 이 Makefile 은 resolve 단계에서 base_profile Makefile 로 교체됩니다.
# 아래는 모든 base_profile 에 공통된 인프라 타겟만 포함한 폴백입니다.
.PHONY: up down dc-logs dc-ps dev test build deploy ps preflight \
        local-all local-logs local-stop local-restart \
        dev-all dev-build dev-logs dev-stop dev-restart \
        staging-all staging-build staging-logs staging-stop staging-restart \
        prod-all prod-build prod-logs prod-stop prod-restart
ENV ?= local
ENV_FILE := $(wildcard .env.$(ENV))
DC := docker compose $(if $(ENV_FILE),--env-file $(ENV_FILE),)   # .env.$(ENV) 존재 시 포트/IP/계정 주입
LOCAL_INFRA ?=

## --- 사전 호환성 점검 / Preflight (env-init 전 실행 권장) ---
preflight:  ## 런타임·도구 버전 호환성 점검 (base_profile 교체 후 보완 필요)
	@echo "=== Preflight: custom ==="
	@command -v docker >/dev/null 2>&1 || (echo "FAIL: Docker 미설치" && exit 1)
	@$(DC) version >/dev/null 2>&1 || (echo "FAIL: docker compose v2 필요" && exit 1)
	@echo "=== Preflight OK (base_profile Makefile 교체 후 언어별 점검 추가) ==="

## --- infra (DB/캐시) ---
up infra-up:  ## docker infra 기동 (compose fragments 에 따라 확장)
	$(DC) up -d
down infra-down:  ## infra 정리
	$(DC) down --remove-orphans

## --- docker-compose 공통 유틸 ---
dc-logs:  ## $(DC) 로그 추적 (SVC=<service> 로 특정 서비스 지정)
	$(DC) logs -f $(SVC)
dc-ps:    ## $(DC) 컨테이너 상태
	$(DC) ps

## --- local 멀티프로세스 (base_profile 교체 후 활성화) ---
# 표준 매니저: node=PM2(ecosystem.config.cjs) · python=honcho(대안 PROC_MGR=pm2) · go/java/c#/c++=goreman · rust=overmind (Procfile.dev)
ps:  ## [local] 프로세스 상태
	@echo "base_profile Makefile 교체 후 활성화 (컨테이너 상태는 make dc-ps)"

## --- local-all/logs/stop/restart (base_profile 교체 후 활성화) ---
local-all:      ## [local] infra + 프로세스 매니저 일괄 기동 (base_profile 교체 후 보완)
	$(DC) up -d $(LOCAL_INFRA)
	@echo "base_profile Makefile 교체 후 프로세스 매니저 기동 명령 추가"
local-logs:     ; @echo "base_profile Makefile 교체 후 활성화"
local-stop:     ## [local] 프로세스 종료 + infra 정리
	$(DC) down --remove-orphans
local-restart:  ; @echo "base_profile Makefile 교체 후 활성화"

## --- dev/staging/prod: Docker 전체 스택 ---
dev-all:          ; docker compose --env-file .env.dev --profile app up -d
dev-build:        ; docker compose --env-file .env.dev --profile app up -d --build
dev-logs:         ; docker compose --env-file .env.dev --profile app logs -f $(SVC)
dev-stop:         ; docker compose --env-file .env.dev --profile app down --remove-orphans
dev-restart:      ; docker compose --env-file .env.dev --profile app restart $(SVC)

staging-all:      ; docker compose --env-file .env.staging --profile app up -d
staging-build:    ; docker compose --env-file .env.staging --profile app up -d --build
staging-logs:     ; docker compose --env-file .env.staging --profile app logs -f $(SVC)
staging-stop:     ; docker compose --env-file .env.staging --profile app down --remove-orphans
staging-restart:  ; docker compose --env-file .env.staging --profile app restart $(SVC)

prod-all:         ; docker compose --env-file .env.prod --profile app up -d
prod-build:       ; docker compose --env-file .env.prod --profile app up -d --build
prod-logs:        ; docker compose --env-file .env.prod --profile app logs -f $(SVC)
prod-stop:        ; docker compose --env-file .env.prod --profile app down --remove-orphans
prod-restart:     ; docker compose --env-file .env.prod --profile app restart $(SVC)

## --- app 실행 (base_profile 교체 후 활성화) ---
dev:
	@echo "base_profile Makefile 로 교체 후 실행"
test:
	@echo "base_profile Makefile 로 교체 후 실행"
build:
	$(DC) build
deploy:
	helm upgrade --install {{PROJECT_NAME}} ./deploy/helm
