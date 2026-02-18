# Python 3.11 — pyenv + venv Setup

One-command setup for a Python 3.11 virtual environment managed by **pyenv**.

## Prerequisites

- **macOS** with [Homebrew](https://brew.sh) installed (pyenv will be auto-installed if missing)
- Xcode Command Line Tools: `xcode-select --install`

## Quick Start

```bash
cd /Users/Shared/autoload/scaffolding_python/install_py3.11_venv
source setup_py311_venv.sh
```

> **Important:** Use `source` (not `bash` or `./`) so the venv activation persists in your current shell.

## What the Script Does

| Step | Action |
|------|--------|
| 1 | Installs **pyenv** via Homebrew (if not already present) |
| 2 | Installs the latest **Python 3.11.x** patch via pyenv |
| 3 | Sets the local Python version for this directory (`.python-version`) |
| 4 | Creates a `.venv` virtual environment |
| 5 | Activates the venv in your shell |
| 6 | Upgrades **pip** and installs **rich**, **poetry**, **pipx** |
| 7 | Configures Poetry to use in-project virtualenvs |

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

## pyenv Cheat Sheet

```bash
# List all installable versions
pyenv install --list

# Install a specific version
pyenv install 3.12.2

# Set the global default
pyenv global 3.12.2

# Set a per-project version (writes .python-version)
pyenv local 3.11.8

# Show current version
pyenv version

# List installed versions
pyenv versions
```

## Shell Integration (One-Time)

Add the following to your `~/.zshrc` (or `~/.bashrc`) if not already present:

```bash
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

Then reload: `source ~/.zshrc`

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `pyenv install` fails with build errors | Install build deps: `brew install openssl readline sqlite3 xz zlib tcl-tk` |
| `python` still points to system Python | Run `pyenv rehash` and ensure shell integration is in your rc file |
| Poetry can't find the right Python | Run `poetry env use python` inside the activated venv |
