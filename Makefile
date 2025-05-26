# Makefile for python-rtsp-processor

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
	@echo "🔍 Scanning $(DEFAULT_NETWORK) for common services..."
	@python3 $(SCAN_SCRIPT) --network $(DEFAULT_NETWORK) --service $(SERVICES) --port $(COMMON_PORTS)

scan-cameras:  ## Scan for cameras and related services
	@echo "📷 Scanning for cameras (RTSP, HTTP, ONVIF, etc.)..."
	@python3 $(SCAN_SCRIPT) --network $(DEFAULT_NETWORK) --service $(SERVICES) --port $(COMMON_PORTS) --verbose

scan-camera:   ## Scan a specific camera IP (make scan-camera IP=192.168.1.100)
	@if [ -z "$(IP)" ]; then echo "❌ Please specify an IP address: make scan-camera IP=192.168.1.100"; exit 1; fi
	@echo "🔍 Scanning camera at $(IP)..."
	@python3 $(SCAN_SCRIPT) --network $(IP) --service $(SERVICES) --port $(COMMON_PORTS) --verbose

scan-quick:    ## Quick scan of common ports
	@echo "⚡ Quick network scan..."
	@python3 $(SCAN_SCRIPT) --network $(DEFAULT_NETWORK) --port 21-23,80,443,554,8000,8080,8081,8443,9000 --timeout 1

scan-full:     ## Comprehensive scan
	@echo "🔍 Full network scan (this may take a while)..."
	@python3 $(SCAN_SCRIPT) --network $(DEFAULT_NETWORK) --port 1-10000 --timeout 2

scan-local:    ## Scan common local network ranges
	@echo "🏠 Scanning common local network ranges..."
	@for net in 192.168.0.0/24 192.168.1.0/24 192.168.2.0/24 10.0.0.0/24 10.0.1.0/24; do \
		echo "\n📡 Scanning network: $$net"; \
		python3 $(SCAN_SCRIPT) --network $$net --service $(SERVICES) --port $(COMMON_PORTS); \
	done

# === Printer Management ===
scan-printers: ## List all available printers
	@echo "🖨️  Listing available printers..."
	@python3 $(PRINTER_SCRIPT) list

# === Shell & Interactive Clients ===
shell:  ## Start a Python shell in the package context
	@echo "🐚 Starting Python shell..."
	@python3 -i mediainspect_rtsp/shell_client.py

interactive: ## Start interactive command-line client
	@echo "🖥️  Starting interactive CLI..."
	@python3 mediainspect_rtsp/interactive_client.py

# === Help ===
help:   ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'
