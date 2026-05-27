#!/usr/bin/env bash
#
# install.sh — Install personal Claude Code setup
#
# Copies agents, skills, templates, and global CLAUDE.md to ~/.claude/
# Safe to run multiple times: backs up existing files before overwriting.
#
# Usage:
#   ./install.sh                  # interactive install
#   ./install.sh --yes            # non-interactive, accept all defaults
#   ./install.sh --dry-run        # show what would happen, don't touch anything
#   ./install.sh --no-backup      # skip backups (NOT recommended)
#

set -euo pipefail

# ============================================================
# Configuration
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${SCRIPT_DIR}/home-claude"
DEST_DIR="${HOME}/.claude"
BACKUP_DIR="${HOME}/.claude.backup.$(date +%Y%m%d-%H%M%S)"
TEMPLATES_DEST="${DEST_DIR}/templates"

# Flags
DRY_RUN=false
YES=false
NO_BACKUP=false

# ============================================================
# Colors and logging
# ============================================================

if [ -t 1 ]; then
  RED=$'\033[0;31m'
  GREEN=$'\033[0;32m'
  YELLOW=$'\033[0;33m'
  BLUE=$'\033[0;34m'
  BOLD=$'\033[1m'
  RESET=$'\033[0m'
else
  RED=""; GREEN=""; YELLOW=""; BLUE=""; BOLD=""; RESET=""
fi

log()    { printf "%s\n" "$1"; }
info()   { printf "%s[ℹ]%s %s\n" "$BLUE" "$RESET" "$1"; }
ok()     { printf "%s[✓]%s %s\n" "$GREEN" "$RESET" "$1"; }
warn()   { printf "%s[⚠]%s %s\n" "$YELLOW" "$RESET" "$1"; }
err()    { printf "%s[✗]%s %s\n" "$RED" "$RESET" "$1" >&2; }
header() { printf "\n%s%s%s\n" "$BOLD" "$1" "$RESET"; }

# ============================================================
# Args
# ============================================================

for arg in "$@"; do
  case "$arg" in
    --dry-run)    DRY_RUN=true ;;
    --yes|-y)     YES=true ;;
    --no-backup)  NO_BACKUP=true ;;
    --help|-h)
      grep '^#' "$0" | sed 's/^# \{0,1\}//' | head -20
      exit 0
      ;;
    *)
      err "Unknown argument: $arg"
      exit 1
      ;;
  esac
done

# ============================================================
# Preflight
# ============================================================

header "Preflight checks"

if [ ! -d "$SOURCE_DIR" ]; then
  err "Source directory not found: $SOURCE_DIR"
  err "Are you running install.sh from the setup root?"
  exit 1
fi
ok "Source directory found: $SOURCE_DIR"

# Detect OS
OS="$(uname -s)"
case "$OS" in
  Darwin) ok "Detected macOS" ;;
  Linux)  ok "Detected Linux" ;;
  *)      warn "Untested OS: $OS. Proceeding anyway." ;;
esac

# Check for Claude Code
if command -v claude >/dev/null 2>&1; then
  CC_VERSION="$(claude --version 2>/dev/null || echo 'unknown')"
  ok "Claude Code found: $CC_VERSION"
else
  warn "Claude Code CLI not detected in PATH."
  warn "The setup will still install to ~/.claude/, but you'll need Claude Code to use it."
fi

# ============================================================
# Confirmation
# ============================================================

header "Plan"

log "Will install:"
log "  Global CLAUDE.md         → ${DEST_DIR}/CLAUDE.md"
log "  Agents (19)              → ${DEST_DIR}/agents/"
log "  Skills (27)              → ${DEST_DIR}/skills/"
log "  Templates (4)            → ${DEST_DIR}/templates/"
log ""

if [ -d "$DEST_DIR" ]; then
  if [ "$NO_BACKUP" = false ]; then
    warn "Existing ~/.claude/ found."
    log "  Will backup to: $BACKUP_DIR"
  else
    warn "Existing ~/.claude/ will be MERGED OVER (no backup, --no-backup set)."
  fi
fi

if [ "$DRY_RUN" = true ]; then
  warn "DRY RUN: nothing will actually be changed."
fi

if [ "$YES" = false ] && [ "$DRY_RUN" = false ]; then
  log ""
  printf "Continue? [y/N] "
  read -r REPLY
  case "$REPLY" in
    [yY]|[yY][eE][sS]) ;;
    *) info "Aborted."; exit 0 ;;
  esac
fi

# ============================================================
# Helpers
# ============================================================

run() {
  if [ "$DRY_RUN" = true ]; then
    log "    [dry-run] $*"
  else
    "$@"
  fi
}

# Copy a file, merging carefully (don't blow away user's customizations to CLAUDE.md without backup)
copy_file() {
  local src="$1"
  local dst="$2"

  if [ "$DRY_RUN" = true ]; then
    log "    [dry-run] copy: $src → $dst"
    return
  fi

  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
}

# Copy a directory, preserving contents
copy_dir() {
  local src="$1"
  local dst="$2"

  if [ "$DRY_RUN" = true ]; then
    log "    [dry-run] copy dir: $src → $dst"
    return
  fi

  mkdir -p "$dst"
  # Use cp -R to copy contents. -p preserves perms/times.
  cp -Rp "$src"/. "$dst"/
}

# ============================================================
# Backup existing setup
# ============================================================

