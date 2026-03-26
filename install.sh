#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/daemonicai/teambuild.git"
INSTALL_DIR="${HOME}/.claude/teambuilder"
COMMANDS_SRC="${INSTALL_DIR}/commands/teambuild"
COMMANDS_DST="${HOME}/.claude/commands/teambuild"

# Install or update
if [ -d "${INSTALL_DIR}/.git" ]; then
  echo "Updating teambuilder..."
  git -C "${INSTALL_DIR}" pull --ff-only
else
  echo "Installing teambuilder..."
  git clone --depth 1 --branch release "${REPO_URL}" "${INSTALL_DIR}"
fi

# Ensure ~/.claude/commands exists
mkdir -p "${HOME}/.claude/commands"

# Symlink commands/teambuild into ~/.claude/commands/teambuild
if [ -L "${COMMANDS_DST}" ]; then
  # Already a symlink — verify it points to the right place
  if [ "$(readlink "${COMMANDS_DST}")" != "${COMMANDS_SRC}" ]; then
    echo "Updating symlink..."
    ln -sf "${COMMANDS_SRC}" "${COMMANDS_DST}"
  fi
elif [ -d "${COMMANDS_DST}" ]; then
  echo "Error: ${COMMANDS_DST} exists and is not a symlink. Remove it and re-run." >&2
  exit 1
else
  ln -s "${COMMANDS_SRC}" "${COMMANDS_DST}"
fi

echo "Done. teambuilder commands are available as /teambuild:* in Claude Code."
