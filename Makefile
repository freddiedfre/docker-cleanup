PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
SCRIPT = scripts/docker-cleanup.sh
TARGET = docker-cleanup
INSTALL_PATH = $(BINDIR)/$(TARGET)

OS := $(shell uname -s)

help:
	@echo "Available targets:"
	@echo "  make install    - Install docker-cleanup globally"
	@echo "  make uninstall  - Uninstall docker-cleanup"
	@echo "  make test       - Run bats tests"
	@echo "  make lint       - Run shellcheck"
	@echo "  make all        - Lint, test, install"

install:
ifeq ($(OS),Darwin)
	@echo ">> Installing on macOS..."
	@mkdir -p $(BINDIR)
	@install -m 0755 $(SCRIPT) $(INSTALL_PATH)
else ifeq ($(OS),Linux)
	@echo ">> Installing on Linux..."
	@mkdir -p $(BINDIR)
	@install -m 0755 $(SCRIPT) $(INSTALL_PATH)
else
	@echo ">> Installing on Windows/WSL..."
	@mkdir -p $(HOME)/.local/bin
	@install -m 0755 $(SCRIPT) $(HOME)/.local/bin/$(TARGET)
endif
	@echo ">> Installed $(TARGET) to $(INSTALL_PATH)"

uninstall:
ifeq ($(OS),Darwin)
	@if [ -f "$(INSTALL_PATH)" ]; then \
	  echo ">> Removing $(INSTALL_PATH)"; \
	  rm -f "$(INSTALL_PATH)"; \
	else \
	  echo ">> Nothing to uninstall at $(INSTALL_PATH)"; \
	fi
else ifeq ($(OS),Linux)
	@if [ -f "$(INSTALL_PATH)" ]; then \
	  echo ">> Removing $(INSTALL_PATH)"; \
	  rm -f "$(INSTALL_PATH)"; \
	else \
	  echo ">> Nothing to uninstall at $(INSTALL_PATH)"; \
	fi
else
	@if [ -f "$(HOME)/.local/bin/$(TARGET)" ]; then \
	  echo ">> Removing $(HOME)/.local/bin/$(TARGET)"; \
	  rm -f "$(HOME)/.local/bin/$(TARGET)"; \
	else \
	  echo ">> Nothing to uninstall at $(HOME)/.local/bin/$(TARGET)"; \
	fi
endif

lint:
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo ">> Running shellcheck..."; \
		shellcheck $(SCRIPT); \
	else \
		echo ">> Skipping lint: shellcheck not installed"; \
	fi

test:
	@if command -v bats >/dev/null 2>&1; then \
		echo ">> Running tests..."; \
		bats tests/; \
	else \
		echo ">> Skipping tests: bats not installed"; \
	fi

all: lint test install
