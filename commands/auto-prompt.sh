#!/usr/bin/env bash
# auto-prompt — wrapper untuk skills/auto-prompt/run.sh
# Usage: bash commands/auto-prompt.sh "input user"
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec bash "$SCRIPT_DIR/../skills/auto-prompt/run.sh" "$@"
