.DEFAULT_GOAL := help

.PHONY: help test build debug release run clean

help: ## List available commands.
	@awk 'BEGIN { FS = ":.*##" } /^[a-zA-Z_-]+:.*##/ { printf "%-10s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

test: ## Run the complete test suite.
	swift test

build: debug ## Build the debug app bundle.

debug: ## Build build/Magpie.app with the debug configuration.
	./scripts/build-app.sh debug

release: ## Build build/Magpie.app with the release configuration.
	./scripts/build-app.sh release

run: ## Build and launch the debug app.
	./scripts/run-dev-app.sh

clean: ## Remove SwiftPM and app-bundle build artifacts.
	rm -rf .build build
