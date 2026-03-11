#!/usr/bin/env bash
# OMU helper — guarantees plannotator is available before PLAN.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_ROOT="$(dirname "$SKILL_DIR")"

QUIET=false

for arg in "$@"; do
  case "$arg" in
    --quiet) QUIET=true ;;
    -h|--help)
      echo "Usage: bash ensure-plannotator.sh [--quiet]"
      echo "Ensures the plannotator CLI is installed before OMU PLAN runs."
      exit 0
      ;;
  esac
done

log() {
  if ! $QUIET; then
    echo "$@"
  fi
}

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

if command -v plannotator >/dev/null 2>&1; then
  log "[OMU][PLAN] plannotator already available: $(command -v plannotator)"
  exit 0
fi

if [[ "${OMU_SKIP_PLANNOTATOR_AUTO_INSTALL:-0}" == "1" ]]; then
  echo "[OMU][PLAN] plannotator not found and auto-install is disabled." >&2
  exit 127
fi

INSTALL_CANDIDATES=(
  "$SKILLS_ROOT/plannotator/scripts/install.sh"
  "$HOME/.agent-skills/plannotator/scripts/install.sh"
  "$HOME/.codex/skills/plannotator/scripts/install.sh"
)

for candidate in "${INSTALL_CANDIDATES[@]}"; do
  if [[ ! -f "$candidate" ]]; then
    continue
  fi

  log "[OMU][PLAN] plannotator missing. Installing via $candidate"
  if bash "$candidate"; then
    export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
    if command -v plannotator >/dev/null 2>&1; then
      log "[OMU][PLAN] plannotator installation completed: $(command -v plannotator)"
      exit 0
    fi
  fi

  echo "[OMU][PLAN] installer finished but plannotator is still unavailable: $candidate" >&2
done

echo "[OMU][PLAN] plannotator auto-install failed. Run: bash scripts/install.sh --with-plannotator" >&2
exit 127
