SHELL  := /bin/bash
PYTHON := python3.11
VENV   := .venv
BIN    := $(VENV)/bin

.DEFAULT_GOAL := help

# ─── Setup ────────────────────────────────────────────────────────────────────

.PHONY: venv
venv: ## Create the virtual environment
	@if [ ! -d $(VENV) ]; then \
		echo "==> Creating virtual environment"; \
		$(PYTHON) -m venv $(VENV); \
	else \
		echo "==> Virtual environment already exists"; \
	fi

.PHONY: setup
setup: venv ## Bootstrap pip, poetry, rich, pipx inside the venv
	$(BIN)/pip install --upgrade pip
	$(BIN)/pip install --upgrade poetry rich pipx
	$(BIN)/poetry env use $(PYTHON)
	$(BIN)/poetry --version

# ─── Install ──────────────────────────────────────────────────────────────────

.PHONY: install
install: setup ## Install project dependencies via Poetry
	$(BIN)/poetry install

.PHONY: registry
registry: setup ## Configure a private Poetry registry (requires PYTHON_REGISTRY_NAME & PYTHON_REGISTRY)
	@if [ -z "$(PYTHON_REGISTRY_NAME)" ] || [ -z "$(PYTHON_REGISTRY)" ]; then \
		echo "ERROR: Set PYTHON_REGISTRY_NAME and PYTHON_REGISTRY"; exit 1; \
	fi
	@if ! $(BIN)/poetry source show >/dev/null 2>&1; then \
		echo "ERROR: 'poetry source show' not available"; exit 1; \
	fi
	@if ! $(BIN)/poetry source show "$(PYTHON_REGISTRY_NAME)" 2>/dev/null | grep -q "(is not set)"; then \
		echo "==> Adding source $(PYTHON_REGISTRY_NAME)"; \
		$(BIN)/poetry source add "$(PYTHON_REGISTRY_NAME)" "$(PYTHON_REGISTRY)"; \
		$(BIN)/poetry config "$${PYTHON_CERT:-certificates.$(PYTHON_REGISTRY_NAME).cert}" false; \
	else \
		echo "==> Source $(PYTHON_REGISTRY_NAME) already configured"; \
	fi

# ─── Run ──────────────────────────────────────────────────────────────────────

.PHONY: run
run: ## Run the project (edit the command below)
	$(BIN)/poetry run $(PYTHON) -m $(APP)

.PHONY: shell
shell: ## Activate the venv in a subshell
	@echo "Launching subshell with venv activated…"
	@VIRTUAL_ENV=$(CURDIR)/$(VENV) PATH="$(CURDIR)/$(BIN):$$PATH" $(SHELL)

# ─── CI ───────────────────────────────────────────────────────────────────────

.PHONY: ci
ci: install ## Full CI pipeline: setup + install + check
	$(BIN)/poetry check
	@echo "==> CI passed"

# ─── Housekeeping ─────────────────────────────────────────────────────────────

.PHONY: clean
clean: ## Remove the virtual environment
	rm -rf $(VENV)

.PHONY: info
info: ## Show environment info
	$(BIN)/poetry env info

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'
