# {{PROJECT_NAME}} — android-compose (정적 템플릿 / static scaffold template)
.PHONY: dev test build deploy setup
dev:    ; ./gradlew installDevDebug
test:   ; ./gradlew testDevDebugUnitTest
build:  ; ./gradlew bundleProdRelease
deploy: ; cd fastlane && fastlane android beta   # Play internal

# 최초 1회 실행 / run once after scaffold
setup:
	@# 1) Gradle Wrapper — gradlew 없으면 생성 (Gradle 9.5.1, JDK 25 호환)
	@if [ ! -f gradlew ]; then \
	  echo "[setup] gradlew not found. Running: gradle wrapper --gradle-version 9.5.1"; \
	  gradle wrapper --gradle-version 9.5.1 || \
	    (echo "ERROR: 'gradle' CLI not found. Install: sdk install gradle 9.5.1  (or brew install gradle)" && exit 1); \
	  chmod +x gradlew; \
	fi
	@# 2) local.properties — Android SDK 경로 자동 감지
	@if grep -q '<YOUR_ANDROID_SDK_PATH>' local.properties 2>/dev/null || [ ! -f local.properties ]; then \
	  if [ -d "$$HOME/Library/Android/sdk" ]; then \
	    echo "sdk.dir=$$HOME/Library/Android/sdk" > local.properties; \
	    echo "[setup] local.properties → macOS SDK path"; \
	  elif [ -d "$$USERPROFILE/AppData/Local/Android/Sdk" ]; then \
	    echo "sdk.dir=$$USERPROFILE/AppData/Local/Android/Sdk" > local.properties; \
	    echo "[setup] local.properties → Windows SDK path"; \
	  elif [ -d "$$HOME/Android/Sdk" ]; then \
	    echo "sdk.dir=$$HOME/Android/Sdk" > local.properties; \
	    echo "[setup] local.properties → Linux SDK path"; \
	  else \
	    echo "[setup] WARN: Android SDK not found. Set sdk.dir in local.properties manually."; \
	  fi; \
	fi
	@echo "[setup] Done. Run: make dev"
