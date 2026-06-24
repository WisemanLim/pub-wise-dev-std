# {{PROJECT_NAME}} — python-fastapi (정적 템플릿 / static scaffold template)
.PHONY: dev test build deploy up down dc-logs dc-ps run stop restart logs ps \
        local-all local-down dev-all dev-build dev-down preflight
ENV ?= local
HONCHO ?= uv run honcho -f Procfile.dev
# local 모드에서 기동할 compose 서비스만 지정 (비워두면 전체 infra).
# SQLite 사용 시 postgres 불필요 → 예: LOCAL_INFRA=redis make local-all
LOCAL_INFRA ?=

## --- 사전 호환성 점검 / Preflight (env-init 전 실행 권장) ---
preflight:  ## 런타임·도구 버전 호환성 점검
	@echo "=== Preflight: python-fastapi ==="
	@command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1 || (echo "FAIL: Python 미설치" && exit 1)
	@command -v uv     >/dev/null 2>&1 || (echo "FAIL: uv 미설치 — brew install uv 또는 curl -LsSf https://astral.sh/uv/install.sh | sh" && exit 1)
	@command -v docker >/dev/null 2>&1 || (echo "FAIL: Docker 미설치" && exit 1)
	@docker compose version >/dev/null 2>&1 || (echo "FAIL: docker compose v2 필요 (docker-compose v1 아님)" && exit 1)
	@python3 -c "import sys; v=sys.version_info; exit(0 if v>=(3,11) else 1)" 2>/dev/null || \
	 python  -c "import sys; v=sys.version_info; exit(0 if v>=(3,11) else 1)" 2>/dev/null || \
	 (echo "FAIL: Python 3.11+ 필요 (현재: $$(python3 --version 2>/dev/null || python --version))" && exit 1)
	@uv --version | awk '{split($$2,v,"."); if(v[1]+0==0 && v[2]+0<4) print "WARN: uv " $$2 " — 0.4+ 권장"}'
	@echo "=== Preflight OK ==="

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
dev:    ## 단일 직접 실행 (포그라운드)
	uv run uvicorn app.main:app --reload
test:   ; uv run pytest
build:  ## app 이미지 빌드
	docker compose --profile app build
deploy: ; helm upgrade --install {{PROJECT_NAME}} ./deploy/helm

## --- local 멀티프로세스 (honcho, 포그라운드 통합로그) ---
run:     ## honcho로 web(+worker) 동시 기동 (Ctrl-C 로 전체 종료)
	$(HONCHO) start
stop:    ; @echo "honcho 포그라운드 — make run 터미널에서 Ctrl-C 로 종료"
restart: ; @echo "Ctrl-C 후 make run 재실행"
logs:    ; @echo "통합 로그는 make run 콘솔에 출력됨"
ps:      ## Procfile 검증
	$(HONCHO) check

## --- local-all: infra + honcho 한 번에 기동 ---
local-all:   ## [local] infra(docker) + honcho 일괄 기동 / Ctrl-C 로 전체 종료
	docker compose up -d $(LOCAL_INFRA)
	$(HONCHO) start
local-down:  ## [local] infra 정리 (honcho 는 먼저 Ctrl-C 로 종료)
	docker compose down --remove-orphans

## --- dev/staging/prod: Docker 전체 스택 ---
dev-all:    ## [dev] infra + app 컨테이너 기동 (기존 이미지 사용)
	docker compose --profile app up -d
dev-build:  ## [dev] 이미지 빌드 후 기동 (코드 변경 후 재빌드 포함)
	docker compose --profile app up -d --build
dev-down:   ## [dev] app + infra 전체 정리
	docker compose --profile app down --remove-orphans
