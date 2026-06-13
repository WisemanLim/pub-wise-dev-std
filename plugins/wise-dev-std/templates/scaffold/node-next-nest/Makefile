# {{PROJECT_NAME}} — node-next-nest (정적 템플릿 / static scaffold template)
.PHONY: dev test build deploy up down run stop restart logs ps
ENV ?= local
PM ?= pnpm exec pm2          # local 프로세스 매니저 / PM2 (베어메탈 재사용 가능)

up:    ## datastore 만 / infra only (pnpm 워크스페이스 앱은 호스트 실행 권장)
	docker compose up -d
down:  ; docker compose down --remove-orphans
dev:   ## 호스트 직접 실행(포그라운드) / host run (워크스페이스 인식)
	pnpm -r dev
test:  ; pnpm -r test
build: ; pnpm -r build
deploy:; helm upgrade --install {{PROJECT_NAME}} ./deploy/helm

## --- local 멀티프로세스 (PM2, 백그라운드 데몬) / local multi-process ---
run:     ## web+api 데몬 기동 / start managed processes
	$(PM) start ecosystem.config.cjs
stop:    ## 중지·삭제 / stop & delete
	$(PM) delete ecosystem.config.cjs || true
restart: ; $(PM) restart ecosystem.config.cjs
logs:    ## 통합 로그 추적 / tail logs
	$(PM) logs
ps:      ## 상태 / status
	$(PM) ls
