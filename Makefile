# Makefile for HAMi - Heterogeneous AI Computing Virtualization Middleware

# Build variables
BINARY_NAME ?= hami
VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
GIT_COMMIT ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_DATE ?= $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
GO_VERSION ?= $(shell go version | awk '{print $$3}')

# Go build settings
GOCMD = go
GOBUILD = $(GOCMD) build
GOTEST = $(GOCMD) test
GOVET = $(GOCMD) vet
GOFMT = gofmt
GOLINT = golangci-lint

# Directories
CMD_DIR = ./cmd
OUT_DIR = ./bin
PKG_DIR = ./pkg

# Docker settings
DOCKER_REGISTRY ?= docker.io/projecthami
DOCKER_IMAGE ?= $(DOCKER_REGISTRY)/$(BINARY_NAME)
DOCKER_TAG ?= $(VERSION)

# LDFLAGS for embedding version info
LDFLAGS = -ldflags "-X main.version=$(VERSION) \
	-X main.gitCommit=$(GIT_COMMIT) \
	-X main.buildDate=$(BUILD_DATE)"

.PHONY: all build clean test lint fmt vet docker-build docker-push help

## all: Build all binaries
all: build

## build: Build the project binaries
build:
	@echo "Building $(BINARY_NAME) version $(VERSION)..."
	@mkdir -p $(OUT_DIR)
	$(GOBUILD) $(LDFLAGS) -o $(OUT_DIR)/$(BINARY_NAME) $(CMD_DIR)/...

## build-scheduler: Build the scheduler extender binary
build-scheduler:
	@echo "Building scheduler extender..."
	@mkdir -p $(OUT_DIR)
	$(GOBUILD) $(LDFLAGS) -o $(OUT_DIR)/scheduler $(CMD_DIR)/scheduler/...

## build-device-plugin: Build the device plugin binary
build-device-plugin:
	@echo "Building device plugin..."
	@mkdir -p $(OUT_DIR)
	$(GOBUILD) $(LDFLAGS) -o $(OUT_DIR)/device-plugin $(CMD_DIR)/device-plugin/...

## test: Run unit tests
test:
	@echo "Running tests..."
	$(GOTEST) -v -race -coverprofile=coverage.out ./...

## test-coverage: Run tests and show coverage report
test-coverage: test
	$(GOCMD) tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated at coverage.html"

## lint: Run linter
lint:
	@echo "Running linter..."
	$(GOLINT) run --timeout 5m ./...

## fmt: Format Go source code
fmt:
	@echo "Formatting code..."
	$(GOFMT) -s -w .

## fmt-check: Check if code is formatted
fmt-check:
	@echo "Checking code format..."
	@if [ -n "$(shell $(GOFMT) -l .)" ]; then \
		echo "The following files need formatting:"; \
		$(GOFMT) -l .; \
		exit 1; \
	fi

## vet: Run go vet
vet:
	@echo "Running go vet..."
	$(GOVET) ./...

## clean: Remove build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(OUT_DIR)
	@rm -f coverage.out coverage.html

## docker-build: Build Docker image
docker-build:
	@echo "Building Docker image $(DOCKER_IMAGE):$(DOCKER_TAG)..."
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

## docker-push: Push Docker image to registry
docker-push:
	@echo "Pushing Docker image $(DOCKER_IMAGE):$(DOCKER_TAG)..."
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)

## generate: Run code generation
generate:
	@echo "Running code generation..."
	$(GOCMD) generate ./...

## vendor: Tidy and vendor dependencies
vendor:
	$(GOCMD) mod tidy
	$(GOCMD) mod vendor
