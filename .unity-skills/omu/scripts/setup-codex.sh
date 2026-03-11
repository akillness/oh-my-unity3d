#!/usr/bin/env bash
# OMU Skill - Codex CLI Setup
# Configures: developer_instructions, /prompts:omu, PLAN_READY notify hook, and removes legacy agentation config
# Usage: bash setup-codex.sh [--dry-run]

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC}  $*"; }
info() { echo -e "${BLUE}→${NC} $*"; }

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

OMU_SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEX_CONFIG="${HOME}/.codex/config.toml"
CODEX_PROMPTS_DIR="${HOME}/.codex/prompts"
HOOK_DIR="${HOME}/.codex/hooks"
HOOK_FILE="${HOOK_DIR}/omu-notify.py"
OMU_PROMPT_FILE="${CODEX_PROMPTS_DIR}/omu.md"

echo ""
echo "OMU - Codex CLI Setup"
echo "====================="

if ! command -v codex >/dev/null 2>&1; then
  warn "codex CLI not found. Install via: npm install -g @openai/codex"
fi

if $DRY_RUN; then
  echo -e "${YELLOW}[DRY-RUN]${NC} Would update $CODEX_CONFIG, $OMU_PROMPT_FILE, and $HOOK_FILE"
else
  mkdir -p "$(dirname "$CODEX_CONFIG")" "$CODEX_PROMPTS_DIR" "$HOOK_DIR"
  [[ -f "$CODEX_CONFIG" ]] && cp "$CODEX_CONFIG" "${CODEX_CONFIG}.omu.bak"

  OMU_INSTRUCTION=$(cat <<OMUEOF
# OMU Orchestration Workflow
# Keyword: omu | Platforms: Codex, Claude, Gemini, OpenCode
#
# OMU provides integrated AI orchestration:
#   1. PLAN: ralph+plannotator for visual plan review
#   2. EXECUTE: team (if available) or bmad workflow
#   3. VERIFY: agent-browser snapshot for UI verification
#   4. CLEANUP: auto worktree cleanup after completion
#
# Trigger with: omu "<task description>"
# Use /prompts:omu for full workflow activation
#
# PLAN phase protocol (Codex):
#   1. Write plan to plan.md
#   2. Run mandatory PLAN gate:
#      bash ${OMU_SKILL_DIR}/scripts/plannotator-plan-loop.sh plan.md /tmp/plannotator_feedback.txt 3
#   3. Output "PLAN_READY" to trigger the backup notify hook
#   4. Check result:
#      - approved=true -> EXECUTE
#      - approved=false -> re-plan
#      - exit 32 -> use manual conversation approval
#
# BMAD commands:
#   /workflow-init
#   /workflow-status
#
# Tools: agent-browser, playwriter, plannotator
OMUEOF
)

  python3 - <<PYEOF
import os
import re

config_path = os.path.expanduser("~/.codex/config.toml")
omu_instruction = """${OMU_INSTRUCTION}"""

try:
    content = open(config_path).read() if os.path.exists(config_path) else ""
except Exception:
    content = ""

content = re.sub(r'(?ms)^developer_instructions\s*=\s*(""".*?"""|".*?")\s*$', '', content).strip()
content = re.sub(r'(?ms)^\[mcp_servers\.agentation\]\n.*?(?=^\[|\Z)', '', content)
content = re.sub(r'(?ms)^\[\[mcp_servers\]\]\s*\nname\s*=\s*"agentation"\s*\n.*?(?=^\[\[mcp_servers\]\]|\Z)', '', content)
content = re.sub(r'(?m)^notify\s*=.*$', '', content)

new_assignment = 'developer_instructions = """\n' + omu_instruction.strip() + '\n"""\n'
first_table = re.search(r'(?m)^\[', content)
if first_table:
    content = new_assignment + "\n" + content[first_table.start():]
else:
    content = new_assignment + ("\n" + content if content else "")

notify_line = f'notify = ["python3", "{os.path.expanduser("~/.codex/hooks/omu-notify.py")}"]\n'
first_table = re.search(r'(?m)^\[', content)
if first_table:
    content = content[:first_table.start()] + notify_line + "\n" + content[first_table.start():]
else:
    content = content + "\n" + notify_line

tui_match = re.search(r'(?ms)^\[tui\]\s*\n(.*?)(?=^\[|\Z)', content)
if not tui_match:
    content = content.rstrip() + '\n\n[tui]\nnotifications = ["agent-turn-complete"]\nnotification_method = "osc9"\n'
else:
    body = tui_match.group(1)
    notifications = re.findall(r'"([^"]+)"', re.search(r'(?m)^notifications\s*=\s*\[(.*?)\]\s*$', body).group(1)) if re.search(r'(?m)^notifications\s*=\s*\[(.*?)\]\s*$', body) else []
    if "agent-turn-complete" not in notifications:
        notifications.append("agent-turn-complete")
    notif_line = 'notifications = [' + ', '.join(f'"{item}"' for item in notifications) + ']'
    if re.search(r'(?m)^notifications\s*=', body):
        body = re.sub(r'(?m)^notifications\s*=.*$', notif_line, body, count=1)
    else:
        body = notif_line + '\n' + body
    if re.search(r'(?m)^notification_method\s*=', body):
        body = re.sub(r'(?m)^notification_method\s*=.*$', 'notification_method = "osc9"', body, count=1)
    else:
        body = body.rstrip() + '\nnotification_method = "osc9"\n'
    content = content[:tui_match.start(1)] + body + content[tui_match.end(1):]