if [ -d "$DEST_DIR" ] && [ "$NO_BACKUP" = false ]; then
  header "Backing up existing ~/.claude/"
  if [ "$DRY_RUN" = false ]; then
    cp -Rp "$DEST_DIR" "$BACKUP_DIR"
    ok "Backed up to: $BACKUP_DIR"
  else
    log "    [dry-run] cp -Rp $DEST_DIR $BACKUP_DIR"
  fi
fi

# ============================================================
# Install global CLAUDE.md
# ============================================================

header "Installing global CLAUDE.md"

if [ -f "$DEST_DIR/CLAUDE.md" ] && [ "$YES" = false ] && [ "$DRY_RUN" = false ]; then
  warn "~/.claude/CLAUDE.md already exists."
  printf "Overwrite? [y/N] "
  read -r REPLY
  case "$REPLY" in
    [yY]|[yY][eE][sS])
      copy_file "$SOURCE_DIR/CLAUDE.md" "$DEST_DIR/CLAUDE.md"
      ok "Installed CLAUDE.md"
      ;;
    *)
      info "Skipped CLAUDE.md (kept existing)"
      ;;
  esac
else
  copy_file "$SOURCE_DIR/CLAUDE.md" "$DEST_DIR/CLAUDE.md"
  ok "Installed CLAUDE.md"
fi

# ============================================================
# Install agents
# ============================================================

header "Installing agents"

AGENT_COUNT=0
for agent_file in "$SOURCE_DIR"/agents/*.md; do
  [ -f "$agent_file" ] || continue
  agent_name="$(basename "$agent_file")"
  copy_file "$agent_file" "$DEST_DIR/agents/$agent_name"
  ok "  agents/$agent_name"
  AGENT_COUNT=$((AGENT_COUNT + 1))
done
info "Installed $AGENT_COUNT agents"

# ============================================================
# Install skills
# ============================================================

header "Installing skills"

SKILL_COUNT=0
for skill_dir in "$SOURCE_DIR"/skills/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  copy_dir "$skill_dir" "$DEST_DIR/skills/$skill_name"
  ok "  skills/$skill_name/"
  SKILL_COUNT=$((SKILL_COUNT + 1))
done
info "Installed $SKILL_COUNT skills (each also exposed as /$(echo 'slash command'))"

# ============================================================
# Install templates
# ============================================================

header "Installing templates"

TEMPLATE_COUNT=0
for tmpl_dir in "$SOURCE_DIR"/templates/*/; do
  [ -d "$tmpl_dir" ] || continue
  tmpl_name="$(basename "$tmpl_dir")"
  copy_dir "$tmpl_dir" "$TEMPLATES_DEST/$tmpl_name"
  ok "  templates/$tmpl_name/"
  TEMPLATE_COUNT=$((TEMPLATE_COUNT + 1))
done
info "Installed $TEMPLATE_COUNT templates"

# ============================================================
# Verify
# ============================================================

if [ "$DRY_RUN" = false ]; then
  header "Verification"

  EXPECTED_AGENTS=19
  EXPECTED_SKILLS=27
  EXPECTED_TEMPLATES=4

  ACTUAL_AGENTS=$(find "$DEST_DIR/agents" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  ACTUAL_SKILLS=$(find "$DEST_DIR/skills" -maxdepth 2 -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
  ACTUAL_TEMPLATES=$(find "$TEMPLATES_DEST" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')

  if [ "$ACTUAL_AGENTS" -ge "$EXPECTED_AGENTS" ]; then
    ok "Agents: $ACTUAL_AGENTS installed"
  else
    err "Agents: expected $EXPECTED_AGENTS, found $ACTUAL_AGENTS"
  fi

  if [ "$ACTUAL_SKILLS" -ge "$EXPECTED_SKILLS" ]; then
    ok "Skills: $ACTUAL_SKILLS installed"
  else
    err "Skills: expected $EXPECTED_SKILLS, found $ACTUAL_SKILLS"
  fi

  if [ "$ACTUAL_TEMPLATES" -ge "$EXPECTED_TEMPLATES" ]; then
    ok "Templates: $ACTUAL_TEMPLATES installed"
  else
    err "Templates: expected $EXPECTED_TEMPLATES, found $ACTUAL_TEMPLATES"
  fi
fi

# ============================================================
# Next steps
# ============================================================

header "Done"

if [ "$DRY_RUN" = true ]; then
  info "Dry run complete. Re-run without --dry-run to actually install."
  exit 0
fi

cat <<EOF

${BOLD}Next steps:${RESET}

  1. Open Claude Code. Run /agents to see your installed subagents:
       ${BLUE}claude${RESET}
       ${BLUE}> /agents${RESET}

  2. To start a new project:
       ${BLUE}cd <new-project-dir>${RESET}
       ${BLUE}claude${RESET}
       ${BLUE}> /kickoff "Brief project description"${RESET}

  3. To use a project template:
       ${BLUE}cp -R ~/.claude/templates/web-fullstack/* <new-project-dir>/${RESET}

  4. Read the manual:
       ${BLUE}open ~/.claude/README.md  # or wherever you placed it${RESET}

${BOLD}Tip:${RESET} restart Claude Code to ensure all new agents and skills are loaded.

EOF

if [ "$NO_BACKUP" = false ] && [ -d "$BACKUP_DIR" ]; then
  log "Your previous setup was backed up to:"
  log "  ${BACKUP_DIR}"
  log ""
  log "If everything works, you can delete it with:"
  log "  rm -rf '$BACKUP_DIR'"
fi
