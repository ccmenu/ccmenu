# This makefile is mainly intended for use on the CI server (Travis).
# It requires xcpretty to be installed.

BUILD_DIR = OBJROOT="$(CURDIR)/build" SYMROOT="$(CURDIR)/build"
SHELL = /bin/bash -e -o pipefail
MACOSX = -scheme CCMenu -sdk macosx $(BUILD_DIR)
XCODEBUILD = xcodebuild -project "$(CURDIR)/CCMenu.xcodeproj" CODE_SIGN_IDENTITY=${CODE_SIGN_IDENTITY}

ci: clean test

clean:
	$(XCODEBUILD) clean
	rm -rf "$(CURDIR)/build"

test:
	@echo "Running OS X tests..."
	which xcpretty || gem install xcpretty -N --quiet
	$(XCODEBUILD) $(MACOSX) test | xcpretty -c
