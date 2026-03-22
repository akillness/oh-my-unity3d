---
name: agentation
description: Visual UI annotation tool — humans click elements, agents receive CSS selectors and React component paths to fix exact code.
compatibility: React 18+, Node.js 18+
allowed-tools: Read Write Bash Grep Glob
metadata:
  tags: ui-feedback, browser-annotation, visual-feedback, mcp, react, ai-agent, design-review, css-selector
  platforms: Claude Code, Codex, Gemini CLI, OpenCode, Cursor, Windsurf, ChatGPT
  keyword: agentation
  version: 1.1.0
  source: benjitaylor/agentation
---


# agentation — Visual UI Feedback Bridge for AI Agents

> **The missing link between human eyes and agent code.**
>
> Instead of describing "the blue button in the sidebar," you hand the agent `.sidebar > button.primary`. It can `grep` for that directly.

---

## When to use this skill

- Human needs to point at a UI element and give feedback — without writing selectors
- Running iterative UI/UX review cycles between human and coding agent
- Building a watch-loop where agent auto-fixes every annotation a human leaves
- Capturing CSS selectors, bounding boxes, and React component trees for precise code targeting
- Autonomous design critique via `agent-browser` + self-driving pattern
- Integrating visual feedback into agent hooks so annotations auto-appear in agent context

---

## 1. Architecture

```
agentation (monorepo)
├── agentation          → npm: agentation (React toolbar component)
│   └── src/index.ts   → exports Agentation component + types + utilities
└── agentation-mcp      → npm: agentation-mcp (MCP server + CLI)
    ├── src/cli.ts      → agentation-mcp CLI (init, server, doctor)
    └── src/server/     → HTTP REST API (port 4747) + SSE events + MCP stdio tools
```

**Two modes of operation:**

| Mode | How it works |
|------|-------------|
| **Copy-Paste** | Human annotates → clicks Copy → pastes markdown into agent chat |
| **Agent Sync** | `endpoint` prop connects toolbar to MCP server → agent uses `agentation_watch_annotations` loop |

---

## 2. Installation

### 2.1 React Component (toolbar)

```bash
npm install agentation -D
# or: pnpm add agentation -D  /  yarn add agentation -D  /  bun add agentation -D
```

**Requirements**: React 18+, desktop browser, zero runtime deps beyond React (desktop only — no mobile)

> **Local-first by design**: Annotations are stored locally and auto-sync when connected to the MCP server.
> - **Offline operation** — Annotations can be created without a server
> - **Session continuity** — Same session persists after page refresh, no duplicates
> - **Agent-first** — resolve/dismiss is handled by the agent

### 2.2 MCP Server — Universal Setup (Recommended)

> **Fastest method** — Auto-detects all installed agents and configures them (Claude Code, Cursor, Codex, Windsurf, and 9+ more agents):

```bash
npx add-mcp "npx -y agentation-mcp server"
```

Or install manually:

```bash
npm install agentation-mcp -D
npx agentation-mcp server          # HTTP :4747 + MCP stdio
npx agentation-mcp server --port 8080   # custom port
npx agentation-mcp doctor          # verify setup
```

### 2.3 Claude Code — Official Skill (Minimal Setup)

> Recommended for Claude Code users — automatically handles framework detection, package installation, and layout integration:

```bash
npx skills add benjitaylor/agentation
# then in Claude Code:
/agentation
```

---

## 3. React Component Setup

### Basic (Copy-Paste mode — no server needed)

```tsx
import { Agentation } from 'agentation';

function App() {
  return (
    <>
      <YourApp />
      {process.env.NODE_ENV === 'development' && <Agentation />}
    </>
  );
}
```

### Next.js App Router

```tsx
// app/layout.tsx
import { Agentation } from 'agentation';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        {children}
        {process.env.NODE_ENV === 'development' && (
          <Agentation endpoint="http://localhost:4747" />
        )}
      </body>
    </html>
  );
}
```

### Next.js Pages Router

