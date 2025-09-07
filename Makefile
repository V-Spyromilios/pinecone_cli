# Project settings
BINARY_NAME := pinecli

# Default Go flags
GO_FLAGS := -ldflags="-s -w"

# --- Targets ---

.PHONY: run
run: ## Run with local .env injected
	@set -a; [ -f .env ] && . ./.env; set +a; \
	go run ./cmd/$(BINARY_NAME)

.PHONY: build
build: ## Build binary into ./bin/
	@mkdir -p bin
	@go build $(GO_FLAGS) -o bin/$(BINARY_NAME) ./cmd/$(BINARY_NAME)

.PHONY: dev
dev: ## Build with 'dev' tag (loads .env via godotenv)
	@mkdir -p bin
	@go build -tags dev $(GO_FLAGS) -o bin/$(BINARY_NAME) ./cmd/$(BINARY_NAME)

.PHONY: test
test: ## Run unit tests with race detector
	go test ./... -race -count=1

.PHONY: lint
lint: ## Basic lint: vet + gofmt check
	go vet ./...
	@test -z "$$(gofmt -s -l . | tee /dev/stderr)"

.PHONY: ci
ci: lint test ## Run full CI pipeline (lint + tests)

.PHONY: clean
clean: ## Remove build artifacts
	rm -rf bin

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?##' Makefile | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "%-12s %s\n", $$1, $$2}'
