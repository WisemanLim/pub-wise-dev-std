# {{PROJECT_NAME}} — custom stack (정적 템플릿 / static scaffold template)
# 이 Makefile 은 resolve 단계에서 base_profile Makefile 로 교체됩니다.
# 아래는 모든 base_profile 에 공통된 인프라 타겟만 포함한 폴백입니다.
.PHONY: up down dc-logs dc-ps dev test build deploy \
        local-all local-down dev-all dev-build dev-down preflight
ENV ?= local
LOCAL_INFRA ?=

## --- 사전 호환성 점검 / Preflight (env-init 전 실행 권장) ---
preflight:  ## 런타임·도구 버전 호환성 점검 (base_profile 교체 후 보완 필요)
	@echo "=== Preflight: custom ==="
	@command -v docker >/dev/null 2>&1 || (echo "FAIL: Docker 미설치" && exit 1)
	@docker compose version >/dev/null 2>&1 || (echo "FAIL: docker compose v2 필요" && exit 1)
	@echo "=== Preflight OK (base_profile Makefile 교체 후 언어별 점검 추가) ==="

## --- infra (DB/캐시) ---
up infra-up:  ## docker infra 기동 (compose fragments 에 따라 확장)
	docker compose up -d
down infra-down:  ## infra 정리
	docker compose down --remove-orphans

## --- docker-compose 공통 유틸 ---
dc-logs:  ## docker compose 로그 추적 (SVC=<service> 로 특정 서비스 지정)
	docker compose logs -f $(SVC)
dc-ps:    ## docker compose 컨테이너 상태
	docker compose ps

## --- local-all / dev-all (base_profile 교체 후 활성화) ---
local-all:   ## [local] infra + 프로세스 매니저 일괄 기동 (base_profile 교체 후 보완)
	docker compose up -d $(LOCAL_INFRA)
	@echo "base_profile Makefile 교체 후 프로세스 매니저 기동 명령 추가"
local-down:  ## [local] 프로세스 종료 + infra 정리
	docker compose down --remove-orphans

dev-all:    ## [dev] infra + app 컨테이너 기동
	docker compose --profile app up -d
dev-build:  ## [dev] 이미지 빌드 후 기동
	docker compose --profile app up -d --build
dev-down:   ## [dev] app + infra 전체 정리
	docker compose --profile app down --remove-orphans

## --- app 실행 (base_profile 교체 후 활성화) ---
dev:
	@echo "base_profile Makefile 로 교체 후 실행"
test:
	@echo "base_profile Makefile 로 교체 후 실행"
build:
	docker compose build
deploy:
	helm upgrade --install {{PROJECT_NAME}} ./deploy/helm
