# plannotator SKILL.md — Autoresearch Changelog

**Run date:** 2026-03-22
**Baseline score:** 1/6 (17%)
**Final score:** 6/6 (100%)
**Line count:** 577 → 278 (-52%)

---

## Mutation 1: Fix Pattern Numbering

**Eval fixed:** EVAL1 (Pattern numbering sequential)
**Score:** 1/6 → 2/6

**Problem:** Patterns were ordered 1,2,3,4,5,6,7,8,**10**,9 — Pattern 10 appeared before Pattern 9.

**Change:**
- Renumbered to strict sequential order 1–10
- OpenCode Setup (previously an unnumbered prose section between Pattern 8 and Pattern 9) promoted to **Pattern 9**
- Former Pattern 10 (Manual Save) merged into Pattern 10 (Notes Integration)
- Former Pattern 9 (Obsidian) renamed to Pattern 10 to cover all notes integrations

---

## Mutation 2: Add Do-Not-Use Section

**Eval fixed:** EVAL5 (Do-not-use section present)
**Score:** 2/6 → 3/6

**Problem:** Skill had no guidance on when NOT to use it, making keyword `plan` over-trigger.

**Change:**
- Added `## Do not use this skill when` section immediately after `## When to use this skill`
- 3 exclusion criteria: simple git diff without visual annotation, CI/CD pipelines, no-browser code review
- Changed frontmatter keyword from generic `plan` to specific `plannotator` to reduce false triggers

---

## Mutation 3: Condense Obsidian/Bear Section

**Eval fixed:** EVAL3 (Obsidian section under 80 lines)
**Score:** 3/6 → 4/6

**Problem:** Baseline Pattern 9 (Obsidian Integration) was ~170 lines (lines 386–555), disproportionate to its role as an optional feature.

**Change:**
- Merged Obsidian setup, Bear Notes, and Manual Save into single Pattern 10 (~55 lines)
- Removed: step-by-step install instructions (replaced with UI steps in prose), folder organization detail, redundant bash detection commands (`ls /Applications/Obsidian.app`, `cat ~/Library/...`)
- Kept: config table, file format example, Bear comparison table, Manual Save note

---

## Mutation 4: Inline Troubleshooting

**Eval fixed:** EVAL4 (Troubleshooting collocated with patterns)
**Score:** 4/6 → 5/6

**Problem:** Troubleshooting section was at lines 513–551, far from the patterns it described.

**Change:**
- Removed standalone `### Troubleshooting` section
- Converted each troubleshooting item to a `> **Tip:**` blockquote callout inline with its related pattern:
  - Vault not detected → inline in Pattern 10 setup steps
  - Plans not saving → inline in Pattern 10 as cookie/browser tip
  - Notes tab requires hook mode → inline in Pattern 10 Manual Save note
  - Bear export → merged into Bear Notes inline note
  - Settings not persisting → merged into cookie tip

---

## Mutation 5: Trim Overall Length

**Eval fixed:** EVAL6 (Skill under 450 lines)
**Score:** 5/6 → 6/6

**Problem:** Baseline was 577 lines; even after M1–M4 the skill was still over 450 lines.

**Change:**
- Removed verbose `What it does:` bullet lists from Patterns 1, 2, 4, 5 (script names are self-explanatory)
- Condensed Gemini CLI and Codex CLI patterns: removed duplicate python3 JSON examples; replaced with single shared `> **Tip:**` in Pattern 7, referenced from Pattern 8 ("Same python3 JSON format as Gemini applies here")
- Removed full inline `AfterAgent` hook JSON for Gemini CLI (reference setup script instead)
- Condensed Recommended Workflow section (removed prose headers, kept code blocks)
- Removed `## Auto-save (Summary)` stub section (content covered inline in Pattern 10)

---

## Summary of All Changes

| Mutation | Lines removed | Evals fixed |
|----------|--------------|-------------|
| M1: Fix numbering | ~0 (reorder only) | EVAL1 |
| M2: Do-not-use section | −0 (net add ~8 lines) | EVAL5 |
| M3: Condense Notes section | ~115 lines | EVAL3 |
| M4: Inline troubleshooting | ~40 lines | EVAL4 |
| M5: Trim verbose prose | ~145 lines | EVAL6 |
| **Total** | **~300 lines** | **5 evals** |
