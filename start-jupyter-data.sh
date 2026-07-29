#!/usr/bin/env bash
set -Eeuo pipefail

# Start JupyterLab while storing runtime/temp files on /mnt/data.
#
# Usage:
#   ./start-jupyter-data.sh [NOTEBOOK_DIRECTORY]
#
# Example:
#   ./start-jupyter-data.sh /mnt/data/practical2

JUPYTER_BIN="${JUPYTER_BIN:-/usr/local/share/course/bin/jupyter-lab}"
NOTEBOOK_DIR="${1:-/mnt/data}"
BASE="${JUPYTER_BASE:-/mnt/data/${USER}/jupyter}"

pause_on_exit() {
    status=$?
    echo
    if (( status == 0 )); then
        echo "JupyterLab stopped."
    else
        echo "JupyterLab exited with status ${status}."
    fi

    if [[ -t 0 ]]; then
        read -r -p "Press Enter to close this terminal..." || true
    fi
}
trap pause_on_exit EXIT

if [[ ! -x "$JUPYTER_BIN" ]]; then
    echo "Error: JupyterLab executable not found at:"
    echo "  $JUPYTER_BIN"
    echo
    echo "Set JUPYTER_BIN to the correct path and try again."
    exit 1
fi

if [[ ! -d "$NOTEBOOK_DIR" ]]; then
    echo "Error: notebook directory does not exist:"
    echo "  $NOTEBOOK_DIR"
    exit 1
fi

if [[ ! -r "$NOTEBOOK_DIR" ]]; then
    echo "Error: notebook directory is not readable:"
    echo "  $NOTEBOOK_DIR"
    exit 1
fi

mkdir -p \
    "$BASE/runtime" \
    "$BASE/tmp" \
    "$BASE/notebooks" \
    "$BASE/config" \
    "$BASE/data" \
    "$BASE/cache" \
    "$BASE/ipython"

chmod 700 "$BASE/runtime" "$BASE/tmp"

export JUPYTER_RUNTIME_DIR="$BASE/runtime"
export JUPYTER_CONFIG_DIR="$BASE/config"
export JUPYTER_DATA_DIR="$BASE/data"
export XDG_CACHE_HOME="$BASE/cache"
export IPYTHONDIR="$BASE/ipython"
export TMPDIR="$BASE/tmp"

echo "Starting JupyterLab"
echo "Notebook directory: $NOTEBOOK_DIR"
echo "Runtime directory:  $JUPYTER_RUNTIME_DIR"
echo
echo "Keep this terminal open."
echo "Copy the http://localhost:... URL into your browser."
echo

"$JUPYTER_BIN" \
    --no-browser \
    --ServerApp.root_dir="$NOTEBOOK_DIR"
