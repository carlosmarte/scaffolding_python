#!/usr/bin/env bash
# Usage: source setup.sh
# Quick setup: creates a Python 3.11 venv with uv, installs dependencies,
# and configures a private PyPI index if env vars are set.

set -euo pipefail

PYTHON_VERSION="3.11"

# --- ensure uv ---
if ! command -v uv &>/dev/null; then
    echo "==> uv not found — installing..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# --- install python ---
if ! uv python find "${PYTHON_VERSION}" &>/dev/null; then
    echo "==> Installing Python ${PYTHON_VERSION}"
    uv python install "${PYTHON_VERSION}"
fi

# --- venv ---
if [ ! -d .venv ]; then
    echo "==> Creating virtual environment"
    uv venv --python "${PYTHON_VERSION}" .venv
fi

echo "==> Activating virtual environment"
# shellcheck disable=SC1091
source .venv/bin/activate

# --- install base packages ---
echo "==> Installing base packages"
uv pip install --upgrade rich pipx

# --- private index (optional) ---
if [ -n "${PYTHON_REGISTRY_NAME:-}" ] && [ -n "${PYTHON_REGISTRY_URL:-}" ]; then
    echo "==> Installing from private index: ${PYTHON_REGISTRY_NAME}"
    # uv supports --index-url / --extra-index-url directly
    # You can also set UV_EXTRA_INDEX_URL in your environment
    export UV_EXTRA_INDEX_URL="${PYTHON_REGISTRY_URL}"

    if [ -n "${PYTHON_REGISTRY_NO_VERIFY:-}" ]; then
        export UV_INSECURE_HOST="${PYTHON_REGISTRY_URL#https://}"
        export UV_INSECURE_HOST="${UV_INSECURE_HOST%%/*}"
    fi

    echo "==> Private index configured (UV_EXTRA_INDEX_URL set for this session)"
else
    echo "==> Skipping private index (PYTHON_REGISTRY_NAME / PYTHON_REGISTRY_URL not set)"
fi

echo "==> Setup complete"
