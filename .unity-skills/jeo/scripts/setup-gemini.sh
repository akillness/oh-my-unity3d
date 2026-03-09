#!/usr/bin/env bash
# JEO Skill - Gemini CLI Setup
# Configures: plannotator-oriented AfterAgent helper, GEMINI.md instructions, and removes legacy agentation config
# Usage: bash setup-gemini.sh [--dry-run] [--hook-only] [--md-only]

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC}  $*"; }
info() { echo -e "${BLUE}→${NC} $*"; }

DRY_RUN=false
HOOK_ONLY=false
MD_ONLY=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --hook-only) HOOK_ONLY=true ;;
    --md-only) MD_ONLY=true ;;
  esac
done

JEO_SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GEMINI_SETTINGS="${HOME}/.gemini/settings.json"
GEMINI_MD="${HOME}/.gemini/GEMINI.md"
GEMINI_HOOK_DIR="${HOME}/.gemini/hooks"
PLANNOTATOR_HOOK="${GEMINI_HOOK_DIR}/jeo-plannotator.sh"
LEGACY_AGENTATION_HOOK="${GEMINI_HOOK_DIR}/jeo-agentation.sh"

echo ""
echo "JEO - Gemini CLI Setup"
echo "======================"

if ! command -v gemini >/dev/null 2>&1; then
  warn "gemini CLI not found. Install via: npm install -g @google/gemini-cli"
fi

if ! $MD_ONLY; then
  if $DRY_RUN; then
    echo -e "${YELLOW}[DRY-RUN]${NC} Would update $GEMINI_SETTINGS and hook files"
  else
    mkdir -p "$(dirname "$GEMINI_SETTINGS")" "$GEMINI_HOOK_DIR"
    [[ -f "$GEMINI_SETTINGS" ]] && cp "$GEMINI_SETTINGS" "${GEMINI_SETTINGS}.jeo.bak"

    cat > "$PLANNOTATOR_HOOK" <<'HOOKEOF'
#!/usr/bin/env bash
# JEO AfterAgent backup hook - only active during PLAN

JEO_STATE="${PWD}/.omc/state/jeo-state.json"
if [[ ! -f "$JEO_STATE" ]]; then
  exit 0
fi

PHASE=$(python3 -c "
import json
try:
    print(json.load(open('$JEO_STATE')).get('phase', 'unknown'))
except Exception:
    print('unknown')
" 2>/dev/null || echo "unknown")

if [[ "$PHASE" != "plan" ]]; then
  exit 0
fi

PLAN_FILE="$(pwd)/plan.md"
[[ -f "$PLAN_FILE" ]] || exit 0

LOOP_SCRIPT=""
for candidate in \
  "$(pwd)/.agent-skills/jeo/scripts/plannotator-plan-loop.sh" \
  "$HOME/.codex/skills/jeo/scripts/plannotator-plan-loop.sh" \
  "$HOME/.agent-skills/jeo/scripts/plannotator-plan-loop.sh"
do
  if [[ -f "$candidate" ]]; then
    LOOP_SCRIPT="$candidate"
    break
  fi
done

[[ -n "$LOOP_SCRIPT" ]] || exit 0
bash "$LOOP_SCRIPT" "$PLAN_FILE" /tmp/plannotator_feedback.txt 3 || true
HOOKEOF
    chmod +x "$PLANNOTATOR_HOOK"
    rm -f "$LEGACY_AGENTATION_HOOK"

    python3 - <<'PYEOF'
import json
import os

settings_path = os.path.expanduser("~/.gemini/settings.json")
try:
    with open(settings_path) as f:
        settings = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    settings = {}

hooks = settings.setdefault("hooks", {})
after_agent = hooks.setdefault("AfterAgent", [])
hook_path = os.path.expanduser("~/.gemini/hooks/jeo-plannotator.sh")

cleaned = []
for entry in after_agent:
    hooks_list = entry.get("hooks", [])
    kept = []
    for hook in hooks_list:
        command = hook.get("command", "")
        if "jeo-agentation" in command or "agentation" in command:
            continue
        kept.append(hook)
    if kept:
        entry["hooks"] = kept
        cleaned.append(entry)
after_agent = cleaned

exists = any(
    any("jeo-plannotator" in hook.get("command", "") for hook in entry.get("hooks", []))
    for entry in after_agent
)
if not exists:
    after_agent.append({
        "matcher": "",
        "hooks": [{
            "name": "plannotator-review",
            "type": "command",
            "command": f"bash {hook_path}",
            "timeout": 1800,
            "description": "Run the JEO plannotator gate when plan.md exists"
        }]
    })

hooks["AfterAgent"] = after_agent
mcp_servers = settings.setdefault("mcpServers", {})
mcp_servers.pop("agentation", None)

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)

print("✓ Gemini settings updated")
PYEOF
    ok "Gemini CLI settings updated"
  fi
fi

if ! $HOOK_ONLY; then
  JEO_SECTION=$(cat <<JEOEOF

## JEO Orchestration Workflow

Keyword: \`jeo\`

### PLAN
1. Write \`plan.md\`
2. Run:
   \`\`\`bash
   bash ${JEO_SKILL_DIR}/scripts/plannotator-plan-loop.sh plan.md /tmp/plannotator_feedback.txt 3
   \`\`\`
3. Proceed only when \`approved=true\`

### EXECUTE
- Prefer BMAD when no native team execution is available
- Use \`/workflow-init\`
- Use \`/workflow-status\`

### VERIFY
- Run \`agent-browser snapshot http://localhost:3000\` for browser-facing tasks

### CLEANUP
- Run \`bash ${JEO_SKILL_DIR}/scripts/worktree-cleanup.sh\`
JEOEOF
)

  if $DRY_RUN; then
    echo -e "${YELLOW}[DRY-RUN]${NC} Would append JEO section to $GEMINI_MD"
  else
    mkdir -p "$(dirname "$GEMINI_MD")"
    [[ -f "$GEMINI_MD" ]] && cp "$GEMINI_MD" "${GEMINI_MD}.jeo.bak"
    if [[ -f "$GEMINI_MD" ]] && grep -q "## JEO Orchestration Workflow" "$GEMINI_MD"; then
      ok "JEO section already present in GEMINI.md"
    else
      printf "%s\n" "$JEO_SECTION" >> "$GEMINI_MD"
      ok "JEO instructions added to GEMINI.md"
    fi
  fi
fi

echo ""
echo "Gemini CLI usage after setup:"
echo "  gemini --approval-mode plan"
echo "  /workflow-init"
echo "  bash ${JEO_SKILL_DIR}/scripts/plannotator-plan-loop.sh plan.md /tmp/plannotator_feedback.txt 3"
echo ""
ok "Gemini CLI setup complete"
echo ""
