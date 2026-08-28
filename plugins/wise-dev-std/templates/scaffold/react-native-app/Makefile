# {{PROJECT_NAME}} — react-native-app (정적 템플릿 / static scaffold template)
# 표준 타겟(모바일): make local-all(expo start) · ios|android · test · dev-build|staging-build|prod-build(eas profile) · deploy
.PHONY: help local-all local-stop ios android test dev-build staging-build prod-build deploy
help:        ## 타겟 목록
	@grep -hE '^[a-z][a-z-]*:.*## ' $(MAKEFILE_LIST) | sed -E 's/:[^#]*##/\t/' | awk -F'\t' '{printf "  %-16s %s\n", $$1, $$2}'
local-all:   ## [local] Expo dev server (.env.local → react-native-dotenv)
	pnpm expo start
local-stop:  ## [local] 시뮬레이터/에뮬레이터 종료
	xcrun simctl shutdown all 2>/dev/null || true; adb emu kill 2>/dev/null || true
ios:         ## iOS 시뮬레이터 네이티브 실행
	pnpm expo run:ios
android:     ## Android 에뮬레이터 네이티브 실행
	pnpm expo run:android
test:        ## jest + 타입체크
	pnpm test && pnpm exec tsc --noEmit
dev-build:   ## [dev] EAS development 빌드
	eas build -p all --profile development
staging-build: ## [staging] EAS preview 빌드
	eas build -p all --profile preview
prod-build:  ## [prod] EAS production 빌드
	eas build -p all --profile production
deploy:      ## 스토어 제출 (eas submit) — OTA: eas update
	eas submit -p all --profile production
