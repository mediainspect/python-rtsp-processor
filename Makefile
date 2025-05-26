# Makefile for rtsp

.PHONY: install test lint run clean shell interactive help

# === Project Management ===
install:  ## Install dependencies
	pip install -r requirements.txt

test:     ## Run tests
	pytest

lint:     ## Lint code
	flake8 .

run:      ## Run main application
	python mediainspect_rtsp/web_rtsp_processor.py

clean:    ## Remove caches
	rm -rf __pycache__ .pytest_cache

# === Network Scanning ===
scan-network:  ## Scan the default network for common services
	@echo " Scanning $(DEFAULT_NETWORK) for common services..."
	@python3 $(SCAN_SCRIPT) --network $(DEFAULT_NETWORK) --service $(SERVICES) --port $(COMMON_PORTS)

scan-cameras:  ## Scan for cameras and related services
	@echo " Scanning for cameras (RTSP, HTTP, ONVIF, etc.)..."
	@python3 $(SCAN_SCRIPT) --network $(DEFAULT_NETWORK) --service $(SERVICES) --port $(COMMON_PORTS) --verbose

scan-camera:   ## Scan a specific camera IP (make scan-camera IP=192.168.1.100)
	@if [ -z "$(IP)" ]; then echo " Please specify an IP address: make scan-camera IP=192.168.1.100"; exit 1; fi
	@echo " Scanning camera at $(IP)..."
	@python3 $(SCAN_SCRIPT) --network $(IP) --service $(SERVICES) --port $(COMMON_PORTS) --verbose

scan-quick:    ## Quick scan of common ports
	@echo " Quick network scan..."
	@python3 $(SCAN_SCRIPT) --network $(DEFAULT_NETWORK) --port 21-23,80,443,554,8000,8080,8081,8443,9000 --timeout 1

scan-full:     ## Comprehensive scan
	@echo " Full network scan (this may take a while)..."
	@python3 $(SCAN_SCRIPT) --network $(DEFAULT_NETWORK) --port 1-10000 --timeout 2

scan-local:    ## Scan common local network ranges
	@echo " Scanning common local network ranges..."
	@for net in 192.168.0.0/24 192.168.1.0/24 192.168.2.0/24 10.0.0.0/24 10.0.1.0/24; do \
		echo "\n Scanning network: $$net"; \
		python3 $(SCAN_SCRIPT) --network $$net --service $(SERVICES) --port $(COMMON_PORTS); \
	done

# === Printer Management ===
scan-printers: ## List all available printers
	@echo "  Listing available printers..."
	@python3 $(PRINTER_SCRIPT) list

# === Shell & Interactive Clients ===
shell:  ## Start a Python shell in the package context
	@echo " Starting Python shell..."
	@python3 -i scripts/shell_client.py

interactive: ## Start interactive command-line client
	@echo "  Starting interactive CLI..."
	@python3 scripts/interactive_client.py

# === Help ===
help:   ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "%-16s %s\n", $$1, $$2}'



# Helper to get PYPI_TOKEN from files
define get_pypi_token
$(shell \
    if [ -f "${HOME}/.pypirc" ]; then \
        grep -A 2 '\[pypi\]' "${HOME}/.pypirc" 2>/dev/null | grep 'token = ' | cut -d' ' -f3; \
    elif [ -f ".pypirc" ]; then \
        grep -A 2 '\[pypi\]' ".pypirc" 2>/dev/null | grep 'token = ' | cut -d' ' -f3; \
    elif [ -f ".env" ]; then \
        grep '^PYPI_TOKEN=' ".env" 2>/dev/null | cut -d'=' -f2-; \
    fi
)
endef

# Export the function to be used in the recipe
PYPI_TOKEN_FROM_FILE := $(call get_pypi_token)

# Publishing
publish:
	@echo "🔄 Bumping version..."
	poetry version patch
	@echo "🧹 Cleaning build artifacts..."
	@$(MAKE) clean
	@echo "🏗️  Building package..."
	poetry build
	@echo "🚀 Publishing to PyPI..."
	poetry publish
	@echo "✅ Successfully published to PyPI"

# Test publishing
TEST_PYPI_TOKEN ?= $(PYPI_TEST_TOKEN)
testpublish: build
	@if [ -z "$(TEST_PYPI_TOKEN)" ]; then \
		echo "Error: Please set PYPI_TEST_TOKEN environment variable"; \
		exit 1; \
	fi
	@echo "🚀 Publishing to TestPyPI..."
	poetry publish --build --repository testpypi --username=__token__ --password=$(TEST_PYPI_TOKEN)
	@echo "✅ Successfully published to TestPyPI"

# Try to read PyPI token from common locations
PYPI_TOKEN_FILE ?= $(shell if [ -f "${HOME}/.pypirc" ]; then echo "${HOME}/.pypirc"; elif [ -f ".pypirc" ]; then echo ".pypirc"; elif [ -f ".env" ]; then echo ".env"; fi)

# Extract PyPI token from file if not provided
ifdef PYPI_TOKEN_FILE
    ifeq ("$(PYPI_TOKEN)","")
        PYPI_TOKEN := $(shell if [ -f "$(PYPI_TOKEN_FILE)" ]; then \
            if [ "$(PYPI_TOKEN_FILE)" = "${HOME}/.pypirc" ] || [ "$(PYPI_TOKEN_FILE)" = ".pypirc" ]; then \
                grep -A 2 '\[pypi\]' "$(PYPI_TOKEN_FILE)" 2>/dev/null | grep 'token = ' | cut -d' ' -f3; \
            elif [ "$(PYPI_TOKEN_FILE)" = ".env" ]; then \
                grep '^PYPI_TOKEN=' "$(PYPI_TOKEN_FILE)" 2>/dev/null | cut -d'=' -f2-; \
            fi \
        fi)
    endif
endif

# Release a new patch version and publish
release-patch:
	@echo "🚀 Starting release process..."
	@# Bump patch version
	@echo "🔄 Bumping patch version..."
	@$(MAKE) version PART=patch
	@# Push changes and tags
	@echo "📤 Pushing changes to remote..."
	@git push --follow-tags
	@# Publish to PyPI
	@if [ -n "$(PYPI_TOKEN)" ]; then \
		echo "🔑 Found PyPI token in $(PYPI_TOKEN_FILE)"; \
		echo "🚀 Publishing to PyPI..."; \
		$(MAKE) publish; \
	else \
		echo "ℹ️  PyPI token not found. Tried: ~/.pypirc, .pypirc, .env"; \
		echo "   To publish to PyPI, either:"; \
		echo "   1. Add token to ~/.pypirc or .pypirc: [pypi]\n   token = pypi_..."; \
		echo "   2. Add PYPI_TOKEN=... to .env file"; \
		echo "   3. Run: make release-patch PYPI_TOKEN=your_token_here"; \
	fi
	@echo "✅ Release process completed!"

# Docker
docker:
	docker build -t mediainspect:latest .
	@echo "✅ Docker image built: mediainspect:latest"

docker-run: docker
	docker run -it --rm \
		-v $(PWD)/examples:/app/examples \
		-v $(PWD)/.env:/app/.env \
		mediainspect:latest \
		mediainspect run -c examples/simple_routes.yaml

# Examples and setup
setup-env:
	@if [ ! -f .env ]; then \
		if [ -f .env.example ]; then \
			cp .env.example .env; \
			echo "✅ Created .env file from template"; \
		else \
			touch .env; \
			echo "✅ Created empty .env file"; \
		fi; \
		echo "📝 Please edit .env with your configuration"; \
	else \
		echo "ℹ️  .env file already exists"; \
	fi
