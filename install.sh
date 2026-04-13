#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------
# knowledge-base-skill-kit installer
# Copies skill directories into the Claude Code skills directory.
#
# Usage:
#   ./install.sh              # interactive, installs to ~/.claude/skills/
#   ./install.sh --npm        # non-interactive (called by npm postinstall)
#   ./install.sh --dir <path> # install to a custom skills directory
# ---------------------------------------------------------------

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SOURCE="${REPO_DIR}/skills"
SKILLS_DIR="${CLAUDE_SKILLS_DIR:-${HOME}/.claude/skills}"
NPM_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --npm)
      NPM_MODE=true
      shift
      ;;
    --dir)
      SKILLS_DIR="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

SKILLS=(kb-create kb-import kb-query kb-maintain kb-evolve)

echo ""
echo "knowledge-base-skill-kit installer"
echo "==================================="
echo "Source:      ${SKILLS_SOURCE}"
echo "Destination: ${SKILLS_DIR}"
echo ""

if [[ "${NPM_MODE}" == false ]]; then
  read -r -p "Install skills to ${SKILLS_DIR}? [Y/n] " response
  response="${response:-Y}"
  if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
fi

# Create destination if needed
mkdir -p "${SKILLS_DIR}"

# Copy each skill
for skill in "${SKILLS[@]}"; do
  src="${SKILLS_SOURCE}/${skill}"
  dst="${SKILLS_DIR}/${skill}"

  if [[ -d "${dst}" ]]; then
    echo "  Updating  ${skill}/ ..."
    rm -rf "${dst}"
  else
    echo "  Installing ${skill}/ ..."
  fi

  cp -r "${src}" "${dst}"
done

echo ""
echo "Done. ${#SKILLS[@]} skills installed to ${SKILLS_DIR}."
echo ""
echo "Next steps:"
echo "  1. Install qmd:        bun install -g @tobilu/qmd"
echo "  2. Install qmd-skill:  https://github.com/levineam/qmd-skill"
echo "  3. Open Claude Code and run /kb-create to create your first knowledge base."
echo ""
