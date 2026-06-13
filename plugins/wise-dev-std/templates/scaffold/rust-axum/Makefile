# {{PROJECT_NAME}} — rust-axum (정적 템플릿 / static scaffold template)
.PHONY: dev test build deploy up down run stop restart logs ps
ENV ?= local
OVERMIND ?= overmind   # local 멀티프로세스 매니저 / overmind (+tmux, +cargo-watch). 대안: hivemind

up:    ; docker compose up -d
down:  ; docker compose --profile app down --remove-orphans
dev:   ; cargo run
test:  ; cargo test
build: ; docker compose --profile app build
deploy:; helm upgrade --install {{PROJECT_NAME}} ./deploy/helm

## --- local 멀티프로세스 (overmind, 제어 소켓) / local multi-process ---
run:     ## server(+worker) 동시 기동(핫리로드) / start procs (cargo-watch)
	$(OVERMIND) start -f Procfile.dev
stop:    ; $(OVERMIND) stop || true          # 별도 터미널에서 / from another shell
restart: ; $(OVERMIND) restart web || true
logs:    ; $(OVERMIND) connect || true       # tmux 세션 접속 / attach
ps:      ; $(OVERMIND) ps || true
