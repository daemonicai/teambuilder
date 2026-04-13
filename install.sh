#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/daemonicai/teambuilder.git"
INSTALL_DIR="${HOME}/.claude/teambuilder"
COMMANDS_SRC="${INSTALL_DIR}/commands/teambuild"
COMMANDS_DST="${HOME}/.claude/commands/teambuild"
SKILLS_SRC_DIR="${INSTALL_DIR}/skills"
SKILLS_DST_DIR="${HOME}/.claude/skills"

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

# Ensure ~/.claude/skills exists, then symlink each teambuilder skill into it
mkdir -p "${SKILLS_DST_DIR}"

if [ -d "${SKILLS_SRC_DIR}" ]; then
  for skill_src in "${SKILLS_SRC_DIR}"/*/; do
    [ -d "${skill_src}" ] || continue
    skill_name="$(basename "${skill_src}")"
    skill_dst="${SKILLS_DST_DIR}/${skill_name}"
    # Strip trailing slash from source for a clean symlink target
    skill_src_nosl="${skill_src%/}"

    if [ -L "${skill_dst}" ]; then
      if [ "$(readlink "${skill_dst}")" != "${skill_src_nosl}" ]; then
        echo "Updating skill symlink: ${skill_name}"
        ln -sf "${skill_src_nosl}" "${skill_dst}"
      fi
    elif [ -e "${skill_dst}" ]; then
      echo "Error: ${skill_dst} exists and is not a symlink. Remove it and re-run." >&2
      exit 1
    else
      ln -s "${skill_src_nosl}" "${skill_dst}"
    fi
  done
fi

echo "Done. teambuilder commands are available as /teambuild:* in Claude Code."
