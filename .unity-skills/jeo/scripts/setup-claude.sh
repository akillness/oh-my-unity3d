#!/usr/bin/env bash
# JEO Skill - Claude Code Setup
# Configures: omc plugin guidance, plannotator hook, team mode, and removes legacy agentation entries
# Usage: bash setup-claude.sh [--dry-run]

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC}  $*"; }
info() { echo -e "${BLUE}→${NC} $*"; }

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

CLAUDE_SETTINGS="${HOME}/.claude/settings.json"

echo ""
echo "JEO - Claude Code Setup"
echo "======================="

if ! command -v claude >/dev/null 2>&1; then
  warn "claude CLI not found. Install Claude Code first."
fi

mkdir -p "$(dirname "$CLAUDE_SETTINGS")"
if [[ -f "$CLAUDE_SETTINGS" ]] && ! $DRY_RUN; then
  cp "$CLAUDE_SETTINGS" "${CLAUDE_SETTINGS}.jeo.bak"
  ok "Backup created: ${CLAUDE_SETTINGS}.jeo.bak"
fi

if $DRY_RUN; then
  echo -e "${YELLOW}[DRY-RUN]${NC} Would update $CLAUDE_SETTINGS"
else
  python3 - <<'PYEOF'
import json
import os

settings_path = os.path.expanduser("~/.claude/settings.json")
try:
    with open(settings_path) as f:
        settings = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    settings = {}

changed = False
messages = []

hooks = settings.setdefault("hooks", {})
perm_req = hooks.setdefault("PermissionRequest", [])
entry = next((item for item in perm_req if item.get("matcher") == "ExitPlanMode"), None)
if entry is None:
    entry = {"matcher": "ExitPlanMode", "hooks": []}
    perm_req.append(entry)
    changed = True

if not any(h.get("command", "").startswith("plannotator") for h in entry.get("hooks", [])):
    entry.setdefault("hooks", []).append({
        "type": "command",
        "command": "plannotator",
        "timeout": 1800,
    })
    changed = True
    messages.append("✓ plannotator PermissionRequest hook added")
else:
    messages.append("✓ plannotator hook already present")

env = settings.setdefault("env", {})
if env.get("CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS") != "1":
    env["CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS"] = "1"
    changed = True
    messages.append("✓ experimental agent teams enabled")
else:
    messages.append("✓ experimental agent teams already enabled")

mcp_servers = settings.setdefault("mcpServers", {})
if "agentation" in mcp_servers:
    mcp_servers.pop("agentation", None)
    changed = True
    messages.append("✓ removed legacy agentation MCP entry")

user_prompt = hooks.get("UserPromptSubmit", [])
new_user_prompt = []
removed = False
for item in user_prompt:
  if "hooks" not in item:
      new_user_prompt.append(item)
      continue
  kept_hooks = []
  for hook in item.get("hooks", []):
      command = hook.get("command", "")
      if "localhost:4747" in command or "agentation" in command:
          removed = True
          changed = True
          continue
      kept_hooks.append(hook)
  if kept_hooks:
      item["hooks"] = kept_hooks
      new_user_prompt.append(item)
hooks["UserPromptSubmit"] = new_user_prompt
if removed:
    messages.append("✓ removed legacy agentation prompt hook")

if changed or not os.path.exists(settings_path):
    with open(settings_path, "w") as f:
        json.dump(settings, f, indent=2)

for message in messages:
    print(message)
PYEOF
  ok "Claude Code settings synced"
fi

echo ""
echo "Manual plugin installation inside Claude Code:"
echo "  /plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode"
echo "  /plugin install oh-my-claudecode"
echo "  /omc:omc-setup"
echo "  /plugin marketplace add backnotprop/plannotator"
echo "  /plugin install plannotator@plannotator"
echo ""
ok "Claude Code setup complete"
echo "  Restart Claude Code to activate hooks and team mode."
echo ""
