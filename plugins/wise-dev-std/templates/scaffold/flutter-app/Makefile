# {{PROJECT_NAME}} — flutter-app (정적 템플릿 / static scaffold template)
.PHONY: dev ios android test build deploy
dev:     ; flutter run
ios:     ; flutter run -d ios
android: ; flutter run -d android
test:    ; flutter test && flutter analyze
build:   ; flutter build appbundle && flutter build ipa
deploy:  ; cd fastlane && fastlane android beta   # iOS: fastlane ios beta
