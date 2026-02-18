#!/usr/bin/env bash
# Usage: source setup.sh
# Sets up the Python 3.11 virtual environment, installs dependencies,
# and configures a private Poetry registry if env vars are set.

set -euo pipefail

PYTHON=python3.11

# --- venv ---
if [ ! -d .venv ]; then
    echo "==> Creating virtual environment"
    $PYTHON -m venv .venv
fi

echo "==> Activating virtual environment"
# shellcheck disable=SC1091
source .venv/bin/activate

# --- pip bootstrap ---
echo "==> Installing/upgrading pip and base packages"
$PYTHON -m pip install --upgrade pip
$PYTHON -m pip install --upgrade pyenv uv poetry rich pipx

# --- poetry env ---
echo "==> Configuring Poetry environment"
$PYTHON -m poetry env use $PYTHON
$PYTHON -m poetry --version
$PYTHON -m poetry env info

# --- private registry (optional) ---
if [ -n "${PYTHON_REGISTRY_NAME:-}" ] && [ -n "${PYTHON_REGISTRY_URL:-}" ]; then
    if ! $PYTHON -m poetry source show >/dev/null 2>&1; then
        echo "ERROR: 'poetry source show' is not available in this Poetry version"
        return 1 2>/dev/null || exit 1
    fi

    if ! $PYTHON -m poetry source show "$PYTHON_REGISTRY_NAME" 2>/dev/null | grep -q "(is not set)"; then
        echo "==> Adding Poetry source: $PYTHON_REGISTRY_NAME -> $PYTHON_REGISTRY_URL"
        $PYTHON -m poetry source add "$PYTHON_REGISTRY_NAME" "$PYTHON_REGISTRY_URL"
        $PYTHON -m poetry config "${PYTHON_CERT:-certificates.${PYTHON_REGISTRY_NAME}.cert}" false
    else
        echo "==> Poetry source '$PYTHON_REGISTRY_NAME' already configured"
    fi
else
    echo "==> Skipping private registry (PYTHON_REGISTRY_NAME / PYTHON_REGISTRY_URL not set)"
fi

echo "==> Setup complete"
