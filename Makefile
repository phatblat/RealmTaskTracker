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
REALM_CLI = node_modules/.bin/realm-cli
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
	$(REALM_CLI) --version

.PHONY: init
init:
	- brew bundle install
	# nvm use
	npm install
	bundle install --gemfile=Gemfile
	pod install --repo-update

.PHONY: clean
clean:
	rm -rf Packages
	xcodebuild clean
	swift package clean
	swift package reset

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
	$(REALM_CLI) users list

.PHONY: realmdiff
realmdiff:
	$(REALM_CLI) diff --app-id=$(REALM_APP_ID)

.PHONY: realmexport
realmexport:
	rm -rf $(ATLAS_FOLDER)/realm
	$(REALM_CLI) export --app-id=$(REALM_APP_ID) --output $(REALM_FOLDER) --for-source-control

# FIXME: Errors out
# node_modules/.bin/realm-cli import --app-id=task-tracker-seidr --path Atlas/realm --strategy=replace
# failed to diff app with currently deployed instance: error: error validating Service: mongodb-atlas: only [wireProtocolEnabled, readPreference, readPreferenceTagSets] are allowed config options
.PHONY: realmimport
realmimport:
	$(REALM_CLI) import --app-id=$(REALM_APP_ID) --path $(REALM_FOLDER) --strategy=replace
