#!/usr/bin/env bash
# setup_py311_uv.sh
# Usage: source setup_py311_uv.sh
#
# Installs Python 3.11 via uv, creates a .venv, and installs base tooling.
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
# 1. Ensure uv is available
# ---------------------------------------------------------------------------
if ! command -v uv &>/dev/null; then
    _info "uv not found — installing via Homebrew..."
    if command -v brew &>/dev/null; then
        brew install uv
    else
        _info "Homebrew not found — installing uv via official installer..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        # Add to current shell path
        export PATH="$HOME/.local/bin:$PATH"
    fi

    if ! command -v uv &>/dev/null; then
        _err "Failed to install uv"
        return 1
    fi
    _ok "uv installed"
fi

_ok "uv $(uv --version | awk '{print $2}') is ready"

# ---------------------------------------------------------------------------
# 2. Install Python 3.11 via uv (if not already present)
# ---------------------------------------------------------------------------
if uv python find "${PYTHON_VERSION}" &>/dev/null; then
    _ok "Python ${PYTHON_VERSION} is already available"
else
    _info "Installing Python ${PYTHON_VERSION} (this is usually very fast)..."
    uv python install "${PYTHON_VERSION}"
    _ok "Python ${PYTHON_VERSION} installed"
fi

# ---------------------------------------------------------------------------
# 3. Create the virtual environment
# ---------------------------------------------------------------------------
VENV_DIR=".venv"

if [ -d "$VENV_DIR" ]; then
    _info "Existing ${VENV_DIR} found — removing and recreating..."
    rm -rf "$VENV_DIR"
fi

uv venv --python "${PYTHON_VERSION}" "$VENV_DIR"
_ok "Virtual environment created at ${VENV_DIR}"

# ---------------------------------------------------------------------------
# 4. Activate the venv
# ---------------------------------------------------------------------------
# shellcheck disable=SC1091
source "${VENV_DIR}/bin/activate"
_ok "Virtual environment activated"

# ---------------------------------------------------------------------------
# 5. Install base tooling via uv
# ---------------------------------------------------------------------------
_info "Installing base packages (rich, pipx)..."
uv pip install rich pipx

_ok "Base packages installed"

# ---------------------------------------------------------------------------
# 6. Pin the Python version for this directory
# ---------------------------------------------------------------------------
echo "${PYTHON_VERSION}" > .python-version
_ok "Pinned Python ${PYTHON_VERSION} in .python-version"

# ---------------------------------------------------------------------------
# 7. Summary
# ---------------------------------------------------------------------------
echo ""
echo "==========================================="
_ok "Setup complete!"
echo "==========================================="
echo "  Python : $(python --version)"
echo "  uv     : $(uv --version)"
echo "  venv   : ${PWD}/${VENV_DIR}"
echo "==========================================="
echo ""
echo "To deactivate the venv later, run: deactivate"
echo ""
echo "Common uv commands:"
echo "  uv pip install <pkg>       # Install a package (fast!)"
echo "  uv pip install -r req.txt  # Install from requirements file"
echo "  uv add <pkg>               # Add dependency to pyproject.toml"
echo "  uv sync                    # Sync all dependencies from lock file"
echo "  uv run <script.py>         # Run a script in the venv"