```tsx
// pages/_app.tsx
import { Agentation } from 'agentation';

export default function App({ Component, pageProps }) {
  return (
    <>
      <Component {...pageProps} />
      {process.env.NODE_ENV === 'development' && (
        <Agentation endpoint="http://localhost:4747" />
      )}
    </>
  );
}
```

### Full Props Reference

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `endpoint` | `string` | — | MCP server URL for Agent Sync mode |
| `sessionId` | `string` | — | Pre-existing session ID to join |
| `onAnnotationAdd` | `(a: Annotation) => void` | — | Callback when annotation created |
| `onAnnotationDelete` | `(a: Annotation) => void` | — | Callback when annotation deleted |
| `onAnnotationUpdate` | `(a: Annotation) => void` | — | Callback when annotation edited |
| `onAnnotationsClear` | `(a: Annotation[]) => void` | — | Callback when all cleared |
| `onCopy` | `(markdown: string) => void` | — | Callback with markdown on copy |
| `onSubmit` | `(output: string, annotations: Annotation[]) => void` | — | On "Send Annotations" click |
| `copyToClipboard` | `boolean` | `true` | Set false to suppress clipboard write |
| `onSessionCreated` | `(sessionId: string) => void` | — | Called on new session creation |
| `webhookUrl` | `string` | — | Webhook URL to receive annotation events |

---

## 4. MCP Server Setup — All Platforms

### Claude Code (`.claude/`)

**(Recommended)** Official Claude Code Skill — minimal setup, auto-detects framework:
```bash
npx skills add benjitaylor/agentation
# In Claude Code:
/agentation
```

Alternative — CLI registration:
```bash
claude mcp add agentation -- npx -y agentation-mcp server
```

Alternative — config file (`.claude/mcp.json` for project-level, `~/.claude/claude_desktop_config.json` for global):
```json
{
  "mcpServers": {
    "agentation": {
      "command": "npx",
      "args": ["-y", "agentation-mcp", "server"]
    }
  }
}
```

**UserPromptSubmit hook** — auto-inject pending annotations on every message.
Add to `.claude/settings.json` (project) or `~/.claude/settings.json` (global):
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "type": "command",
        "command": "curl -sf --connect-timeout 1 http://localhost:4747/pending 2>/dev/null | python3 -c \"import sys,json;d=json.load(sys.stdin);c=d['count'];exit(0)if c==0 else[print(f'\\n=== AGENTATION: {c} UI annotations ===\\n'),*[print(f\\\"[{i+1}] {a['element']} ({a['elementPath']})\\n    {a['comment']}\\n\\\")for i,a in enumerate(d['annotations'])],print('=== END ===\\n')]\" 2>/dev/null;exit 0"
      }
    ]
  }
}
```

---

### Codex CLI (`~/.codex/`)

**(Recommended)** Add to `~/.codex/config.toml`:

```toml
# Agentation MCP Server
[[mcp_servers]]
name = "agentation"
command = "npx"
args = ["-y", "agentation-mcp", "server"]

