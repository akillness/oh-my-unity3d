#!/usr/bin/env bash
# JEO Skill - Status Check
# Verifies the release-supported JEO components and flags legacy agentation leftovers
# Usage: bash check-status.sh [--resume]

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'
ok()   { echo -e "  ${GREEN}✓${NC} $*"; }
warn() { echo -e "  ${YELLOW}⚠${NC}  $*"; }
err()  { echo -e "  ${RED}✗${NC} $*"; }
info() { echo -e "${BLUE}${BOLD}$*${NC}"; }

RESUME=false
[[ "${1:-}" == "--resume" ]] && RESUME=true

PASS=0
WARN=0
FAIL=0

check() {
  local label="$1"; local cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    ok "$label"; ((PASS++)) || true
  else
    err "$label (not found)"; ((FAIL++)) || true
  fi
}

check_opt() {
  local label="$1"; local cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    ok "$label"; ((PASS++)) || true
  else
    warn "$label (optional - not configured)"; ((WARN++)) || true
  fi
}

legacy_warn() {
  warn "$1"; ((WARN++)) || true
}

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   JEO Skill - Status Check              ║"
echo "╚══════════════════════════════════════════╝"
echo ""

info "Prerequisites"
check "node >=18" "node --version | grep -E 'v(1[89]|[2-9][0-9])'"
check "npm" "command -v npm"
check "git" "command -v git"
check_opt "bun" "command -v bun"
check_opt "python3" "command -v python3"
echo ""

info "Core Tools"
check_opt "plannotator CLI" "command -v plannotator"
check_opt "agent-browser" "command -v agent-browser || npx agent-browser --version"
check_opt "playwriter" "command -v playwriter"
echo ""

info "AI Tool Integrations"

if [[ -f "${HOME}/.claude/settings.json" ]]; then
  if grep -q "plannotator" "${HOME}/.claude/settings.json" 2>/dev/null; then
    ok "Claude Code - plannotator hook configured"; ((PASS++)) || true
  else
    warn "Claude Code - plannotator hook missing"; ((WARN++)) || true
  fi
  if grep -q "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" "${HOME}/.claude/settings.json" 2>/dev/null; then
    ok "Claude Code - team mode configured"; ((PASS++)) || true
  else
    err "Claude Code - team mode not configured"; ((FAIL++)) || true
  fi
  if grep -q '"agentation"' "${HOME}/.claude/settings.json" 2>/dev/null || grep -q "localhost:4747" "${HOME}/.claude/settings.json" 2>/dev/null; then
    legacy_warn "Claude Code - legacy agentation config still present"
  fi
else
  warn "Claude Code - ~/.claude/settings.json not found"; ((WARN++)) || true
fi

if [[ -f "${HOME}/.codex/config.toml" ]]; then
  if grep -q "Keyword: jeo | Platforms: Codex, Claude, Gemini, OpenCode" "${HOME}/.codex/config.toml" 2>/dev/null; then
    ok "Codex CLI - JEO developer instructions configured"; ((PASS++)) || true
  else
    warn "Codex CLI - JEO developer instructions missing"; ((WARN++)) || true
  fi
  if [[ -f "${HOME}/.codex/prompts/jeo.md" ]]; then
    ok "Codex CLI - /prompts:jeo available"; ((PASS++)) || true
  else
    warn "Codex CLI - /prompts:jeo missing"; ((WARN++)) || true
  fi
  if grep -q "jeo-notify.py" "${HOME}/.codex/config.toml" 2>/dev/null; then
    ok "Codex CLI - notify hook configured"; ((PASS++)) || true
  else
    warn "Codex CLI - notify hook missing"; ((WARN++)) || true
  fi
  if grep -q "agentation" "${HOME}/.codex/config.toml" 2>/dev/null; then
    legacy_warn "Codex CLI - legacy agentation config still present"
  fi
else
  warn "Codex CLI - ~/.codex/config.toml not found"; ((WARN++)) || true
fi

