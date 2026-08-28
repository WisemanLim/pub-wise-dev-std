# {{PROJECT_NAME}} — custom stack (정적 템플릿 / static scaffold template)
# 이 Makefile 은 resolve 단계에서 base_profile Makefile 로 교체됩니다. 아래는 공통 컨테이너 타겟만 담은 폴백.
# 표준 타겟: make <env>-all|-build|-logs|-stop|-restart|-ps (env=local|dev|staging|prod) · db-* [ENV=] · test · deploy · preflight · help
.PHONY: help preflight test deploy \
        local-all local-build local-logs local-stop local-restart local-ps \
        $(foreach e,dev staging prod,$(e)-all $(e)-build $(e)-logs $(e)-stop $(e)-restart $(e)-ps) \
        db-migrate db-seed db-reset db-fresh
ENV  ?= local
ENVS := dev staging prod
DC   = docker compose $(if $(wildcard .env.$(ENV)),--env-file .env.$(ENV),) --profile app
DCE  = docker compose $(if $(wildcard .env.$*),--env-file .env.$*,) --profile app
WITH_ENV = { [ -f .env.$(ENV) ] && set -a && . ./.env.$(ENV) && set +a || true; } &&
LOCAL_INFRA ?=
SQLITE_DB   ?= local.db
MIGRATE ?= echo "MIGRATE 미설정 — base_profile Makefile 교체 후 지정"
SEED    ?= echo "SEED 미설정 — base_profile Makefile 교체 후 지정"

help:  ## 타겟 목록
	@grep -hE '^[a-z][a-z-]*:.*## ' $(MAKEFILE_LIST) | sed -E 's/:[^#]*##/\t/' | awk -F'\t' '{printf "  %-16s %s\n", $$1, $$2}'
	@echo "  <env>-all|build|logs|stop|restart|ps   [dev|staging|prod] 컨테이너 전체 스택 (prod-build 미제공)"

preflight:  ## 도구 점검 (base_profile 교체 후 언어별 점검 추가)
	@command -v docker >/dev/null 2>&1 || (echo "FAIL: Docker 미설치" && exit 1)
	@docker compose version >/dev/null 2>&1 || (echo "FAIL: docker compose v2 필요" && exit 1)
	@echo "=== Preflight OK (custom) ==="
test:    ; @echo "base_profile Makefile 로 교체 후 실행"
deploy:  ; helm upgrade --install {{PROJECT_NAME}} ./deploy/helm

## --- local (프로세스 매니저는 base_profile 교체 후 활성화) ---
# 표준 매니저: node=PM2(ecosystem.config.cjs) · python=honcho(PROC_MGR=pm2 대안) · go/java/c#/c++=goreman · rust=overmind (Procfile.dev)
local-build:   ; @echo "base_profile Makefile 교체 후 활성화"
local-all:      ## [local] infra 기동 (+프로세스 매니저는 base_profile 교체 후)
	docker compose $(if $(wildcard .env.local),--env-file .env.local,) up -d $(LOCAL_INFRA)
local-logs:    ; @echo "base_profile Makefile 교체 후 활성화 (컨테이너 로그: make dev-logs)"
local-stop:     ## [local] infra 정리
	docker compose $(if $(wildcard .env.local),--env-file .env.local,) down --remove-orphans
local-restart: ; @echo "base_profile Makefile 교체 후 활성화"
local-ps:      ; docker compose ps

## --- dev/staging/prod: Docker 전체 스택 ---
$(ENVS:%=%-all):     %-all:     ; $(DCE) up -d
$(filter-out prod-build,$(ENVS:%=%-build)): %-build: ; $(DCE) up -d --build
$(ENVS:%=%-logs):    %-logs:    ; $(DCE) logs -f $(SVC)
$(ENVS:%=%-stop):    %-stop:    ; $(DCE) down --remove-orphans
$(ENVS:%=%-restart): %-restart: ; $(DCE) restart $(SVC)
$(ENVS:%=%-ps):      %-ps:      ; $(DCE) ps
prod-build: ; @echo "prod-build 미제공 — CI/CD 산출물 사용 (make prod-all)"; exit 1

## --- DB (ENV=local|dev|staging, 기본 local) ---
db-migrate:  ## 마이그레이션 적용 (MIGRATE)
	$(WITH_ENV) $(MIGRATE)
db-seed:     ## 시드 적재 (SEED)
	$(WITH_ENV) $(SEED)
db-reset:    ## 스키마 초기화 + 마이그레이션 — 데이터 삭제!
ifeq ($(ENV),prod)
	@echo "prod DB reset 금지"; exit 1
else ifeq ($(ENV),local)
	rm -f $(SQLITE_DB)
else
	$(DC) exec -T postgres sh -c 'psql -U "$$POSTGRES_USER" -d "$$POSTGRES_DB" -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"'
endif
	$(MAKE) db-migrate ENV=$(ENV)
db-fresh: db-reset  ## db-reset + 시드
	$(MAKE) db-seed ENV=$(ENV)