# Optional: teach Codex about watch-loop
developer_instructions = """
When user says "watch mode" or "agentation watch", call agentation_watch_annotations in a loop.
For each annotation: acknowledge it, fix the code using the elementPath CSS selector, resolve with summary.
"""
```

Restart Codex CLI after editing `config.toml`.

---

### Gemini CLI (`~/.gemini/`)

**(Recommended)** CLI registration:
```bash
gemini mcp add agentation npx -y agentation-mcp server
# or with explicit scope
gemini mcp add -s user agentation npx -y agentation-mcp server
```

Alternative — config file (`~/.gemini/settings.json` for global, `.gemini/settings.json` for project):
```json
{
  "mcpServers": {
    "agentation": {
      "command": "npx",
      "args": ["-y", "agentation-mcp", "server"]
    }
  }
}
```

**AfterAgent hook** — trigger annotation check after each agent turn:
```json
{
  "mcpServers": {
    "agentation": {
      "command": "npx",
      "args": ["-y", "agentation-mcp", "server"]
    }
  },
  "hooks": {
    "AfterAgent": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "curl -sf --connect-timeout 1 http://localhost:4747/pending 2>/dev/null | python3 -c \"import sys,json;d=json.load(sys.stdin);c=d.get('count',0);[print(f'[agentation] {c} pending annotations'),exit(1)]if c>0 else exit(0)\" 2>/dev/null;exit 0",
            "description": "Check for pending agentation annotations"
          }
        ]
      }
    ]
  }
}
```

---

### OpenCode (`~/.config/opencode/`)

**(Recommended)** Add to `~/.config/opencode/opencode.json`:

```json
{
  "mcp": {
    "agentation": {
      "type": "local",
      "command": ["npx", "-y", "agentation-mcp", "server"],
      "environment": {
        "AGENTATION_STORE": "sqlite",
        "AGENTATION_EVENT_RETENTION_DAYS": "7"
      }
    }
  }
}
```

Restart OpenCode after editing. MCP tools (`agentation_*`) will be available immediately.

---

### Scripts (Automated Setup)

Prefer the bundled scripts before copying config blocks by hand:

| Script | Pattern | Usage |
|--------|---------|-------|
| `scripts/setup-agentation-mcp.sh` | MCP registration | Register `agentation-mcp` for Claude Code, Codex, Gemini CLI, and OpenCode |
| `scripts/verify-loop.sh` | Watch-loop verification | Validate health, annotation CRUD, and ACK → RESOLVE flow before starting watch mode |

---

## 5. MCP Tools (Agent API)

| Tool | Parameters | Description |
|------|-----------|-------------|
| `agentation_list_sessions` | none | List all active annotation sessions |
| `agentation_get_session` | `sessionId: string` | Get session with all annotations |
| `agentation_get_pending` | `sessionId: string` | Get pending annotations for a session |
| `agentation_get_all_pending` | none | Get pending annotations across ALL sessions |
| `agentation_acknowledge` | `annotationId: string` | Mark annotation as acknowledged (agent is working on it) |
| `agentation_resolve` | `annotationId: string, summary?: string` | Mark as resolved with optional summary |
| `agentation_dismiss` | `annotationId: string, reason: string` | Dismiss with required reason |
| `agentation_reply` | `annotationId: string, message: string` | Add reply to annotation thread |
| `agentation_watch_annotations` | `sessionId?: string, batchWindowSeconds?: number (default 10, max 60), timeoutSeconds?: number (default 120, max 300)` | **Block until new annotations arrive** — core watch-loop tool |

---

## 6. Workflow Patterns

### Pattern 1: Copy-Paste (Simplest, No Server)

```
1. Human opens app in browser
2. Clicks agentation toolbar → activates
3. Clicks element → adds comment → clicks Copy
4. Pastes markdown output into agent chat
5. Agent receives CSS selectors, elementPath, boundingBox
6. Agent greps/edits code using selector
```

### Pattern 2: MCP Watch Loop (Recommended for iterative review)

```
Agent: agentation_watch_annotations (blocks up to 120s)
  → Human adds annotation in browser
  → Agent receives batch immediately
  → Agent: agentation_acknowledge(annotationId)
  → Agent makes code changes using elementPath as grep target
  → Agent: agentation_resolve(annotationId, "Changed button color to #3b82f6")
  → Agent: agentation_watch_annotations (loops again)
```

**CLAUDE.md / GEMINI.md / Codex developer_instructions — add for automated watch:**

```markdown
When I say "watch mode" or "agentation watch", call agentation_watch_annotations in a loop.
For each annotation received:
  1. Call agentation_acknowledge(annotationId)
  2. Use elementPath to locate the code: Grep(elementPath) or search codebase for CSS class
  3. Make the minimal change described in the comment
  4. Call agentation_resolve(annotationId, "<brief summary of what was changed>")
