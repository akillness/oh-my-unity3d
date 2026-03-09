#!/usr/bin/env bash
# JEO Skill - OpenCode Setup
# Configures: opencode plugin entries and JEO slash commands, and removes legacy agentation config
# Usage: bash setup-opencode.sh [--dry-run]

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC}  $*"; }
info() { echo -e "${BLUE}→${NC} $*"; }

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

OPENCODE_JSON=""
for candidate in "./opencode.json" "${HOME}/.config/opencode/opencode.json" "${HOME}/opencode.json"; do
  [[ -f "$candidate" ]] && OPENCODE_JSON="$candidate" && break
done

echo ""
echo "JEO - OpenCode Setup"
echo "===================="

if ! command -v opencode >/dev/null 2>&1; then
  warn "opencode CLI not found. Install via: npm install -g opencode-ai"
fi

if [[ -z "$OPENCODE_JSON" ]]; then
  OPENCODE_JSON="${HOME}/.config/opencode/opencode.json"
fi

if $DRY_RUN; then
  echo -e "${YELLOW}[DRY-RUN]${NC} Would update $OPENCODE_JSON"
else
  mkdir -p "$(dirname "$OPENCODE_JSON")"
  [[ -f "$OPENCODE_JSON" ]] && cp "$OPENCODE_JSON" "${OPENCODE_JSON}.jeo.bak"

  OPENCODE_JSON_PATH="$OPENCODE_JSON" python3 - <<'PYEOF'
import json
import os

config_path = os.environ["OPENCODE_JSON_PATH"]
try:
    with open(config_path) as f:
        config = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    config = {}

config.setdefault("$schema", "https://opencode.ai/config.json")
plugins = config.setdefault("plugin", [])
for plugin in ("@plannotator/opencode@latest", "@oh-my-opencode/opencode@latest"):
    if plugin not in plugins:
        plugins.append(plugin)

mcp = config.setdefault("mcp", {})
mcp.pop("agentation", None)

commands = config.setdefault("command", {})
commands.pop("jeo-annotate", None)
commands.pop("jeo-agentui", None)
commands["jeo-plan"] = {
    "description": "JEO planning workflow",
    "template": "Write plan.md and run bash .unity-skills/jeo/scripts/plannotator-plan-loop.sh plan.md /tmp/plannotator_feedback.txt 3."
}
commands["jeo-exec"] = {
    "description": "JEO execution workflow",
    "template": "Execute the approved JEO plan with team mode or BMAD."
}
commands["jeo-verify"] = {
    "description": "JEO browser verification",
    "template": "Run agent-browser snapshot for the current browser-facing task."
}
commands["jeo-cleanup"] = {
    "description": "JEO cleanup workflow",
    "template": "Run bash .unity-skills/jeo/scripts/worktree-cleanup.sh"
}

with open(config_path, "w") as f:
    json.dump(config, f, indent=2)

print(f"✓ OpenCode config saved: {config_path}")
PYEOF

  ok "OpenCode configuration updated"
fi

echo ""
echo "OpenCode commands after setup:"
echo "  /jeo-plan"
echo "  /jeo-exec"
echo "  /jeo-verify"
echo "  /jeo-cleanup"
echo ""
ok "OpenCode setup complete"
echo ""
