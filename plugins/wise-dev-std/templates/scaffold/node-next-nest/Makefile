# {{PROJECT_NAME}} — node-next-nest (정적 템플릿 / static scaffold template)
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
PM      ?= pnpm exec pm2
MIGRATE ?= pnpm -C apps/api exec prisma migrate deploy
SEED    ?= pnpm -C apps/api exec prisma db seed
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
	@echo "=== Preflight: node-next-nest ==="
	@command -v node >/dev/null 2>&1 || (echo "FAIL: Node.js 미설치" && exit 1)
	@command -v pnpm >/dev/null 2>&1 || (echo "FAIL: pnpm 미설치 — corepack enable 또는 npm i -g pnpm" && exit 1)
	@command -v docker >/dev/null 2>&1 || (echo "FAIL: Docker 미설치" && exit 1)
	@docker compose version >/dev/null 2>&1 || (echo "FAIL: docker compose v2 필요 (docker-compose v1 아님)" && exit 1)
	@node -e "const v=+process.version.slice(1).split('.')[0]; if(v<22){console.error('FAIL: Node '+process.version+' — 22+ 필요');process.exit(1)}" || exit 1
	@pnpm --version | awk -F. '{if($$1+0<9) print "WARN: pnpm " $$0 " — 9+ 권장"}'
	@echo "=== Preflight OK ==="

## --- 공통 / common ---
test:    ## 테스트 실행
	pnpm -r test
deploy:  ## K8s 배포 (Helm)
	helm upgrade --install {{PROJECT_NAME}} ./deploy/helm

## --- local: infra(docker) + 호스트 프로세스 매니저 (PM2) ---
local-build:    ## [local] 의존성 설치/호스트 빌드
	pnpm install && pnpm -r build
local-all:      ## [local] infra(docker) + PM2 일괄 기동 (백그라운드 데몬)
	docker compose $(if $(wildcard .env.local),--env-file .env.local,) up -d $(LOCAL_INFRA)
	$(PM) start ecosystem.config.cjs
local-logs:     ## [local] PM2 통합 로그 추적 (Ctrl-C 로 종료 — 프로세스는 유지)
	$(PM) logs
local-stop:     ## [local] PM2 종료 + infra 정리
	$(PM) delete ecosystem.config.cjs || true
	docker compose $(if $(wildcard .env.local),--env-file .env.local,) down --remove-orphans
local-restart:  ## [local] PM2 재기동 (infra 유지)
	$(PM) restart ecosystem.config.cjs
local-ps:       ## [local] PM2 프로세스 상태
	$(PM) ls

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