Continue watching until I say stop, or until timeout.
```

### Pattern 3: Platform-Specific Hook (Passive Injection)

The hook from Section 4 auto-appends pending annotations to every agent message — no "watch mode" needed. Works across all platforms.

### Pattern 4: Autonomous Self-Driving Critique

Two-agent setup for fully autonomous UI review cycles:

**Session 1 (Critic — uses `agent-browser`):**
```bash
# Start headed browser pointing at your dev server
agent-browser open http://localhost:3000
agent-browser snapshot -i
# Agent navigates, clicks elements via agentation toolbar, adds critique
# Annotations flow to agentation MCP server automatically
```

**Session 2 (Fixer — watches MCP):**
```
agentation_watch_annotations → receives critique → acknowledge → edit → resolve → loop
```

### Pattern 5: Webhook Integration

```tsx
<Agentation webhookUrl="https://your-server.com/webhook" />
# or env var:
# AGENTATION_WEBHOOK_URL=https://your-server.com/webhook
```

---

## 7. Annotation Schema

```typescript
type Annotation = {
  // Core
  id: string;
  x: number;            // % of viewport width (0-100)
  y: number;            // px from document top
  comment: string;      // User's feedback text
  element: string;      // Tag name: "button", "div", etc.
  elementPath: string;  // CSS selector: "body > main > button.cta"  ← grep target
  timestamp: number;

  // Context
  selectedText?: string;
  boundingBox?: { x: number; y: number; width: number; height: number };
  nearbyText?: string;
  cssClasses?: string;
  nearbyElements?: string;
  computedStyles?: string;
  fullPath?: string;
  accessibility?: string;
  reactComponents?: string;  // "App > Dashboard > Button"  ← component grep target
  isMultiSelect?: boolean;
  isFixed?: boolean;

  // Lifecycle (server-synced)
  sessionId?: string;
  url?: string;
  intent?: "fix" | "change" | "question" | "approve";
  severity?: "blocking" | "important" | "suggestion";
  status?: "pending" | "acknowledged" | "resolved" | "dismissed";
  thread?: ThreadMessage[];
  createdAt?: string;
  updatedAt?: string;
  resolvedAt?: string;
  resolvedBy?: "human" | "agent";
};
```

**Annotation lifecycle:**
```
pending → acknowledged → resolved
                      ↘ dismissed (requires reason)
```

---

## 8. HTTP REST API (port 4747)

```bash
# Sessions
POST   /sessions                     # Create session
GET    /sessions                     # List all sessions
GET    /sessions/:id                 # Get session + annotations

# Annotations
POST   /sessions/:id/annotations     # Add annotation
GET    /annotations/:id              # Get annotation
PATCH  /annotations/:id              # Update annotation
DELETE /annotations/:id              # Delete annotation
GET    /sessions/:id/pending         # Pending for session
GET    /pending                      # ALL pending across sessions

# Events (SSE streaming)
GET    /sessions/:id/events          # Session stream
GET    /events                       # Global stream (?domain=filter)

