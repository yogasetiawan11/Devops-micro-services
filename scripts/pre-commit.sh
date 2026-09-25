#!/bin/bash

set -euo pipefail

VENV_DIR=".venv"

# --- Cek apakah sudah ada di dalam venv ---
if [[ -n "${VIRTUAL_ENV:-}" ]]; then
    echo "✅ Already inside a virtualenv: $VIRTUAL_ENV"
    pip install --upgrade pre-commit
else
    # --- Coba install ke system/user dulu ---
    if pip install --user pre-commit 2>/dev/null; then
        echo "✅ pre-commit installed globally (user scope)"
    else
        echo "⚠️  Global install failed. Falling back to venv..."
        
        if [[ ! -d "$VENV_DIR" ]]; then
            python3 -m venv "$VENV_DIR"
            echo "✅ venv created at $VENV_DIR"
        else
            echo "ℹ️  Reusing existing venv at $VENV_DIR"
        fi
        
        # shellcheck disable=SC1091
        source "$VENV_DIR/bin/activate"
        echo "✅ venv activated: $VIRTUAL_ENV"
        
        pip install --upgrade pip
        pip install --upgrade pre-commit
    fi
fi

# --- Verifikasi pre-commit tersedia ---
if ! command -v pre-commit &>/dev/null; then
    echo "❌ pre-commit tidak ditemukan setelah instalasi. Cek PATH lo."
    exit 1
fi

# --- Update hook versions ---
if [[ -f .pre-commit-config.yaml ]]; then
    echo "🔄 Running pre-commit autoupdate..."
    pre-commit autoupdate
else
    echo "ℹ️  .pre-commit-config.yaml belum ada. Skip autoupdate."
    echo "   Jalankan: pre-commit sample-config > .pre-commit-config.yaml"
fi

echo "🎉 Selesai."