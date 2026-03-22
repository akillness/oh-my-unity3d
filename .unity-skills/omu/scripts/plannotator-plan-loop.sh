#!/usr/bin/env bash
# OMU PLAN gate for plannotator.
# Guarantees blocking review, retries dead sessions, and requires explicit stop decision.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAN_FILE="${1:-plan.md}"
FEEDBACK_FILE="${2:-}"
MAX_RESTARTS="${3:-3}"
PORT_ERROR_REGEX='Failed to start server\. Is port .* in use|EADDRINUSE|EPERM|operation not permitted|Failed to listen|Cannot GET|404 Not Found|500 Internal Server Error|SyntaxError|Unexpected token|page error|ReferenceError|TypeError.*Cannot read'

if ! command -v plannotator >/dev/null 2>&1; then
  if ! bash "$SCRIPT_DIR/ensure-plannotator.sh" --quiet; then
    echo "[OMU][PLAN] plannotator is required in PLAN phase." >&2
    exit 127
  fi
fi

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

if [[ ! -f "$PLAN_FILE" ]]; then
  echo "[OMU][PLAN] plan file not found: $PLAN_FILE" >&2
  exit 2
fi

if ! [[ "$MAX_RESTARTS" =~ ^[0-9]+$ ]] || [[ "$MAX_RESTARTS" -lt 1 ]]; then
  echo "[OMU][PLAN] invalid MAX_RESTARTS: $MAX_RESTARTS" >&2
  exit 2
fi

SESSION_KEY="$(python3 -c "import hashlib,os; print(hashlib.md5(os.getcwd().encode()).hexdigest()[:8])" 2>/dev/null || echo "default")"
FEEDBACK_DIR="/tmp/omu-${SESSION_KEY}"
RUNTIME_HOME="${FEEDBACK_DIR}/.plannotator"
mkdir -p "$FEEDBACK_DIR" "$RUNTIME_HOME"

if [[ -z "$FEEDBACK_FILE" ]]; then
  FEEDBACK_FILE="${FEEDBACK_DIR}/plannotator_feedback.txt"
else
  mkdir -p "$(dirname "$FEEDBACK_FILE")"
fi

write_state_gate_status() {
  local status="$1"
  OMU_GATE_STATUS="$status" python3 -c "
import json, os, subprocess, datetime
try:
    root = subprocess.check_output(['git','rev-parse','--show-toplevel'], stderr=subprocess.DEVNULL).decode().strip()
except Exception:
    root = os.getcwd()
f = os.path.join(root, '.omc/state/omu-state.json')
if os.path.exists(f):
    try:
        import fcntl
        with open(f, 'r+') as fh:
            fcntl.flock(fh, fcntl.LOCK_EX)
            try:
                d = json.load(fh)
                d['plan_gate_status'] = os.environ['OMU_GATE_STATUS']
                d['updated_at'] = datetime.datetime.utcnow().isoformat() + 'Z'
                fh.seek(0); json.dump(d, fh, indent=2); fh.truncate()
            finally:
                fcntl.flock(fh, fcntl.LOCK_UN)
    except Exception:
        pass
" 2>/dev/null || true
}

probe_local_listen() {
  if command -v node >/dev/null 2>&1; then
    node -e "const http=require('http');const s=http.createServer(()=>{});s.on('error',()=>process.exit(1));s.listen({host:'127.0.0.1',port:0},()=>s.close(()=>process.exit(0)));" >/dev/null 2>&1
    return $?
  fi
  return 0
}

# Non-interactive environment (Codex sandbox, CI, piped stdin): plannotator is required.
# TUI fallback is disabled — plannotator must be available.
if [[ ! -t 0 || ! -t 1 ]]; then
  echo "[OMU][PLAN] plannotator UI가 필요합니다. 비대화형 환경에서는 plannotator 없이 PLAN을 승인할 수 없습니다." >&2
  echo "[OMU][PLAN] plannotator를 설치하려면: bash scripts/ensure-plannotator.sh" >&2
  write_state_gate_status "plannotator_required"
  exit 32
fi

# Some sandboxes disallow localhost bind(). In that environment plannotator hook mode cannot run.
if [[ "${OMU_SKIP_LISTEN_PROBE:-0}" != "1" ]]; then
  if ! probe_local_listen; then
    echo "[OMU][PLAN] localhost bind 실패 — plannotator를 실행할 수 없습니다." >&2
    echo "[OMU][PLAN] plannotator는 PLAN 단계에서 필수입니다. TUI 폴백은 비활성화되어 있습니다." >&2
    write_state_gate_status "infrastructure_blocked"
    exit 32
  fi
fi

STDERR_FILE="${FEEDBACK_DIR}/plannotator_stderr.txt"
# Ensure lock is always cleaned up on script exit
trap 'rm -f /tmp/omu-plannotator-direct.lock' EXIT INT TERM

