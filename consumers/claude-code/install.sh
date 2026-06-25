#!/usr/bin/env bash
# Installs the bc-quality-review Claude Code skill, using THIS BCQuality checkout as the
# knowledge corpus. Run from a clone of the fork:
#   bash ./consumers/claude-code/install.sh
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# The corpus is the BCQuality checkout this script lives in (consumers/claude-code -> repo root).
corpus="$(cd "$here/../.." && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

# 1. Install the skill.
skill_dest="$CLAUDE_DIR/skills/bc-quality-review"
mkdir -p "$skill_dest"
cp "$here/SKILL.md" "$skill_dest/SKILL.md"
echo "[1/2] Skill installed -> $skill_dest"

# 2. Point the skill at this checkout.
echo "[2/2] Add BCQUALITY_HOME to your shell profile so the skill finds this clone:"
echo "        echo 'export BCQUALITY_HOME=\"$corpus\"' >> ~/.bashrc   # or ~/.zshrc"
echo ""
echo "Done. This clone IS the corpus -- 'git pull' here to update knowledge."
echo "In any BC/AL repo, ask Claude to 'run a BCQuality review'."
