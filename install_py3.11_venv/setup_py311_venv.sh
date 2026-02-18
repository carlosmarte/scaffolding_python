#!/usr/bin/env bash
# setup_py311_venv.sh
# Usage: source setup_py311_venv.sh
#
# Installs Python 3.11 via pyenv, creates a .venv, and installs base tooling.
# Must be sourced (not executed) so the venv activation persists in your shell.

set -euo pipefail

PYTHON_VERSION="3.11"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
_info()  { printf '\033[1;34m[INFO]\033[0m  %s\n' "$*"; }
_ok()    { printf '\033[1;32m[OK]\033[0m    %s\n' "$*"; }
_err()   { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*"; }

# ---------------------------------------------------------------------------
# 1. Ensure pyenv is available
# ---------------------------------------------------------------------------
if ! command -v pyenv &>/dev/null; then
    _info "pyenv not found — installing via Homebrew..."
    if ! command -v brew &>/dev/null; then
        _err "Homebrew is required to install pyenv. Install it from https://brew.sh"
        return 1
    fi
    brew install pyenv
    _ok "pyenv installed"
fi

# Ensure pyenv is initialised in the current shell
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
[[ ":$PATH:" != *":$PYENV_ROOT/bin:"* ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

_ok "pyenv $(pyenv --version | awk '{print $2}') is ready"

# ---------------------------------------------------------------------------
# 2. Install the latest Python 3.11.x patch if not already present
# ---------------------------------------------------------------------------
LATEST_311=$(pyenv install --list | tr -d ' ' | grep -E "^${PYTHON_VERSION}\.[0-9]+$" | sort -V | tail -1)

if [ -z "$LATEST_311" ]; then
    _err "Could not determine latest Python ${PYTHON_VERSION}.x version from pyenv"
    return 1
fi

if pyenv versions --bare | grep -qE "^${LATEST_311}$"; then
    _ok "Python ${LATEST_311} is already installed"
else
    _info "Installing Python ${LATEST_311} (this may take a few minutes)..."
    pyenv install "${LATEST_311}"
    _ok "Python ${LATEST_311} installed"
fi

# ---------------------------------------------------------------------------
# 3. Set the local Python version for this directory
# ---------------------------------------------------------------------------
pyenv local "${LATEST_311}"
_ok "Set local Python version to ${LATEST_311} (.python-version written)"

# Rehash so the shims pick up the new version
pyenv rehash

# ---------------------------------------------------------------------------
# 4. Create the virtual environment
# ---------------------------------------------------------------------------
VENV_DIR=".venv"

if [ -d "$VENV_DIR" ]; then
    _info "Existing ${VENV_DIR} found — removing and recreating..."
    rm -rf "$VENV_DIR"
fi

python -m venv "$VENV_DIR"
_ok "Virtual environment created at ${VENV_DIR}"

# ---------------------------------------------------------------------------
# 5. Activate the venv
# ---------------------------------------------------------------------------
# shellcheck disable=SC1091
source "${VENV_DIR}/bin/activate"
_ok "Virtual environment activated"

# ---------------------------------------------------------------------------
# 6. Upgrade pip and install base tooling
# ---------------------------------------------------------------------------
_info "Upgrading pip..."
python -m pip install --upgrade pip --quiet

_info "Installing base packages (rich, poetry, pipx)..."
python -m pip install rich poetry pipx --quiet

_ok "Base packages installed"

# ---------------------------------------------------------------------------
# 7. Configure Poetry to use the in-project venv
# ---------------------------------------------------------------------------
poetry config virtualenvs.in-project true
_ok "Poetry configured to use in-project virtualenvs"

# ---------------------------------------------------------------------------
# 8. Summary
# ---------------------------------------------------------------------------
echo ""
echo "==========================================="
_ok "Setup complete!"
echo "==========================================="
echo "  Python : $(python --version)"
echo "  pip    : $(pip --version | awk '{print $2}')"
echo "  poetry : $(poetry --version)"
echo "  venv   : ${PWD}/${VENV_DIR}"
echo "==========================================="
echo ""
echo "To deactivate the venv later, run: deactivate"
