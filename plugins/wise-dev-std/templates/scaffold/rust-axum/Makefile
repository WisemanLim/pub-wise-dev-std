# {{PROJECT_NAME}} — rust-axum (정적 템플릿 / static scaffold template)
.PHONY: dev test build deploy up down dc-logs dc-ps run stop restart logs ps \
        local-all local-down dev-all dev-build dev-down preflight
ENV ?= local
OVERMIND ?= overmind
# local 모드에서 기동할 compose 서비스만 지정 (비워두면 전체 infra).
# SQLite 사용 시 postgres 불필요 → 예: LOCAL_INFRA=redis make local-all
LOCAL_INFRA ?=

## --- 사전 호환성 점검 / Preflight (env-init 전 실행 권장) ---
preflight:  ## 런타임·도구 버전 호환성 점검
	@echo "=== Preflight: rust-axum ==="
	@command -v rustc  >/dev/null 2>&1 || (echo "FAIL: Rust 미설치 — curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh" && exit 1)
	@command -v cargo  >/dev/null 2>&1 || (echo "FAIL: cargo 미설치" && exit 1)
	@command -v docker >/dev/null 2>&1 || (echo "FAIL: Docker 미설치" && exit 1)
	@docker compose version >/dev/null 2>&1 || (echo "FAIL: docker compose v2 필요 (docker-compose v1 아님)" && exit 1)
	@rustc --version | awk '{print "Rust: " $$2}'
	@command -v overmind >/dev/null 2>&1 || echo "WARN: overmind 미설치 — brew install overmind (make run 필요 시, tmux 필요)"
	@command -v cargo-watch >/dev/null 2>&1 || echo "WARN: cargo-watch 미설치 — cargo install cargo-watch (핫리로드 필요 시)"
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
dev:    ; cargo run
test:   ; cargo test
build:  ; docker compose --profile app build
deploy: ; helm upgrade --install {{PROJECT_NAME}} ./deploy/helm

## --- local 멀티프로세스 (overmind, 제어 소켓 + tmux) ---
run:     ## overmind로 server(+worker) 동시 기동 (핫리로드, cargo-watch)
	$(OVERMIND) start -f Procfile.dev
stop:    ; $(OVERMIND) stop || true
restart: ; $(OVERMIND) restart web || true
logs:    ; $(OVERMIND) connect || true      # tmux 세션 접속
ps:      ; $(OVERMIND) ps || true

## --- local-all: infra + overmind 한 번에 기동 ---
local-all:   ## [local] infra(docker) + overmind 일괄 기동 (tmux 필요)
	docker compose up -d $(LOCAL_INFRA)
	$(OVERMIND) start -f Procfile.dev
local-down:  ## [local] overmind 종료 + infra 정리
	$(OVERMIND) stop || true
	docker compose down --remove-orphans

## --- dev/staging/prod: Docker 전체 스택 ---
dev-all:    ## [dev] infra + app 컨테이너 기동 (기존 이미지 사용)
	docker compose --profile app up -d
dev-build:  ## [dev] 이미지 빌드 후 기동 (코드 변경 후 재빌드 포함)
	docker compose --profile app up -d --build
dev-down:   ## [dev] app + infra 전체 정리
	docker compose --profile app down --remove-orphans
