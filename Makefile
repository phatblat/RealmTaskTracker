#
# Makefile
# RealmTaskTracker
#

################################################################################
#
# Variables
#

CMD_NAME = RealmTaskTracker
SHELL = /bin/sh
SWIFT_VERSION = 5.3
REALM_CLI = node_modules/.bin/realm-cli
REALM_APP_ID = `cat .realm_app_id`
ATLAS_PUBLIC_API_KEY = `cat .atlas_public_api_key`
ATLAS_PRIVATE_API_KEY = `cat .atlas_private_api_key`
ATLAS_FOLDER = Atlas

# set EXECUTABLE_DIRECTORY according to your specific environment
# run swift build and see where the output executable is created

# OS specific differences
UNAME = ${shell uname}

ifeq ($(UNAME), Darwin)
SWIFTC_FLAGS =
LINKER_FLAGS = -Xlinker -L/usr/local/lib
PLATFORM = x86_64-apple-macosx
EXECUTABLE_DIRECTORY = ./.build/${PLATFORM}/debug
TEST_BUNDLE = ${CMD_NAME}PackageTests.xctest
TEST_RESOURCES_DIRECTORY = ./.build/${PLATFORM}/debug/${TEST_BUNDLE}/Contents/Resources
endif
ifeq ($(UNAME), Linux)
SWIFTC_FLAGS = -Xcc -fblocks
LINKER_FLAGS = -Xlinker -rpath -Xlinker .build/debug
PATH_TO_SWIFT = /home/vagrant/swiftenv/versions/$(SWIFT_VERSION)
PLATFORM = x86_64-unknown-linux
EXECUTABLE_DIRECTORY = ./.build/${PLATFORM}/debug
TEST_RESOURCES_DIRECTORY = ${EXECUTABLE_DIRECTORY}
endif

RUN_RESOURCES_DIRECTORY = ${EXECUTABLE_DIRECTORY}

################################################################################
#
# Targets
#

.PHONY: version
version:
	xcodebuild -version
	swift --version
	swift package tools-version
	$(REALM_CLI) --version

.PHONY: init
init:
	- swiftenv install $(SWIFT_VERSION)
	swiftenv local $(SWIFT_VERSION)
	nvm use
	npm install

.PHONY: clean
clean:
	rm -rf Packages
	xcodebuild clean
	swift package clean
	swift package reset

.PHONY: login
login:
	$(REALM_CLI) login --api-key="$(ATLAS_PUBLIC_API_KEY)" --private-api-key="$(ATLAS_PRIVATE_API_KEY)"

.PHONY: whoami
whoami:
	$(REALM_CLI) whoami

.PHONY: diff
diff:
	$(REALM_CLI) diff --app-id=$(REALM_APP_ID)

.PHONY: export
export:
	rm -rf $(ATLAS_FOLDER)
	$(REALM_CLI) export --app-id=$(REALM_APP_ID) --output $(ATLAS_FOLDER) --include-hosting --for-source-control
