SHELL := bash

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Users / UID-GID Registry

.PHONY: generate-service-uids
generate-service-uids: ## Regenerate users/zz_generated_uid_gid.yaml from Go constants in users/registry.go.
	cd users && go run ./cmd/gen-uid-gid-yaml

.PHONY: verify-service-uids
verify-service-uids: ## Verify zz_generated_uid_gid.yaml is up-to-date (fails if regeneration produces a diff).
	@cp users/zz_generated_uid_gid.yaml users/zz_generated_uid_gid.yaml.bak
	@$(MAKE) generate-service-uids
	@diff users/zz_generated_uid_gid.yaml.bak users/zz_generated_uid_gid.yaml || \
		(echo ""; echo "ERROR: users/zz_generated_uid_gid.yaml is out of date. Run 'make generate-service-uids' and commit the result."; \
		 mv users/zz_generated_uid_gid.yaml.bak users/zz_generated_uid_gid.yaml; exit 1)
	@rm -f users/zz_generated_uid_gid.yaml.bak
	@echo "users/zz_generated_uid_gid.yaml is up-to-date."

##@ Testing

.PHONY: test-users
test-users: ## Run users package tests.
	cd users && go test -v ./...

.PHONY: test
test: test-users ## Run all tests.
