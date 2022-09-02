ifneq (,$(wildcard ./.env))
    include .env
    export
endif

.PHONY: help
help:
	@echo -e "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)"

.PHONY: build
build: infra-prep ## Builds all

.PHONY: infra-prep
infra-prep: ## Create the backend resources if missing
	@az group create --location $(REGION) --resource-group $(RESOURCE_GROUP)
	@az deployment group create --resource-group $(RESOURCE_GROUP) \
		--template-file infra/backend.bicep \
		--parameters \
			storageAccountName=$(STATE_BUCKET_NAME)

.PHONY: init
init: ## Initialize backend for terraform
	cd infra && terraform init \
		-backend-config="resource_group_name=$(RESOURCE_GROUP)" \
		-backend-config="storage_account_name=$(STATE_BUCKET_NAME)" \
		-backend-config="container_name=tfstate" \
		-backend-config="use_oidc=true" \
		-backend-config="subscription_id=$(SUBSCRIPTION_ID)" \
		-backend-config="tenant_id=$(TENANT_ID)"

plan: ## Terraform plan
	cd infra && terraform plan

lint: ## tflint execution
	cd infra && tflint