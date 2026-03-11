#!/usr/bin/env bash
# Validate all SKILL.md files in .unity-skills/

SKILLS_DIR="$(cd "$(dirname "$0")/../../.." && pwd)/.unity-skills"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

ok_count=0
warn_count=0

echo "=== oh-my-unity3d Skill Validation ==="

for skill_md in "$SKILLS_DIR"/*/SKILL.md; do
  skill_dir="$(dirname "$skill_md")"
  skill_name="$(basename "$skill_dir")"
  warnings=()
  checks=""

  # Check required frontmatter fields
  for field in name description keyword; do
    if grep -qE "^  $field:|^$field:" "$skill_md" 2>/dev/null; then
      checks="$checks $field ✓,"
    else
      warnings+=("missing frontmatter: $field")
      checks="$checks $field ✗,"
    fi
  done

  # Warn if SKILL.toon missing
  if [ ! -f "$skill_dir/SKILL.toon" ]; then
    warnings+=("missing SKILL.toon")
  fi

  # Check for Quick Start section
  if grep -qiE "^#+\s*(quick.?start|getting.?started)" "$skill_md" 2>/dev/null; then
    checks="$checks quick-start ✓"
  else
    warnings+=("missing quick-start section")
    checks="$checks quick-start ✗"
  fi

  checks="${checks#" "}"

  if [ ${#warnings[@]} -eq 0 ]; then
    echo -e "${GREEN}✅${RESET} $skill_name: $checks"
    (( ok_count++ ))
  else
    warn_msg=$(printf ", %s" "${warnings[@]}"); warn_msg="${warn_msg:2}"
    echo -e "${YELLOW}⚠️ ${RESET} $skill_name: $checks  [${warn_msg}]"
    (( warn_count++ ))
  fi
done

echo "=== Summary: $ok_count OK, $warn_count warnings ==="
exit 0
