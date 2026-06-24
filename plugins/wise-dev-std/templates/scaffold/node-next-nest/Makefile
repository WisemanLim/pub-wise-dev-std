# {{PROJECT_NAME}} — node-next-nest (정적 템플릿 / static scaffold template)
.PHONY: dev test build deploy up down dc-logs dc-ps run stop restart logs ps \
        local-all local-down dev-all dev-build dev-down preflight
ENV ?= local
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
	@docker compose version >/dev/null 2>&1 || (echo "FAIL: docker compose v2 필요 (docker-compose v1 아님)" && exit 1)
	@node -e "const v=+process.version.slice(1).split('.')[0]; if(v<22){console.error('FAIL: Node '+process.version+' — 22+ 필요 (corepack/pnpm 호환)');process.exit(1)}" || exit 1
	@pnpm --version | awk -F. '{if($$1+0<9) print "WARN: pnpm " $$0 " — 9+ 권장"}'
	@echo "=== Preflight OK ==="

## --- infra (DB/캐시, app 제외) ---
up:    ## docker infra 기동 (postgres/redis — app 컨테이너 제외)
	docker compose up -d
down:  ## infra 정리
	docker compose down --remove-orphans

## --- docker-compose 공통 유틸 ---
dc-logs:  ## docker compose 로그 추적 (SVC=<service> 로 특정 서비스 지정)
	docker compose logs -f $(SVC)
dc-ps:    ## docker compose 컨테이너 상태
	docker compose ps

## --- local 직접 실행 (포그라운드, 단일 프로세스) ---
dev:    ## 호스트 직접 실행 (포그라운드) / host run (워크스페이스 인식)
	pnpm -r dev
test:   ; pnpm -r test
build:  ; pnpm -r build
deploy: ; helm upgrade --install {{PROJECT_NAME}} ./deploy/helm

## --- local 멀티프로세스 (PM2, 백그라운드 데몬) ---
run:     ## PM2 데몬 기동 (web+api)
	$(PM) start ecosystem.config.cjs
stop:    ## PM2 중지·삭제
	$(PM) delete ecosystem.config.cjs || true
restart: ; $(PM) restart ecosystem.config.cjs
logs:    ## PM2 통합 로그 (Ctrl-C 로 종료)
	$(PM) logs
ps:      ## PM2 프로세스 상태
	$(PM) ls

## --- local-all: infra + PM2 한 번에 기동 ---
local-all:   ## [local] infra(docker) + PM2 일괄 기동 / docker up + managed procs
	docker compose up -d $(LOCAL_INFRA)
	$(PM) start ecosystem.config.cjs
local-down:  ## [local] PM2 종료 + infra 정리 (역순)
	$(PM) delete ecosystem.config.cjs || true
	docker compose down --remove-orphans

## --- dev/staging/prod: Docker 전체 스택 ---
dev-all:    ## [dev] infra + app 컨테이너 기동 (기존 이미지 사용)
	docker compose --profile app up -d
dev-build:  ## [dev] 이미지 빌드 후 기동 (코드 변경 후 재빌드 포함)
	docker compose --profile app up -d --build
dev-down:   ## [dev] app + infra 전체 정리
	docker compose --profile app down --remove-orphans
