# {{PROJECT_NAME}} — flutter-app (정적 템플릿 / static scaffold template)
# 표준 타겟(모바일): make local-all|dev-all|staging-all(실행, .env.<env> dart-define) · test · dev-build|staging-build|prod-build · deploy
.PHONY: help local-all dev-all staging-all local-stop ios android test dev-build staging-build prod-build deploy
ENVS := local dev staging
DEVICE ?=          # -d ios | -d android | -d <id> (비우면 flutter 가 선택)
help:        ## 타겟 목록
	@grep -hE '^[a-z][a-z-]*:.*## ' $(MAKEFILE_LIST) | sed -E 's/:[^#]*##/\t/' | awk -F'\t' '{printf "  %-16s %s\n", $$1, $$2}'
$(ENVS:%=%-all): %-all:  ## [local|dev|staging] .env.<env> 주입 실행 (flutter run --dart-define-from-file)
	flutter run $(DEVICE) --dart-define-from-file=.env.$*
local-stop:  ## [local] 시뮬레이터/에뮬레이터 종료
	xcrun simctl shutdown all 2>/dev/null || true; adb emu kill 2>/dev/null || true
ios:         ## iOS 시뮬레이터 실행 (.env.local)
	flutter run -d ios --dart-define-from-file=.env.local
android:     ## Android 에뮬레이터 실행 (.env.local)
	flutter run -d android --dart-define-from-file=.env.local
test:        ## flutter test + analyze
	flutter test && flutter analyze
dev-build:   ## [dev] APK (debug, .env.dev)
	flutter build apk --debug --dart-define-from-file=.env.dev
staging-build: ## [staging] AAB + IPA (.env.staging)
	flutter build appbundle --dart-define-from-file=.env.staging && flutter build ipa --dart-define-from-file=.env.staging
prod-build:  ## [prod] AAB + IPA (.env.prod)
	flutter build appbundle --dart-define-from-file=.env.prod && flutter build ipa --dart-define-from-file=.env.prod
deploy:      ## 스토어 업로드 (fastlane android beta / ios beta)
	cd fastlane && fastlane android beta   # iOS: fastlane ios beta
