# {{PROJECT_NAME}} — go-gin (정적 템플릿 / static scaffold template)
.PHONY: dev test build deploy up down run stop restart logs ps
ENV ?= local
GOREMAN ?= goreman -f Procfile.dev   # local 멀티프로세스 매니저 / goreman (go install github.com/mattn/goreman@latest)

up:    ; docker compose up -d
down:  ; docker compose --profile app down --remove-orphans
dev:   ; go run ./cmd/server
test:  ; go test ./...
build: ; docker compose --profile app build
deploy:; helm upgrade --install {{PROJECT_NAME}} ./deploy/helm

## --- local 멀티프로세스 (goreman, 포그라운드 + RPC 제어) / local multi-process ---
run:     ## server(+worker) 동시 기동 / start procs
	$(GOREMAN) start
stop:    ; goreman run stop-all || true     # 별도 터미널에서 / from another shell
restart: ; goreman run restart-all || true
logs:    ; @echo "통합 로그는 make run 콘솔. 개별 상태: goreman run status"
ps:      ; goreman run status || echo "먼저 make run (별도 터미널)"
