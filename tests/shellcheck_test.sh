#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

shellcheck "$REPO_ROOT/setup.sh" "$REPO_ROOT/setup-old.sh"
