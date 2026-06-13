# {{PROJECT_NAME}} — ios-swiftui (정적 템플릿 / static scaffold template)
.PHONY: dev test build deploy setup
SCHEME ?= App
DEST ?= platform=iOS\ Simulator,name=iPhone\ 16
dev:    ; xcodebuild -scheme $(SCHEME) -destination $(DEST) -configuration Debug build
test:   ; xcodebuild test -scheme $(SCHEME) -destination $(DEST)
build:  ; cd fastlane && fastlane ios build
deploy: ; cd fastlane && fastlane ios beta   # TestFlight

# 최초 1회 실행 / run once after scaffold
setup:
	@# 1) Xcode Command Line Tools
	@xcode-select -p > /dev/null 2>&1 || \
	  (echo "ERROR: Xcode CLT not installed. Run: xcode-select --install" && exit 1)
	@echo "[setup] Xcode CLT: $$(xcode-select -p)"
	@xcodebuild -version
	@# 2) 사용 가능한 시뮬레이터 확인 / list available simulators
	@echo "[setup] Available simulators (iOS):"
	@xcrun simctl list devices available | grep "iPhone" | head -8
	@# 3) Swift Package 의존성 resolve
	@echo "[setup] Resolving Swift packages..."
	@swift package resolve 2>/dev/null || echo "[setup] WARN: swift package resolve failed (Xcode project이면 xcodebuild -resolvePackageDependencies 사용)"
	@echo "[setup] Done. Run: make dev"
