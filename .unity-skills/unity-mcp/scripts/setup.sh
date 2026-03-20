#!/usr/bin/env bash
# unity-mcp 플랫폼별 MCP 자동 설정
# 동작 원리: Unity Editor가 mcp-for-unity를 HTTP 서버로 직접 실행합니다.
#            AI 클라이언트는 subprocess를 띄우지 않고 URL로 연결합니다.
set -euo pipefail

UNITY_MCP_URL="http://localhost:8080/mcp"
UNITY_MCP_TRANSPORT="${UNITY_MCP_TRANSPORT:-http}"

stdio_json='{
  "command": "uvx",
  "args": ["--from", "mcpforunityserver", "mcp-for-unity", "--transport", "stdio"]
}'

http_json=$(cat <<EOF
{
  "url": "${UNITY_MCP_URL}"
}
EOF
)

if [[ "$UNITY_MCP_TRANSPORT" == "stdio" ]] && ! command -v uvx &>/dev/null; then
  echo "ERROR: UNITY_MCP_TRANSPORT=stdio requires uvx."
  exit 1
fi

echo "🎮 unity-mcp 설정을 시작합니다..."
echo "   연결 방식: ${UNITY_MCP_TRANSPORT}"

# Claude Code 설정
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if [ -f "$CLAUDE_SETTINGS" ]; then
  echo "✅ Claude Code 설정 업데이트: $CLAUDE_SETTINGS"
  python3 -c "
import json, sys
try:
    with open('$CLAUDE_SETTINGS', 'r') as f:
        s = json.load(f)
    s.setdefault('mcpServers', {})
    s['mcpServers']['unity'] = $stdio_json if '$UNITY_MCP_TRANSPORT' == 'stdio' else $http_json
    with open('$CLAUDE_SETTINGS', 'w') as f:
        json.dump(s, f, indent=2, ensure_ascii=False)
    print('  Claude Code: unity-mcp 추가 완료')
except Exception as e:
    print(f'  Claude Code 설정 실패: {e}', file=sys.stderr)
"
fi

# Codex CLI 설정
CODEX_CONFIG="$HOME/.codex/config.toml"
if [ -f "$CODEX_CONFIG" ]; then
  echo "✅ Codex CLI 설정 확인: $CODEX_CONFIG"
  if ! grep -q 'name = "unity"' "$CODEX_CONFIG" 2>/dev/null; then
    if [[ "$UNITY_MCP_TRANSPORT" == "stdio" ]]; then
      cat >> "$CODEX_CONFIG" << 'TOML'

[[mcp_servers]]
name = "unity"
command = "uvx"
args = ["--from", "mcpforunityserver", "mcp-for-unity", "--transport", "stdio"]
TOML
    else
      cat >> "$CODEX_CONFIG" << 'TOML'

[[mcp_servers]]
name = "unity"
url = "http://localhost:8080/mcp"
TOML
    fi
    echo "  Codex CLI: unity-mcp 추가 완료"
  else
    echo "  Codex CLI: 이미 설정됨"
  fi
fi

# Gemini CLI 설정
GEMINI_SETTINGS="$HOME/.gemini/settings.json"
if [ -f "$GEMINI_SETTINGS" ]; then
  echo "✅ Gemini CLI 설정 업데이트: $GEMINI_SETTINGS"
  python3 -c "
import json, sys
try:
    with open('$GEMINI_SETTINGS', 'r') as f:
        s = json.load(f)
    s.setdefault('mcpServers', {})
    s['mcpServers']['unity'] = $stdio_json if '$UNITY_MCP_TRANSPORT' == 'stdio' else $http_json
    with open('$GEMINI_SETTINGS', 'w') as f:
        json.dump(s, f, indent=2, ensure_ascii=False)
    print('  Gemini CLI: unity-mcp 추가 완료')
except Exception as e:
    print(f'  Gemini CLI 설정 실패: {e}', file=sys.stderr)
"
fi

echo ""
echo "🚀 설정 완료! Unity Editor에서 MCP 서버를 시작하세요:"
echo "   Unity Editor → Window → MCP → Start"
echo "   연결 확인: curl http://localhost:8080/health"
if [[ "$UNITY_MCP_TRANSPORT" == "stdio" ]]; then
  echo "   stdio 모드에서는 uvx 실행 경로가 클라이언트에서 접근 가능해야 합니다."
fi
echo ""
echo "⚠️  주의: Claude Code 재시작 후 /mcp 에서 unity 도구를 확인하세요."
