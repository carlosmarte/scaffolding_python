# Python 3.11 — uv Setup

One-command setup for a Python 3.11 virtual environment managed by **uv** (Astral).

## Why uv?

- **All-in-one**: manages Python versions, virtual environments, and package installs
- **Fast**: written in Rust, 10–100x faster than pip for dependency resolution and installs
- **Simple**: replaces pyenv + venv + pip + poetry with a single tool

## Prerequisites

- **macOS** with [Homebrew](https://brew.sh) installed, **or** `curl` available (uv will be auto-installed)
- Xcode Command Line Tools: `xcode-select --install`

## Quick Start

```bash
cd /Users/Shared/autoload/scaffolding_python/install_py3.11_uv
source setup_py311_uv.sh
```

> **Important:** Use `source` (not `bash` or `./`) so the venv activation persists in your current shell.

## What the Script Does

| Step | Action |
|------|--------|
| 1 | Installs **uv** via Homebrew or the official installer (if not already present) |
| 2 | Installs **Python 3.11** via uv (if not already available) |
| 3 | Creates a `.venv` virtual environment pinned to Python 3.11 |
| 4 | Activates the venv in your shell |
| 5 | Installs base packages: **rich**, **pipx** |
| 6 | Pins Python version in `.python-version` |

## After Setup

```bash
# Verify
python --version          # Python 3.11.x
which python              # .venv/bin/python

# Deactivate when done
deactivate

# Re-activate later
source .venv/bin/activate
```

## uv Cheat Sheet

### Python Management

```bash
# List available Python versions
uv python list

# Install a specific version
uv python install 3.12

# Find installed Python
uv python find 3.11
```

### Virtual Environments

```bash
# Create venv with specific Python
uv venv --python 3.11

# Create venv at custom path
uv venv --python 3.11 .my-venv
```

### Package Management (pip-compatible)

```bash
# Install packages (blazing fast)
uv pip install requests flask

# Install from requirements file
uv pip install -r requirements.txt

# Show installed packages
uv pip list

# Freeze current environment
uv pip freeze > requirements.txt

# Uninstall
uv pip uninstall requests
```

### Project Management (pyproject.toml)

```bash
# Initialize a new project
uv init

# Add a dependency (updates pyproject.toml + uv.lock)
uv add requests

# Add a dev dependency
uv add --dev pytest

# Sync all dependencies from lock file
uv sync

# Run a script within the project environment
uv run python script.py
```

## Migrating from Poetry

If you have an existing `pyproject.toml` with Poetry dependencies:

```bash
# uv can read pyproject.toml directly
uv sync

# Or export Poetry lock to requirements and install
poetry export -f requirements.txt --output requirements.txt
uv pip install -r requirements.txt
```

## Private Index / Registry

Set these environment variables before running `setup.sh`:

```bash
export PYTHON_REGISTRY_NAME="my-registry"
export PYTHON_REGISTRY_URL="https://my-registry.example.com/simple/"
export PYTHON_REGISTRY_NO_VERIFY=1  # optional: skip TLS verification
source setup.sh
```

Or configure globally in `~/.config/uv/uv.toml`:

```toml
[[index]]
url = "https://my-registry.example.com/simple/"
name = "my-registry"
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `uv` not found after install | Add `$HOME/.local/bin` to your PATH |
| Python version not available | Run `uv python install 3.11` |
| Need to start fresh | Delete `.venv/` and re-run `source setup_py311_uv.sh` |
| Package conflict errors | Delete `.venv/` for a clean resolve, or use `uv pip install --reinstall` |
| Need pip compatibility | uv's `pip` interface is a drop-in replacement — just prefix with `uv` |
