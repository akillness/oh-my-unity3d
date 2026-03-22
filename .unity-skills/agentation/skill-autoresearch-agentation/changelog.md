# skill-autoresearch changelog — agentation

## Run: 2026-03-22

**Baseline**: 2/6 (789 lines)
**Final**: 6/6 (537 lines, -32%)

---

### Mutation 1: Remove duplicate "Interactive wizard" block

**Eval fixed**: EVAL2 (No duplicate content) → 3/6

The Claude Code platform setup section contained the `npx agentation-mcp init` block twice
at lines 217-219 and again at lines 238-240. The second occurrence was removed entirely.

---

### Mutation 2: Fix section numbering

**Eval fixed**: EVAL3 (Consistent section numbering) → 4/6

Baseline sections:
- 1. Architecture
- 2. Installation
- 3. React Component Setup
- 4. MCP Server Setup (with unnumbered sub-patterns "Pattern 1-5" inside)
- 5. MCP Tools
- (no section 6)
- 7. Annotation Type
- 8. HTTP REST API
- 9. Environment Variables
- 10. Programmatic Utilities
- 11. Platform Support Matrix
- 12. jeo Integration

Fixed to sequential 1-11:
- 1. Architecture
- 2. Installation
- 3. React Component Setup
- 4. MCP Server Setup — All Platforms
- 5. MCP Tools (Agent API)
- 6. Workflow Patterns (patterns 1-5 kept as numbered subsections)
- 7. Annotation Schema
- 8. HTTP REST API
- 9. Configuration (env vars + platform matrix merged)
- 10. Programmatic Utilities
- 11. jeo Integration

---

### Mutation 3: Mark recommended setup per platform

**Eval fixed**: EVAL4 (Platform setup clarity) → 5/6

Added `**(Recommended)**` label to one option per platform:
- Claude Code → Official Skill (`npx skills add benjitaylor/agentation`)
- Codex → TOML config (`~/.codex/config.toml`)
- Gemini CLI → CLI registration (`gemini mcp add ...`)
- OpenCode → JSON config (`~/.config/opencode/opencode.json`)

Also removed the standalone "Universal (npx add-mcp)" section at lines 366-373 since
`npx add-mcp` was already covered as the primary method in Section 2.2.

---

### Mutation 4: Trim jeo section + remove inline setup script

**Eval fixed**: EVAL6 (Skill length < 600 lines) → 6/6

**Removed**: Inline `setup-agentation-mcp.sh` bash script (~70 lines, lines 379-450).
The script table in the Scripts section already references it as a file. Agents should
use the file reference rather than an inline copy.

**Condensed**: jeo integration section from ~100 lines to ~40 lines.
Removed: verbose "How it works" ASCII diagram (duplicate of jeo SKILL.md content),
"Using with jeo" step-by-step block (redundant with jeo docs), "Loop Verification Test"
subsection (operational detail, not agent instruction).
Kept: Trigger keywords table, Phase guard table, VERIFY_UI evaluation flow diagram,
install command, reference link.

**Also removed**: Duplicate frontmatter description reduced from 2 sentences to 1 concise line.

**Net result**: 789 → 537 lines (-252 lines, -32%)
