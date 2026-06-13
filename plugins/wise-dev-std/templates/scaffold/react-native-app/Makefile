# {{PROJECT_NAME}} — react-native-app (정적 템플릿 / static scaffold template)
.PHONY: dev ios android test build deploy
dev:     ; pnpm expo start
ios:     ; pnpm expo run:ios
android: ; pnpm expo run:android
test:    ; pnpm test && pnpm exec tsc --noEmit
build:   ; eas build -p all --profile production
deploy:  ; eas submit -p all   # 또는 fastlane; OTA: eas update