if [[ -f "${HOME}/.gemini/settings.json" ]]; then
  if grep -q "jeo-plannotator" "${HOME}/.gemini/settings.json" 2>/dev/null || grep -q "plannotator" "${HOME}/.gemini/settings.json" 2>/dev/null; then
    ok "Gemini CLI - plannotator hook configured"; ((PASS++)) || true
  else
    warn "Gemini CLI - plannotator hook missing"; ((WARN++)) || true
  fi
  if grep -q "agentation" "${HOME}/.gemini/settings.json" 2>/dev/null; then
    legacy_warn "Gemini CLI - legacy agentation config still present"
  fi
else
  warn "Gemini CLI - ~/.gemini/settings.json not found"; ((WARN++)) || true
fi

if [[ -f "${HOME}/.gemini/GEMINI.md" ]]; then
  if grep -q "## JEO Orchestration Workflow" "${HOME}/.gemini/GEMINI.md" 2>/dev/null; then
    ok "Gemini CLI - JEO section present"; ((PASS++)) || true
  else
    warn "Gemini CLI - JEO section missing"; ((WARN++)) || true
  fi
fi

for candidate in "./opencode.json" "${HOME}/opencode.json" "${HOME}/.config/opencode/opencode.json"; do
  if [[ -f "$candidate" ]]; then
    if grep -q "plannotator" "$candidate" 2>/dev/null; then
      ok "OpenCode - plannotator plugin configured ($candidate)"; ((PASS++)) || true
    else
      warn "OpenCode - plannotator plugin missing ($candidate)"; ((WARN++)) || true
    fi
    if grep -q "agentation" "$candidate" 2>/dev/null; then
      legacy_warn "OpenCode - legacy agentation config still present ($candidate)"
    fi
    break
  fi
done
echo ""

info "JEO State"
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
STATE_FILE="$GIT_ROOT/.omc/state/jeo-state.json"
if [[ -f "$STATE_FILE" ]]; then
  ok "State file found: $STATE_FILE"
  if command -v python3 >/dev/null 2>&1; then
    python3 - <<PYEOF
import json
state = json.load(open("$STATE_FILE"))
print(f"     Current phase: {state.get('phase', 'unknown')}")
print(f"     Task: {state.get('task', '(none)')}")
retry = state.get('retry_count', 0)
if retry:
    print(f"     Retry count: {retry}")
last_error = state.get('last_error')
if last_error:
    print(f"     Last error: {last_error}")
PYEOF
  fi
else
  warn "No active JEO state"
  if $RESUME; then
    mkdir -p "$GIT_ROOT/.omc/state" "$GIT_ROOT/.omc/plans"
    python3 - <<PYEOF
import datetime
import json
import os
state = {
    "mode": "jeo",
    "phase": "plan",
    "task": "resumed session",
    "plan_approved": False,
    "plan_gate_status": "pending",
    "team_available": False,
    "retry_count": 0,
    "last_error": None,
    "checkpoint": None,
    "created_at": datetime.datetime.utcnow().isoformat() + "Z",
    "updated_at": datetime.datetime.utcnow().isoformat() + "Z",
}
path = os.path.join("$GIT_ROOT", ".omc", "state", "jeo-state.json")
with open(path, "w") as f:
    json.dump(state, f, indent=2)
print(f"✓ Fresh JEO state initialized at {path}")
PYEOF
  fi
fi

WORKTREE_COUNT=$(git worktree list 2>/dev/null | wc -l | tr -d ' ') || WORKTREE_COUNT=0
if [[ "$WORKTREE_COUNT" -gt 1 ]]; then
  warn "Active worktrees: $WORKTREE_COUNT"
else
  ok "No extra worktrees active"
fi
echo ""

echo "══════════════════════════════════════════"
echo -e "  ${GREEN}✓${NC} Passed: $PASS  ${YELLOW}⚠${NC}  Warnings: $WARN  ${RED}✗${NC} Failed: $FAIL"
echo "══════════════════════════════════════════"
echo ""

if [[ $FAIL -gt 0 ]]; then
  echo "Fix failures by running: bash scripts/install.sh --all"
elif [[ $WARN -gt 0 ]]; then
  echo "Warnings remain. Re-run the relevant platform setup scripts."
else
  echo -e "${GREEN}All checks passed. JEO is aligned with the v2.0.0 release contract.${NC}"
fi
echo ""
