# {{PROJECT_NAME}} — python-fastapi (정적 템플릿 / static scaffold template)
# 표준 타겟 / standard targets (모든 환경 동일 네이밍):
#   make <env>-all | <env>-build | <env>-logs | <env>-stop | <env>-restart | <env>-ps   env = local | dev | staging | prod
#   make db-migrate | db-seed | db-reset | db-fresh [ENV=<env>]     make test | deploy | preflight | help
.PHONY: help preflight test deploy \
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
PROC_MGR ?= honcho   # honcho(기본) | pm2(npx, Node 필요)
HONCHO   ?= uv run honcho -f Procfile.dev
PM2      ?= npx --yes pm2
MIGRATE  ?= uv run alembic upgrade head
SEED     ?= uv run python -m app.seed
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
	@echo "=== Preflight: python-fastapi ==="
	@command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1 || (echo "FAIL: Python 미설치" && exit 1)
	@command -v uv >/dev/null 2>&1 || (echo "FAIL: uv 미설치 — brew install uv 또는 curl -LsSf https://astral.sh/uv/install.sh | sh" && exit 1)
	@command -v docker >/dev/null 2>&1 || (echo "FAIL: Docker 미설치" && exit 1)
	@docker compose version >/dev/null 2>&1 || (echo "FAIL: docker compose v2 필요 (docker-compose v1 아님)" && exit 1)
	@python3 -c "import sys; v=sys.version_info; exit(0 if v>=(3,11) else 1)" 2>/dev/null || \
	 python  -c "import sys; v=sys.version_info; exit(0 if v>=(3,11) else 1)" 2>/dev/null || \
	 (echo "FAIL: Python 3.11+ 필요 (현재: $$(python3 --version 2>/dev/null || python --version))" && exit 1)
	@if [ "$(PROC_MGR)" = "pm2" ]; then command -v node >/dev/null 2>&1 || echo "WARN: Node 미설치 — PROC_MGR=pm2 사용 시 필요 (npx pm2)"; fi
	@echo "=== Preflight OK ==="

## --- 공통 / common ---
test:    ## 테스트 실행
	uv run pytest
deploy:  ## K8s 배포 (Helm)
	helm upgrade --install {{PROJECT_NAME}} ./deploy/helm

## --- local: infra(docker) + 호스트 프로세스 매니저 (honcho 기본 · PROC_MGR=pm2 대안) ---
local-build:    ## [local] 의존성 설치/호스트 빌드
	uv sync
HONCHO_PIDFILE := .make/honcho.pid
HONCHO_LOGFILE := .make/honcho.log
local-all:      ## [local] infra(docker) + web/worker 일괄 기동 (백그라운드, PROC_MGR=honcho|pm2)
	docker compose $(if $(wildcard .env.local),--env-file .env.local,) up -d $(LOCAL_INFRA)
	@mkdir -p .make
ifeq ($(PROC_MGR),pm2)
	$(PM2) start ecosystem.config.cjs
else
	@if [ -f $(HONCHO_PIDFILE) ] && kill -0 $$(cat $(HONCHO_PIDFILE)) 2>/dev/null; then \
	  echo "honcho 이미 실행 중 (pid $$(cat $(HONCHO_PIDFILE)))"; \
	else \
	  nohup $(HONCHO) start > $(HONCHO_LOGFILE) 2>&1 & echo $$! > $(HONCHO_PIDFILE); \
	  echo "honcho 백그라운드 기동 (pid $$(cat $(HONCHO_PIDFILE)), 로그: $(HONCHO_LOGFILE))"; \
	fi
endif
local-logs:     ## [local] 통합 로그 추적 (Ctrl-C 로 tail 종료 — 프로세스는 유지)
ifeq ($(PROC_MGR),pm2)
	$(PM2) logs
else
	@touch $(HONCHO_LOGFILE) && tail -f $(HONCHO_LOGFILE)
endif
local-stop:     ## [local] web/worker 중지 + infra 정리
ifeq ($(PROC_MGR),pm2)
	$(PM2) delete ecosystem.config.cjs || true
else
	@if [ -f $(HONCHO_PIDFILE) ]; then kill $$(cat $(HONCHO_PIDFILE)) 2>/dev/null || true; rm -f $(HONCHO_PIDFILE); fi
endif
	docker compose $(if $(wildcard .env.local),--env-file .env.local,) down --remove-orphans
local-restart:  ## [local] web/worker 재기동 (infra 유지)
ifeq ($(PROC_MGR),pm2)
	$(PM2) restart ecosystem.config.cjs
else
	@if [ -f $(HONCHO_PIDFILE) ]; then kill $$(cat $(HONCHO_PIDFILE)) 2>/dev/null || true; rm -f $(HONCHO_PIDFILE); fi
	@mkdir -p .make; nohup $(HONCHO) start > $(HONCHO_LOGFILE) 2>&1 & echo $$! > $(HONCHO_PIDFILE)
	@echo "honcho 재기동 (pid $$(cat $(HONCHO_PIDFILE)))"
endif
local-ps:       ## [local] 프로세스 상태 (pm2 ls / honcho check)
ifeq ($(PROC_MGR),pm2)
	$(PM2) ls
else
	$(HONCHO) check
endif

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