attempt=1
while (( attempt <= MAX_RESTARTS )); do
  : > "$FEEDBACK_FILE"
  : > "$STDERR_FILE"
  # Create lock BEFORE starting plannotator to prevent ExitPlanMode hook double-launch
  touch /tmp/omu-plannotator-direct.lock

  python3 -c "
import json, sys
plan = open(sys.argv[1]).read()
sys.stdout.write(json.dumps({'tool_input': {'plan': plan, 'permission_mode': 'acceptEdits'}}))
" "$PLAN_FILE" | env HOME="$RUNTIME_HOME" PLANNOTATOR_HOME="$RUNTIME_HOME" plannotator > "$FEEDBACK_FILE" 2>"$STDERR_FILE" || true

  # Release lock immediately after plannotator exits
  rm -f /tmp/omu-plannotator-direct.lock

  # Merge stderr into feedback for error detection (keep JSON intact at start of FEEDBACK_FILE)
  if [[ -s "$STDERR_FILE" ]]; then
    echo "" >> "$FEEDBACK_FILE"
    cat "$STDERR_FILE" >> "$FEEDBACK_FILE"
  fi

  set +e
  python3 - "$FEEDBACK_FILE" <<'PYEOF'
import json, sys
path = sys.argv[1]
payload = None
# Read only the first valid JSON object (ignore appended stderr lines)
try:
    with open(path) as fh:
        content = fh.read()
    # Try full file first, then first non-empty line
    for chunk in [content, content.split('\n')[0]]:
        try:
            payload = json.loads(chunk.strip())
            break
        except Exception:
            pass
except Exception:
    pass
if payload is None:
    sys.exit(20)
approved = payload.get("approved")
if approved is True:
    sys.exit(0)
if approved is False:
    sys.exit(10)
sys.exit(20)
PYEOF
  rc=$?
  set -e

  if [[ "$rc" -eq 0 ]]; then
    echo "[OMU][PLAN] approved=true"
    # Persist approval to omu-state.json so agent skips re-calling on next turn
    python3 - <<'PYEOF'
import json, os, datetime
state_path = os.path.join(os.getcwd(), '.omc/state/omu-state.json')
if os.path.exists(state_path):
    try:
        s = json.load(open(state_path))
        s['plan_approved'] = True
        s['phase'] = 'execute'
        s['plan_gate_status'] = 'approved'
        s['ralphmode_requested'] = True
        s['updated_at'] = datetime.datetime.utcnow().isoformat() + 'Z'
        with open(state_path, 'w') as f:
            json.dump(s, f, indent=2)
    except Exception:
        pass
PYEOF
    echo "[OMU][PLAN] ralphmode: permission profile activation requested — invoke /ralphmode before executing"
    exit 0
  fi

  if [[ "$rc" -eq 10 ]]; then
    echo "[OMU][PLAN] approved=false (feedback)"
    # Persist feedback to omu-state.json so agent reads it on next turn
    python3 - "$FEEDBACK_FILE" <<'PYEOF'
import json, os, sys, datetime
state_path = os.path.join(os.getcwd(), '.omc/state/omu-state.json')
feedback_path = sys.argv[1] if len(sys.argv) > 1 else ''
if os.path.exists(state_path):
    try:
        s = json.load(open(state_path))
        fb = {}
        if feedback_path and os.path.exists(feedback_path):
            try:
                fb = json.load(open(feedback_path))
            except Exception:
                pass
        s['plan_approved'] = False
        s['plannotator_feedback'] = fb
        s['plan_gate_status'] = 'feedback_required'
        s['updated_at'] = datetime.datetime.utcnow().isoformat() + 'Z'
        with open(state_path, 'w') as f:
            json.dump(s, f, indent=2)
    except Exception:
        pass
PYEOF
    exit 10
  fi

  if grep -Eiq "$PORT_ERROR_REGEX" "$FEEDBACK_FILE"; then
    echo "[OMU][PLAN] plannotator 서버 바인딩 실패 (EADDRINUSE/EPERM)." >&2
    echo "[OMU][PLAN] 포트 충돌 해결 후 재시도하세요: pkill plannotator; sleep 1" >&2
    write_state_gate_status "infrastructure_blocked"
    exit 32
  fi

  echo "[OMU][PLAN] session ended unexpectedly (attempt ${attempt}/${MAX_RESTARTS}). restarting..." >&2
  ((attempt++))
done

echo "[OMU][PLAN] plannotator 세션이 ${MAX_RESTARTS}회 종료되었습니다." >&2
echo "[OMU][PLAN] plannotator가 정상 동작하지 않습니다. TUI 폴백은 비활성화되어 있습니다." >&2
echo "[OMU][PLAN] 재설치: bash scripts/ensure-plannotator.sh" >&2
write_state_gate_status "infrastructure_blocked"
exit 32
