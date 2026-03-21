# OMU Skill Autoresearch Changelog

## Baseline (Experiment 0)

**Score: 1/6 (0.17)**

| Eval | Result |
|------|--------|
| PLAN-GATE-EXIT-CODE | FAIL - Exit codes 0 and 10 not explicitly named; handling implicit |
| PLATFORM-FORK | PASS - Distinct Claude Code vs Codex/Gemini/OpenCode sections |
| STATE-PERSIST | FAIL - Missing execute-to-verify and verify-to-cleanup state snippets |
| RECOVERY | FAIL - Generic resume guidance without per-phase actions |
| UNITY-DETECT | FAIL - No concrete command for unity-mcp detection |
| CLEANUP-GUARD | FAIL - "warn before cleanup" without specific command |

---

## Experiment 1: PLAN-GATE-EXIT-CODE fix (KEEP)

**Score: 1 -> 2/6 (+1)**

**Change**: Replaced the implicit plannotator rules with explicit exit code table:
- exit 0: approved=true, proceed to EXECUTE
- exit 10: approved=false (feedback), update plan and re-run
- exit 32: non-interactive, print plan contents and wait for user reply

**Section**: PLAN > Required plan gate > Rules

---

## Experiment 2: STATE-PERSIST fix (KEEP)

**Score: 2 -> 3/6 (+1)**

**Change**: Added two state update JSON snippets:
- After EXECUTE section: `{ "phase": "verify", "checkpoint": "execute-complete" }`
- After VERIFY section: `{ "phase": "cleanup", "checkpoint": "verify-complete" }`

Now all four phase transitions (plan-to-execute, execute-to-verify, verify-to-cleanup, cleanup-to-done) have explicit state snippets.

**Sections**: EXECUTE (end), VERIFY (after verification rule)

---

## Experiment 3: RECOVERY fix (KEEP)

**Score: 3 -> 4/6 (+1)**

**Change**: Expanded the single-line resume bullet into per-phase guidance:
- phase=plan: re-run plannotator gate if plan_approved=false
- phase=execute: skip PLAN, resume from last implementation checkpoint
- phase=verify: skip PLAN+EXECUTE, re-run verification commands
- phase=cleanup: run cleanup script, then mark done

**Section**: STEP 0.1: Recovery Rules

---

## Experiment 4: UNITY-DETECT fix (KEEP)

**Score: 4 -> 5/6 (+1)**

**Change**: Replaced the vague Korean description with a concrete bash command:
```bash
curl -sf http://localhost:8080/health >/dev/null 2>&1 && echo "unity-mcp: available" || echo "unity-mcp: not available"
```
Added explicit branching: exit 0 activates Unity3D verification loop, otherwise standard agent-browser.

**Section**: Unity3D mode detection

---

## Experiment 5: CLEANUP-GUARD fix (KEEP)

**Score: 5 -> 6/6 (+1)**

**Change**: Added a guard script block before the cleanup command:
```bash
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "[OMU][CLEANUP] Uncommitted changes detected. Commit or stash before cleanup."
  git status --short
  exit 1
fi
```

**Section**: CLEANUP (before worktree-cleanup.sh)

---

## Final Result

**Baseline: 1/6 (0.17) -> Final: 6/6 (1.00)**

All 5 mutations kept. No mutations discarded.
