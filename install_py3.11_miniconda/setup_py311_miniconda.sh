#!/usr/bin/env bash
# setup_py311_miniconda.sh
# Usage: source setup_py311_miniconda.sh
#
# Installs Miniconda, creates a conda environment with Python 3.11,
# and installs base tooling.
# Must be sourced (not executed) so the env activation persists in your shell.

set -euo pipefail

PYTHON_VERSION="3.11"
CONDA_ENV_NAME="py311"
MINICONDA_DIR="$HOME/miniconda3"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
_info()  { printf '\033[1;34m[INFO]\033[0m  %s\n' "$*"; }
_ok()    { printf '\033[1;32m[OK]\033[0m    %s\n' "$*"; }
_err()   { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*"; }

# ---------------------------------------------------------------------------
# 1. Ensure conda is available (install Miniconda if needed)
# ---------------------------------------------------------------------------
if ! command -v conda &>/dev/null; then
    _info "conda not found — installing Miniconda..."

    ARCH=$(uname -m)
    OS=$(uname -s)

    if [ "$OS" = "Darwin" ]; then
        if [ "$ARCH" = "arm64" ]; then
            INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
        else
            INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
        fi
    elif [ "$OS" = "Linux" ]; then
        if [ "$ARCH" = "aarch64" ]; then
            INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"
        else
            INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
        fi
    else
        _err "Unsupported OS: $OS"
        return 1
    fi

    INSTALLER="/tmp/miniconda_installer.sh"
    _info "Downloading Miniconda from ${INSTALLER_URL}..."
    curl -fsSL -o "$INSTALLER" "$INSTALLER_URL"

    _info "Installing Miniconda to ${MINICONDA_DIR}..."
    bash "$INSTALLER" -b -p "$MINICONDA_DIR"
    rm -f "$INSTALLER"

    _ok "Miniconda installed at ${MINICONDA_DIR}"
fi

# ---------------------------------------------------------------------------
# 2. Initialize conda for the current shell
# ---------------------------------------------------------------------------
if ! command -v conda &>/dev/null; then
    # shellcheck disable=SC1091
    source "${MINICONDA_DIR}/etc/profile.d/conda.sh"
fi

# Ensure conda is initialised (handles both fresh install and existing)
eval "$(conda shell.bash hook 2>/dev/null || "${MINICONDA_DIR}/bin/conda" shell.bash hook)"

_ok "conda $(conda --version | awk '{print $2}') is ready"

# ---------------------------------------------------------------------------
# 3. Update conda itself
# ---------------------------------------------------------------------------
_info "Updating conda..."
conda update -n base -c defaults conda -y --quiet

# ---------------------------------------------------------------------------
# 4. Create the conda environment with Python 3.11
# ---------------------------------------------------------------------------
if conda env list | grep -qE "^${CONDA_ENV_NAME}\s"; then
    _info "Environment '${CONDA_ENV_NAME}' already exists — removing and recreating..."
    conda deactivate 2>/dev/null || true
    conda env remove -n "$CONDA_ENV_NAME" -y
fi

_info "Creating conda environment '${CONDA_ENV_NAME}' with Python ${PYTHON_VERSION}..."
conda create -n "$CONDA_ENV_NAME" python="${PYTHON_VERSION}" -y --quiet
_ok "Environment '${CONDA_ENV_NAME}' created"

# ---------------------------------------------------------------------------
# 5. Activate the environment
# ---------------------------------------------------------------------------
conda activate "$CONDA_ENV_NAME"
_ok "Environment '${CONDA_ENV_NAME}' activated"

# ---------------------------------------------------------------------------
# 6. Install base tooling
# ---------------------------------------------------------------------------
_info "Installing base packages (rich, pipx via pip)..."
pip install --quiet rich pipx

_ok "Base packages installed"

# ---------------------------------------------------------------------------
# 7. Configure conda defaults
# ---------------------------------------------------------------------------
conda config --set auto_activate_base false
_ok "Disabled auto-activation of base environment"

# ---------------------------------------------------------------------------
# 8. Pin the Python version for this directory
# ---------------------------------------------------------------------------
echo "${PYTHON_VERSION}" > .python-version
_ok "Pinned Python ${PYTHON_VERSION} in .python-version"

# ---------------------------------------------------------------------------
# 9. Summary
# ---------------------------------------------------------------------------
echo ""
echo "==========================================="
_ok "Setup complete!"
echo "==========================================="
echo "  Python : $(python --version)"
echo "  conda  : $(conda --version)"
echo "  env    : ${CONDA_ENV_NAME}"
echo "  prefix : $(conda info --envs | grep "${CONDA_ENV_NAME}" | awk '{print $NF}')"
echo "==========================================="
echo ""
echo "To deactivate the env later, run: conda deactivate"
echo ""
echo "Common conda commands:"
echo "  conda install <pkg>          # Install from conda channels"
echo "  conda install -c conda-forge <pkg>  # Install from conda-forge"
echo "  pip install <pkg>            # Install from PyPI (within the env)"
echo "  conda list                   # Show installed packages"
echo "  conda env export > env.yml   # Export environment to YAML"
echo "  conda env create -f env.yml  # Recreate environment from YAML"
