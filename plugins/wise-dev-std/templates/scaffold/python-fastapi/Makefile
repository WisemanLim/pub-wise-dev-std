# {{PROJECT_NAME}} — python-fastapi (정적 템플릿 / static scaffold template)
.PHONY: dev test build deploy up down run stop restart logs ps
ENV ?= local
HONCHO ?= uv run honcho -f Procfile.dev   # local 멀티프로세스 매니저 / honcho

up:    ## datastore 만 기동 / infra only
	docker compose up -d
down:  ## 전체 정리 / tear down
	docker compose --profile app down --remove-orphans
dev:   ## 단일 직접 실행(포그라운드) / single direct run
	uv run uvicorn app.main:app --reload
test:  ## pytest
	uv run pytest
build: ## app 이미지 빌드 / build app image
	docker compose --profile app build
deploy: ## 배포 / deploy
	helm upgrade --install {{PROJECT_NAME}} ./deploy/helm

## --- local 멀티프로세스 (honcho, 포그라운드 통합로그) / local multi-process ---
run:     ## web(+worker) 동시 기동 / start procs (Ctrl-C 로 전체 종료)
	$(HONCHO) start
stop:    ; @echo "honcho 는 포그라운드 — make run 터미널서 Ctrl-C 로 종료"
restart: ; @echo "Ctrl-C 후 make run 재실행"
logs:    ; @echo "통합 로그는 make run 콘솔에 출력됨"
ps:      ## Procfile 검증 / validate Procfile
	$(HONCHO) check
