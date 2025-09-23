# Makefile for Ubuntu Runner Docker Image
# This file provides convenient commands for building, testing, and managing the Docker image

.PHONY: help build test lint clean security-scan push all

# Variables
REGISTRY ?= ghcr.io
IMAGE_NAME ?= ubuntu-runner
IMAGE_TAG ?= latest
FULL_IMAGE = $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)
PLATFORMS ?= linux/amd64

# Default target
help:
	@echo "Ubuntu Runner Docker Image - Available targets:"
	@echo "  make build         - Build the Docker image locally"
	@echo "  make test          - Run basic tests on the built image"
	@echo "  make lint          - Run linters on configuration files"
	@echo "  make security-scan - Run security vulnerability scans"
	@echo "  make push          - Push image to registry (requires authentication)"
	@echo "  make clean         - Clean up local Docker images and build cache"
	@echo "  make all           - Run build, test, and lint"
	@echo ""
	@echo "Environment variables:"
	@echo "  REGISTRY=$(REGISTRY)"
	@echo "  IMAGE_NAME=$(IMAGE_NAME)"
	@echo "  IMAGE_TAG=$(IMAGE_TAG)"

# Build Docker image
build:
	@echo "Building Docker image: $(FULL_IMAGE)"
	docker build -t $(FULL_IMAGE) \
		--platform $(PLATFORMS) \
		--build-arg BUILDKIT_INLINE_CACHE=1 \
		.
	@echo "✅ Build complete: $(FULL_IMAGE)"

# Test the built image
test: build
	@echo "Running tests on $(FULL_IMAGE)..."
	@echo "Testing basic commands..."
	@docker run --rm $(FULL_IMAGE) bash -c " \
		set -e; \
		echo 'Testing git...'; which git && git --version; \
		echo 'Testing curl...'; which curl && curl --version | head -1; \
		echo 'Testing jq...'; which jq && jq --version; \
		echo 'Testing docker...'; which docker && docker --version; \
		echo 'Testing python3...'; which python3 && python3 --version; \
		echo 'Testing node...'; which node && node --version; \
		echo 'Testing go...'; which go && go version; \
		echo '✅ All basic tests passed!'; \
	"

# Lint configuration files
lint:
	@echo "Linting configuration files..."
	@if command -v yamllint >/dev/null 2>&1; then \
		yamllint -c .yamllint.yml .github/workflows/*.yml || true; \
	else \
		echo "⚠️  yamllint not installed, skipping YAML linting"; \
	fi
	@echo "Checking shell scripts..."
	@for script in scripts/*.sh; do \
		echo "Checking $$script..."; \
		bash -n "$$script" || exit 1; \
	done
	@echo "✅ Linting complete"

# Run security vulnerability scan
security-scan: build
	@echo "Running security scans on $(FULL_IMAGE)..."
	@if command -v trivy >/dev/null 2>&1; then \
		trivy image --severity HIGH,CRITICAL $(FULL_IMAGE); \
	else \
		echo "⚠️  Trivy not installed, trying Docker scan..."; \
		docker scan $(FULL_IMAGE) 2>/dev/null || \
		echo "⚠️  No security scanner available"; \
	fi

# Push image to registry
push: build
	@echo "Pushing image to $(REGISTRY)..."
	docker push $(FULL_IMAGE)
	@echo "✅ Image pushed: $(FULL_IMAGE)"

# Clean up Docker resources
clean:
	@echo "Cleaning up Docker resources..."
	@docker rmi $(FULL_IMAGE) 2>/dev/null || true
	@docker system prune -f
	@echo "✅ Cleanup complete"

# Check for updates
check-updates:
	@echo "Checking for external tool updates..."
	@bash scripts/check-external-updates.sh

# Build, test, and lint
all: build test lint
	@echo "✅ All tasks completed successfully"