#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/daemonicai/teambuilder.git"
REPO_API="https://api.github.com/repos/daemonicai/teambuilder/releases/latest"
INSTALL_DIR="${HOME}/.claude/teambuilder"
COMMANDS_SRC="${INSTALL_DIR}/commands/teambuild"
COMMANDS_DST="${HOME}/.claude/commands/teambuild"
SKILLS_SRC_DIR="${INSTALL_DIR}/skills"
SKILLS_DST_DIR="${HOME}/.claude/skills"

# Resolve the target ref. Priority: VERSION env var > latest GitHub release > main (bootstrap).
resolve_target() {
  if [ -n "${VERSION:-}" ]; then
    echo "${VERSION}"
    return
  fi

  local tag
  tag="$(curl -fsSL "${REPO_API}" 2>/dev/null \
    | grep -E '"tag_name"[[:space:]]*:' \
    | head -n 1 \
    | sed -E 's/.*"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/' || true)"

  if [ -n "${tag}" ]; then
    echo "${tag}"
  else
    echo "main"
  fi
}

TARGET="$(resolve_target)"

if [ "${TARGET}" = "main" ]; then
  echo "No release tag found (or VERSION=main). Installing from main — this is an unreleased build."
else
  echo "Target: ${TARGET}"
fi

# Determine the current ref of an existing install (tag name if detached, branch name if on a branch, empty if no install).
current_ref() {
  if [ ! -d "${INSTALL_DIR}/.git" ]; then
    return
  fi
  # Detached HEAD on a tag: describe exact match.
  local tag
  tag="$(git -C "${INSTALL_DIR}" describe --tags --exact-match 2>/dev/null || true)"
  if [ -n "${tag}" ]; then
    echo "${tag}"
    return
  fi
  # On a branch.
  local branch
  branch="$(git -C "${INSTALL_DIR}" symbolic-ref --short HEAD 2>/dev/null || true)"
  if [ -n "${branch}" ]; then
    echo "${branch}"
    return
  fi
  # Detached but not on a tag we can name.
  echo "unknown"
}

CURRENT="$(current_ref)"

# Install or update.
if [ -z "${CURRENT}" ]; then
  echo "Installing teambuilder at ${TARGET}..."
  git clone --depth 1 --branch "${TARGET}" "${REPO_URL}" "${INSTALL_DIR}"
elif [ "${CURRENT}" = "${TARGET}" ]; then
  echo "teambuilder is already at ${TARGET}. Refreshing symlinks only."
else
  echo "Migrating teambuilder from ${CURRENT} to ${TARGET}..."
  rm -rf "${INSTALL_DIR}"
  git clone --depth 1 --branch "${TARGET}" "${REPO_URL}" "${INSTALL_DIR}"
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
