help: ## Show this help
	@egrep '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

lint: ## Format & Check for errors
	@pre-commit run -a

test: tests/*.sh ## Run smoke tests
	@for t in $^; do \
		./$${t} ; \
	done
