#!/usr/bin/env bash
# Usage: source setup.sh
# Quick setup: installs Miniconda if needed, creates a conda env with Python 3.11,
# installs dependencies, and configures a private channel if env vars are set.

set -euo pipefail

PYTHON_VERSION="3.11"
CONDA_ENV_NAME="py311"
MINICONDA_DIR="$HOME/miniconda3"

# --- ensure conda ---
if ! command -v conda &>/dev/null; then
    echo "==> conda not found — installing Miniconda..."
    ARCH=$(uname -m)
    OS=$(uname -s)
    if [ "$OS" = "Darwin" ]; then
        [ "$ARCH" = "arm64" ] && SUFFIX="MacOSX-arm64" || SUFFIX="MacOSX-x86_64"
    else
        [ "$ARCH" = "aarch64" ] && SUFFIX="Linux-aarch64" || SUFFIX="Linux-x86_64"
    fi
    curl -fsSL -o /tmp/miniconda.sh "https://repo.anaconda.com/miniconda/Miniconda3-latest-${SUFFIX}.sh"
    bash /tmp/miniconda.sh -b -p "$MINICONDA_DIR"
    rm -f /tmp/miniconda.sh
fi

# --- initialize conda ---
if ! command -v conda &>/dev/null; then
    # shellcheck disable=SC1091
    source "${MINICONDA_DIR}/etc/profile.d/conda.sh"
fi
eval "$(conda shell.bash hook 2>/dev/null || "${MINICONDA_DIR}/bin/conda" shell.bash hook)"

# --- create env ---
if ! conda env list | grep -qE "^${CONDA_ENV_NAME}\s"; then
    echo "==> Creating conda environment '${CONDA_ENV_NAME}' with Python ${PYTHON_VERSION}"
    conda create -n "$CONDA_ENV_NAME" python="${PYTHON_VERSION}" -y --quiet
fi

echo "==> Activating environment '${CONDA_ENV_NAME}'"
conda activate "$CONDA_ENV_NAME"

# --- install base packages ---
echo "==> Installing base packages"
pip install --quiet --upgrade rich pipx

# --- private channel (optional) ---
if [ -n "${CONDA_CHANNEL_NAME:-}" ] && [ -n "${CONDA_CHANNEL_URL:-}" ]; then
    echo "==> Adding private conda channel: ${CONDA_CHANNEL_NAME}"
    conda config --env --add channels "$CONDA_CHANNEL_URL"

    if [ -n "${CONDA_CHANNEL_NO_VERIFY:-}" ]; then
        conda config --env --set ssl_verify false
    fi

    echo "==> Private channel configured for this environment"
elif [ -n "${PYTHON_REGISTRY_NAME:-}" ] && [ -n "${PYTHON_REGISTRY_URL:-}" ]; then
    echo "==> Configuring private PyPI index: ${PYTHON_REGISTRY_NAME}"
    pip config --site set global.extra-index-url "$PYTHON_REGISTRY_URL"

    if [ -n "${PYTHON_REGISTRY_NO_VERIFY:-}" ]; then
        pip config --site set global.trusted-host "${PYTHON_REGISTRY_URL#https://}"
    fi

    echo "==> Private PyPI index configured for this environment"
else
    echo "==> Skipping private channel/registry (not configured)"
fi

echo "==> Setup complete"
