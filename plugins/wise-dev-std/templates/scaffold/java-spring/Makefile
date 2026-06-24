# {{PROJECT_NAME}} — java-spring (정적 템플릿 / static scaffold template)
.PHONY: dev test build deploy up down dc-logs dc-ps run stop restart logs ps \
        local-all local-down dev-all dev-build dev-down preflight
ENV ?= local
GOREMAN ?= goreman -f Procfile.dev
GRADLE  ?= ./gradlew
# local 모드에서 기동할 compose 서비스만 지정 (비워두면 전체 infra).
# SQLite 사용 시 postgres 불필요 → 예: LOCAL_INFRA=redis make local-all
LOCAL_INFRA ?=

## --- 사전 호환성 점검 / Preflight (env-init 전 실행 권장) ---
preflight:  ## 런타임·도구 버전 호환성 점검
	@echo "=== Preflight: java-spring ==="
	@command -v java   >/dev/null 2>&1 || (echo "FAIL: Java 미설치" && exit 1)
	@command -v docker >/dev/null 2>&1 || (echo "FAIL: Docker 미설치" && exit 1)
	@docker compose version >/dev/null 2>&1 || (echo "FAIL: docker compose v2 필요 (docker-compose v1 아님)" && exit 1)
	@java -version 2>&1 | awk '/version/{match($$0,/"([0-9]+)/,v); if(v[1]+0<21) print "FAIL: Java 21+ 필요 (현재: " $$0 ")"}'
	@test -f gradlew || (echo "WARN: gradlew 없음 — gradle wrapper --gradle-version 9.5.1 후 chmod +x gradlew")
	@command -v goreman >/dev/null 2>&1 || echo "WARN: goreman 미설치 — go install github.com/mattn/goreman@latest (make run 필요 시)"
	@echo "=== Preflight OK ==="
	@echo "JDK-Gradle 호환: JDK17=Gradle8.x, JDK21=Gradle8.5+, JDK25+=Gradle9.5.1+"

## --- infra (DB/캐시, app 제외) ---
up:    ## docker infra 기동 (postgres/redis — app 컨테이너 제외)
	docker compose up -d
down:  ## infra 전체 정리
	docker compose down --remove-orphans

## --- docker-compose 공통 유틸 ---
dc-logs:  ## docker compose 로그 추적 (SVC=<service> 로 특정 서비스 지정)
	docker compose logs -f $(SVC)
dc-ps:    ## docker compose 컨테이너 상태
	docker compose ps

## --- local 직접 실행 (포그라운드, 단일 프로세스) ---
dev:    ## Spring Boot 직접 실행
	$(GRADLE) bootRun --args='--spring.profiles.active=local'
test:   ; $(GRADLE) test
build:  ; docker compose build
deploy: ; helm upgrade --install {{PROJECT_NAME}} ./deploy/helm

## --- local 멀티프로세스 (goreman, Procfile.dev) ---
run:     ## goreman으로 api(+worker) 동시 기동
	$(GOREMAN) start
stop:    ; goreman run stop-all || true
restart: ; goreman run restart-all || true
logs:    ; @echo "통합 로그는 make run 콘솔. 개별 상태: goreman run status"
ps:      ; goreman run status || echo "먼저 make run (별도 터미널)"

## --- local-all: infra + goreman 한 번에 기동 ---
local-all:   ## [local] infra(docker) + goreman 일괄 기동 / Ctrl-C 로 종료
	docker compose up -d $(LOCAL_INFRA)
	$(GOREMAN) start
local-down:  ## [local] goreman 종료 + infra 정리
	goreman run stop-all || true
	docker compose down --remove-orphans

## --- dev/staging/prod: Docker 전체 스택 ---
dev-all:    ## [dev] infra + app 컨테이너 기동 (기존 이미지 사용)
	docker compose --profile app up -d
dev-build:  ## [dev] 이미지 빌드 후 기동 (코드 변경 후 재빌드 포함)
	docker compose --profile app up -d --build
dev-down:   ## [dev] app + infra 전체 정리
	docker compose --profile app down --remove-orphans