with open(config_path, "w") as f:
    f.write(content.strip() + "\n")

print("✓ Codex config updated")
PYEOF

  cat > "$OMU_PROMPT_FILE" <<PROMPTEOF
# OMU - Integrated Agent Orchestration Prompt

You are now operating in OMU mode.

## Workflow

### Step 1: PLAN
1. Write \`plan.md\` with goal, steps, risks, and completion criteria.
2. Run:
   \`\`\`bash
   bash ${OMU_SKILL_DIR}/scripts/plannotator-plan-loop.sh plan.md /tmp/plannotator_feedback.txt 3
   echo "PLAN_READY"
   \`\`\`
3. Proceed only if \`approved=true\`.
4. If the plan is rejected, revise \`plan.md\` and repeat.
5. If the loop exits with \`32\`, output the plan in the conversation and wait for manual approval.

### Step 2: EXECUTE
- Use \`/workflow-init\`
- Use \`/workflow-status\`
- Implement only after plan approval

### Step 3: VERIFY
- Run \`agent-browser snapshot http://localhost:3000\` for browser-facing tasks
- Capture screenshots when helpful

### Step 4: CLEANUP
- Run \`bash ${OMU_SKILL_DIR}/scripts/worktree-cleanup.sh\`
- Run \`git worktree prune\`

## State File

Save progress to \`.omc/state/omu-state.json\`:

\`\`\`json
{
  "mode": "omu",
  "phase": "plan|execute|verify|cleanup|done",
  "task": "current task description",
  "plan_approved": false,
  "team_available": false,
  "retry_count": 0,
  "last_error": null,
  "checkpoint": null
}
\`\`\`
PROMPTEOF

  cat > "$HOOK_FILE" <<'HOOKEOF'
#!/usr/bin/env python3
"""OMU Codex notify hook - triggers the plannotator plan gate when PLAN_READY is emitted."""
import hashlib
import json
import os
import re
import subprocess
import sys

PLAN_SIGNALS = ["PLAN_READY"]

def get_phase(cwd: str) -> str:
    state_path = os.path.join(cwd, ".omc", "state", "omu-state.json")
    try:
        with open(state_path) as f:
            return json.load(f).get("phase", "")
    except Exception:
        return ""

def get_feedback_file(cwd: str) -> str:
    key = hashlib.md5(cwd.encode()).hexdigest()[:8]
    base = f"/tmp/omu-{key}"
    os.makedirs(base, exist_ok=True)
    return os.path.join(base, "plannotator_feedback.txt")

def get_loop_script(cwd: str) -> str:
    candidates = [
        os.path.join(cwd, ".agent-skills", "omu", "scripts", "plannotator-plan-loop.sh"),
        os.path.expanduser("~/.codex/skills/omu/scripts/plannotator-plan-loop.sh"),
        os.path.expanduser("~/.agent-skills/omu/scripts/plannotator-plan-loop.sh"),
    ]
    for candidate in candidates:
        if os.path.exists(candidate):
            return candidate
    return ""

def write_result(cwd: str, rc: int) -> None:
    state_path = os.path.join(cwd, ".omc", "state", "omu-state.json")
    if not os.path.exists(state_path):
        return
    try:
        with open(state_path) as f:
            data = json.load(f)
    except Exception:
        return
    if rc == 0:
        data["phase"] = "execute"
        data["plan_approved"] = True
        data["plan_gate_status"] = "approved"
    elif rc == 10:
        data["phase"] = "plan"
        data["plan_approved"] = False
        data["plan_gate_status"] = "feedback_required"
    elif rc == 32:
        data["phase"] = "plan"
        data["plan_gate_status"] = "manual_approval_required"
        data["last_error"] = "plannotator UI unavailable"
    with open(state_path, "w") as f:
        json.dump(data, f, indent=2)

def main() -> int:
    try:
        notification = json.loads(sys.argv[1])
    except Exception:
        return 0
    if notification.get("type") != "agent-turn-complete":
        return 0
    message = notification.get("last-assistant-message", "")
    cwd = notification.get("cwd", os.getcwd())
    if get_phase(cwd) != "plan":
        return 0
    if not any(re.search(rf'(?m)^{re.escape(sig)}\s*$', message) for sig in PLAN_SIGNALS):
        return 0
    plan_path = os.path.join(cwd, "plan.md")
    if not os.path.exists(plan_path):
        print("[OMU] plan.md not found")
        return 0
    loop_script = get_loop_script(cwd)
    if not loop_script:
        print("[OMU] plannotator loop script not found")
        return 0
    feedback_file = get_feedback_file(cwd)
    result = subprocess.run(
        ["bash", loop_script, plan_path, feedback_file, "3"],
        cwd=cwd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    write_result(cwd, result.returncode)
    if result.stdout:
        print(result.stdout.strip())
    print(f"[OMU] plan gate result={result.returncode} feedback={feedback_file}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
HOOKEOF

  chmod +x "$HOOK_FILE"
  ok "Codex CLI files updated"
fi

echo ""
echo "Codex CLI usage after setup:"
echo "  /prompts:omu"
echo "  notify hook: ~/.codex/hooks/omu-notify.py"
echo "  backup signal: PLAN_READY"
echo ""
ok "Codex CLI setup complete"
echo ""
