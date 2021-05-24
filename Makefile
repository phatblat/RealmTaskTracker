#
# Makefile
# RealmTaskTracker
#

################################################################################
#
# Variables
#

ATLAS_PUBLIC_API_KEY := $(shell cat .atlas_public_api_key)
ATLAS_PRIVATE_API_KEY := $(shell cat .atlas_private_api_key)
MONGODB_USERNAME := $(shell cat .mongodb_username)
MONGODB_PASSWORD := $(shell cat .mongodb_password)
CLUSTER = cluster10.5exqq.azure.mongodb.net
DATABASE = tracker
COLLECTION = tasks
REALM_APP_ID := $(shell cat .realm_app_id)
REALM_CLI = $(shell npm bin)/realm-cli
SWIFT_VERSION = 5.3
ATLAS_FOLDER = Atlas
MONGODB_FOLDER = $(ATLAS_FOLDER)/mongodb
REALM_FOLDER = $(ATLAS_FOLDER)/realm

################################################################################
#
# Targets
#

.PHONY: version
version:
	xcodebuild -version
	swift --version
	mongo --version
	mongodump --version
	mongorestore --version
	mongoexport --version
	mongoimport --version
	node --version
	npm --version
	$(REALM_CLI) --version

.PHONY: init
init:
	- brew bundle install
	# nvm use
	npm install

.PHONY: clean
clean:
	rm -rf Packages
	xcodebuild clean

#
# MongoDB
#

.PHONY: shell
shell:
	mongo "mongodb+srv://$(CLUSTER)/$(DATABASE)" --username $(MONGODB_USERNAME) --password $(MONGODB_PASSWORD)

.PHONY: dump
dump:
	mongodump --uri "mongodb+srv://$(MONGODB_USERNAME):$(MONGODB_PASSWORD)@$(CLUSTER)/$(DATABASE)" --out=$(MONGODB_FOLDER)

.PHONY: restore
restore:
	mongorestore --uri "mongodb+srv://$(MONGODB_USERNAME):$(MONGODB_PASSWORD)@$(CLUSTER)/$(DATABASE)" --drop $(MONGODB_FOLDER)

.PHONY: export
export:
	mongoexport --uri="mongodb+srv://$(MONGODB_USERNAME):$(MONGODB_PASSWORD)@$(CLUSTER)/$(DATABASE)" --collection=$(COLLECTION) --out=$(MONGODB_FOLDER)/$(COLLECTION).json

.PHONY: import
import:
	mongoimport --uri="mongodb+srv://$(MONGODB_USERNAME):$(MONGODB_PASSWORD)@$(CLUSTER)/$(DATABASE)" --collection=$(COLLECTION) --drop $(MONGODB_FOLDER)/$(COLLECTION).json

#
# Realm CLI
# https://docs.mongodb.com/realm/deploy/realm-cli-reference/
# Note: v2 beta syntax does not match documented CLI reference.
#

.PHONY: login
login:
	$(REALM_CLI) login --api-key="$(ATLAS_PUBLIC_API_KEY)" --private-api-key="$(ATLAS_PRIVATE_API_KEY)"

.PHONY: whoami
whoami:
	$(REALM_CLI) whoami

.PHONY: list
list:
	$(REALM_CLI) apps list

.PHONY: users
users:
	$(REALM_CLI) users list --app $(REALM_APP_ID)

.PHONY: realmdiff
realmdiff:
	$(REALM_CLI) app diff --app $(REALM_APP_ID)

.PHONY: realmpull
realmpull:
	rm -rf $(ATLAS_FOLDER)/realm
	$(REALM_CLI) pull --remote $(REALM_APP_ID) --local $(REALM_FOLDER)

# FIXME: Errors out
# node_modules/.bin/realm-cli import --app-id=task-tracker-seidr --path Atlas/realm --strategy=replace
# failed to diff app with currently deployed instance: error: error validating Service: mongodb-atlas: only [wireProtocolEnabled, readPreference, readPreferenceTagSets] are allowed config options
.PHONY: realmpush
realmpush:
	$(REALM_CLI) push --remote $(REALM_APP_ID) --local $(REALM_FOLDER)

.PHONY: realmpushtest
realmpushtest:
	$(REALM_CLI) push --remote $(REALM_APP_ID) --local $(REALM_FOLDER) --dry-run