# Health
GET    /health
GET    /status
```

---

## 9. Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `AGENTATION_STORE` | `memory` or `sqlite` | `sqlite` |
| `AGENTATION_WEBHOOK_URL` | Single webhook URL | — |
| `AGENTATION_WEBHOOKS` | Comma-separated webhook URLs | — |
| `AGENTATION_EVENT_RETENTION_DAYS` | Days to keep events | `7` |

SQLite storage: `~/.agentation/store.db`

### Platform Config Files

| Platform | Config File | MCP Key | Hook |
|----------|------------|---------|------|
| **Claude Code** | `.claude/mcp.json` (project) / `~/.claude/claude_desktop_config.json` (global) | `mcpServers` | `hooks.UserPromptSubmit` in `settings.json` |
| **Codex CLI** | `~/.codex/config.toml` | `[[mcp_servers]]` (TOML) | `developer_instructions` + `notify` |
| **Gemini CLI** | `~/.gemini/settings.json` | `mcpServers` | `hooks.AfterAgent` in `settings.json` |
| **OpenCode** | `~/.config/opencode/opencode.json` | `mcp` (`type: "local"`) | Skills system (no hook needed) |
| **Cursor / Windsurf** | `.cursor/mcp.json` / `.windsurf/mcp.json` | `mcpServers` | — |

---

## 10. Programmatic Utilities

```typescript
import {
  identifyElement, identifyAnimationElement,
  getElementPath, getNearbyText, getElementClasses,
  isInShadowDOM, getShadowHost, closestCrossingShadow,
  loadAnnotations, saveAnnotations, getStorageKey,
  type Annotation, type Session, type ThreadMessage,
} from 'agentation';
```

---

## 11. jeo Integration (annotate keyword)

> agentation integrates as the **VERIFY_UI** phase of the jeo skill. `annotate` is the primary keyword; `agentui` is a backward-compatible alias.

### Trigger Keywords

| Keyword | Platform | Action |
|--------|----------|------|
| `annotate` | Claude Code | `agentation_watch_annotations` MCP blocking call |
| `annotate` | Codex | `ANNOTATE_READY` signal → `jeo-notify.py` HTTP polling |
| `annotate` | Gemini | GEMINI.md instruction: HTTP REST polling pattern |
| `/jeo-annotate` | OpenCode | opencode.json `mcp.agentation` + instructions |
| `agentui` *(deprecated)* | All platforms | Same behavior — backward-compatible alias |
| `UI review` | All platforms | Same as `annotate` |

### Phase Guard

plannotator and agentation use the same blocking loop pattern but only operate in different phases:

| Tool | Allowed phase | Guard |
|------|-----------|------------|
| **plannotator** | `plan` only | `jeo-state.json` → `phase === "plan"` |
| **agentation** | `verify_ui` only | `jeo-state.json` → `phase === "verify_ui"` |

### jeo VERIFY_UI Evaluation Flow

```
jeo "<task>"
    │
[1] PLAN (plannotator loop)    ← approve plan.md
[2] EXECUTE (team/bmad)
[3] VERIFY
    ├─ agent-browser snapshot
    ├─ Pre-flight: GET /health → GET /sessions → GET /pending
    └─ annotate → VERIFY_UI (agentation loop)
        ├─ ACK → FIND → FIX → RESOLVE
        ├─ RE-SNAPSHOT (agent-browser)
        └─ update agentation fields in jeo-state.json
[4] CLEANUP
```

Install with jeo:
```bash
bash .agent-skills/jeo/scripts/install.sh --with-agentation
```

> For detailed jeo integration: see [jeo SKILL.md](../jeo/SKILL.md) Section 3.3.1

---

## Best Practices

1. Always gate `<Agentation>` with `NODE_ENV === 'development'` — never ship to production
2. Use MCP watch-loop over copy-paste for iterative cycles — eliminates context switching
3. Call `agentation_acknowledge` immediately when starting a fix — signals human
4. Include a `summary` in `agentation_resolve` — gives human traceability
5. Process `severity: "blocking"` annotations first in the watch loop
6. Use `elementPath` as the primary grep/search target in code — it's a valid CSS selector
7. Use `reactComponents` field when the codebase is React — matches component names directly
8. Add the appropriate hook for your platform (Section 4) for zero-friction passive injection
9. For autonomous self-driving, use `agent-browser` in headed mode with `agentation` mounted

---

## References

- [agentation repo](https://github.com/benjitaylor/agentation)
- [agentation npm](https://www.npmjs.com/package/agentation)
- [agentation-mcp npm](https://www.npmjs.com/package/agentation-mcp)
- [Gemini CLI MCP docs](https://github.com/google-gemini/gemini-cli/blob/main/docs/tools/mcp-server.md)
- [agent-browser skill](../agent-browser/SKILL.md)

## Metadata

- Version: 1.1.0
- Source: benjitaylor/agentation (PolyForm Shield 1.0.0)
- Packages: `agentation@2.2.1`, `agentation-mcp@1.2.0`
- Last updated: 2026-03-22
- Scope: UI annotation bridge for human-agent feedback loops — Claude Code, Codex, Gemini CLI, OpenCode
