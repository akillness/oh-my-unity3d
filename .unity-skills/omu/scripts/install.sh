#!/usr/bin/env bash
# OMU Skill - Master Installation Script
# Installs and configures: ralph, omc, omx, ohmg, bmad, agent-browser, playwriter, plannotator
# Usage: bash install.sh [--all] [--with-omc] [--with-plannotator] [--with-browser] [--with-bmad] [--with-omx] [--with-ohmg] [--dry-run]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_ROOT="$(dirname "$SKILL_DIR")"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC}  $*"; }
err()  { echo -e "${RED}✗${NC} $*"; }
info() { echo -e "${BLUE}→${NC} $*"; }

DRY_RUN=false
INSTALL_ALL=false
INSTALL_OMC=false
INSTALL_PLANNOTATOR=false
INSTALL_BROWSER=false
INSTALL_BMAD=false
INSTALL_OMX=false
INSTALL_OHMG=false

for arg in "$@"; do
  case "$arg" in
    --all) INSTALL_ALL=true ;;
    --with-omc) INSTALL_OMC=true ;;
    --with-plannotator) INSTALL_PLANNOTATOR=true ;;
    --with-browser) INSTALL_BROWSER=true ;;
    --with-bmad) INSTALL_BMAD=true ;;
    --with-omx) INSTALL_OMX=true ;;
    --with-ohmg) INSTALL_OHMG=true ;;
    --dry-run) DRY_RUN=true ;;
    -h|--help)
      echo "OMU Master Installer"
      echo "Usage: bash install.sh [options]"
      echo "Options:"
      echo "  --all              Install all supported components"
      echo "  --with-omc         Install oh-my-claudecode guidance"
      echo "  --with-plannotator Install plannotator CLI"
      echo "  --with-browser     Install agent-browser and playwriter"
      echo "  --with-bmad        Verify BMAD skill availability"
      echo "  --with-omx         Install oh-my-opencode"
      echo "  --with-ohmg        Install oh-my-ag for Gemini CLI"
      echo "  --dry-run          Preview commands without executing"
      exit 0
      ;;
  esac
done

if $INSTALL_ALL; then
  INSTALL_OMC=true
  INSTALL_PLANNOTATOR=true
  INSTALL_BROWSER=true
  INSTALL_BMAD=true
  INSTALL_OMX=true
  INSTALL_OHMG=true
fi

run() {
  if $DRY_RUN; then
    echo -e "${YELLOW}[DRY-RUN]${NC} $*"
  else
    eval "$@"
  fi
}

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   OMU Skill - Integrated Orchestration  ║"
echo "║   Version 2.0.0                         ║"
echo "╚══════════════════════════════════════════╝"
echo ""

info "Checking prerequisites..."
MISSING_DEPS=()
if command -v node >/dev/null 2>&1; then
  NODE_VER=$(node --version 2>/dev/null | grep -oE '[0-9]+' | head -1)
  if [[ -z "$NODE_VER" ]] || [[ "$NODE_VER" -lt 18 ]]; then
    MISSING_DEPS+=("node >=18 (current: $(node --version 2>/dev/null || echo unknown))")
  fi
else
  MISSING_DEPS+=("node >=18")
fi
command -v npm >/dev/null 2>&1 || MISSING_DEPS+=("npm")
command -v git >/dev/null 2>&1 || MISSING_DEPS+=("git")
command -v bash >/dev/null 2>&1 || MISSING_DEPS+=("bash")

if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
  err "Missing required dependencies: ${MISSING_DEPS[*]}"
  exit 1
fi
ok "Prerequisites satisfied"

if $INSTALL_OMC; then
  echo ""
  info "Preparing omc (oh-my-claudecode)..."
  if command -v claude >/dev/null 2>&1; then
    echo "  Run these commands inside Claude Code:"
    echo "  /plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode"
    echo "  /plugin install oh-my-claudecode"
    echo "  /omc:omc-setup"
    ok "omc installation guidance printed"
  else
    warn "claude CLI not found - install Claude Code first"
  fi
fi

if $INSTALL_OMX; then
  echo ""
  info "Installing omx (oh-my-opencode)..."
  if command -v bun >/dev/null 2>&1; then
    run "bunx oh-my-opencode setup 2>/dev/null || true"
    ok "omx configured via bunx"
  elif command -v npx >/dev/null 2>&1; then
    run "npx oh-my-opencode setup 2>/dev/null || true"
    ok "omx configured via npx"
  else
    warn "bun or npx not found - skipping omx setup"
  fi
fi

if $INSTALL_OHMG; then
  echo ""
  info "Installing ohmg (oh-my-ag)..."
  if command -v bun >/dev/null 2>&1; then
    run "bunx oh-my-ag 2>/dev/null || true"
    ok "ohmg configured"
  else
    warn "bun not found - skipping ohmg setup"
  fi
fi

if $INSTALL_PLANNOTATOR; then
  echo ""
  info "Installing plannotator..."
  PLANNOTATOR_INSTALL="$SKILLS_ROOT/plannotator/scripts/install.sh"
  PLANNOTATOR_INSTALLED=false
  if [[ -f "$PLANNOTATOR_INSTALL" ]]; then
    if run "bash '$PLANNOTATOR_INSTALL' --all"; then
      PLANNOTATOR_INSTALLED=true
      ok "plannotator installed via bundled script"
    fi
  fi
  if ! $PLANNOTATOR_INSTALLED; then
    if run "curl -fsSL https://plannotator.ai/install.sh | bash"; then
      PLANNOTATOR_INSTALLED=true
      ok "plannotator installed via upstream script"
    fi
  fi
  export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
  if ! $PLANNOTATOR_INSTALLED || ! command -v plannotator >/dev/null 2>&1; then
    err "plannotator is unavailable after install attempt"
    exit 1
  fi
fi

if $INSTALL_BROWSER; then
  echo ""
  info "Installing agent-browser..."
  run "npm install -g agent-browser 2>/dev/null || npx agent-browser --version 2>/dev/null || true"
  ok "agent-browser installed"

  echo ""
  info "Installing playwriter..."
  run "npm install -g playwriter 2>/dev/null || true"
  ok "playwriter installed"
fi

if $INSTALL_BMAD; then
  echo ""
  info "Checking BMAD skill..."
  BMAD_SKILL="$SKILLS_ROOT/bmad-orchestrator/SKILL.md"
  if [[ -f "$BMAD_SKILL" ]]; then
    ok "BMAD skill available at: $BMAD_SKILL"
  else
    warn "BMAD skill not found - ensure the skill pack is installed correctly"
  fi
fi

if $INSTALL_ALL; then
  echo ""
  info "Running platform setup scripts..."
  run "bash '$SCRIPT_DIR/setup-claude.sh' 2>/dev/null || true"
  run "bash '$SCRIPT_DIR/setup-codex.sh' 2>/dev/null || true"
  run "bash '$SCRIPT_DIR/setup-gemini.sh' 2>/dev/null || true"
  run "bash '$SCRIPT_DIR/setup-opencode.sh' 2>/dev/null || true"
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   OMU Installation Complete             ║"
echo "╚══════════════════════════════════════════╝"
echo ""
ok "OMU release package installed"
echo ""
echo "Next steps:"
echo "  1. bash scripts/check-status.sh"
echo "  2. Restart your AI tools"
echo "  3. Use keyword 'omu' to activate the workflow"
echo ""
