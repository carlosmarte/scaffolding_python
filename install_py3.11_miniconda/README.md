# Python 3.11 — Miniconda Setup

One-command setup for a Python 3.11 environment managed by **Miniconda**.

## Why Miniconda?

- **Scientific computing**: first-class support for NumPy, SciPy, pandas, and other C-extension-heavy packages with pre-built binaries
- **Cross-language packages**: can install non-Python dependencies (C libraries, R, Node.js) in the same environment
- **Reproducible environments**: `environment.yml` captures the full dependency tree including system-level libs
- **Conflict resolution**: conda's SAT solver handles complex dependency graphs that pip sometimes can't

## Prerequisites

- **macOS** or **Linux** (the installer is auto-detected for your architecture)
- `curl` available in your shell
- ~400 MB disk space for Miniconda + the Python 3.11 environment

## Quick Start

```bash
cd /Users/Shared/autoload/scaffolding_python/install_py3.11_miniconda
source setup_py311_miniconda.sh
```

> **Important:** Use `source` (not `bash` or `./`) so the environment activation persists in your current shell.

## What the Script Does

| Step | Action |
|------|--------|
| 1 | Downloads and installs **Miniconda** to `~/miniconda3` (if not already present) |
| 2 | Initializes conda for the current shell session |
| 3 | Updates conda to the latest version |
| 4 | Creates a conda environment `py311` with **Python 3.11** |
| 5 | Activates the environment in your shell |
| 6 | Installs base packages: **rich**, **pipx** |
| 7 | Disables auto-activation of the `base` environment |
| 8 | Pins Python version in `.python-version` |

## After Setup

```bash
# Verify
python --version          # Python 3.11.x
which python              # ~/miniconda3/envs/py311/bin/python

# Deactivate when done
conda deactivate

# Re-activate later
conda activate py311
```

## Conda Cheat Sheet

### Environment Management

```bash
# List all environments
conda env list

# Create a new environment
conda create -n myenv python=3.12

# Clone an environment
conda create -n myenv-copy --clone myenv

# Remove an environment
conda env remove -n myenv

# Export environment to YAML (full reproducibility)
conda env export > environment.yml

# Recreate from YAML
conda env create -f environment.yml
```

### Package Management

```bash
# Install from default channel
conda install numpy pandas scikit-learn

# Install from conda-forge (community channel, largest selection)
conda install -c conda-forge polars

# Install from PyPI (within the active env)
pip install some-pypi-package

# Search for a package
conda search tensorflow

# List installed packages
conda list

# Update a package
conda update numpy

# Update all packages in the environment
conda update --all

# Remove a package
conda remove numpy
```

### Channel Management

```bash
# Add conda-forge as a default channel
conda config --add channels conda-forge

# Set channel priority (strict = only use higher-priority channels first)
conda config --set channel_priority strict

# Show current channels
conda config --show channels
```

## Conda vs pip — When to Use Which

| Use conda for | Use pip for |
|---------------|-------------|
| NumPy, SciPy, pandas, scikit-learn | Pure-Python packages not on conda |
| Packages with C/Fortran extensions | Packages only available on PyPI |
| Non-Python dependencies (CUDA, MKL) | Development tools (black, ruff, mypy) |
| Reproducible scientific environments | Quick installs of simple packages |

> **Tip:** You can mix conda and pip in the same environment. Install conda packages first, then pip packages.

## Private Channel / Registry

### Conda channels

Set these environment variables before running `setup.sh`:

```bash
export CONDA_CHANNEL_NAME="my-channel"
export CONDA_CHANNEL_URL="https://my-conda-repo.example.com/"
export CONDA_CHANNEL_NO_VERIFY=1  # optional: skip TLS verification
source setup.sh
```

### PyPI index (for pip within conda)

```bash
export PYTHON_REGISTRY_NAME="my-registry"
export PYTHON_REGISTRY_URL="https://my-registry.example.com/simple/"
export PYTHON_REGISTRY_NO_VERIFY=1  # optional: skip TLS verification
source setup.sh
```

Or configure globally in `~/.condarc`:

```yaml
channels:
  - https://my-conda-repo.example.com/
  - conda-forge
  - defaults
```

## Shell Integration (One-Time)

To have `conda` available in every new shell, run:

```bash
~/miniconda3/bin/conda init zsh    # or bash
```

Then reload: `source ~/.zshrc`

> The script sets `auto_activate_base false` so your shell won't start in the `base` environment by default.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `conda` not found after install | Run `source ~/miniconda3/etc/profile.d/conda.sh` or `conda init zsh` |
| Environment creation is slow | Use `conda install -c conda-forge conda-libmamba-solver` then `conda config --set solver libmamba` |
| Conflicts between conda and pip | Install all conda packages first, then pip packages; avoid mixing for the same package |
| Need to start fresh | `conda env remove -n py311` then re-run the script |
| `Solving environment` hangs | Switch to libmamba solver (see above) or use `--no-update-deps` |
| Disk space issues | Run `conda clean --all` to remove cached packages and tarballs |
