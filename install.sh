```bash
#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/rodolfo21233/Dotfiles-2.0.git"
REPO_DIR="${DOTFILES_DIR:-$HOME/.local/share/dotfiles-2.0}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

log()  { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m[ OK ]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[ERR ]\033[0m %s\n' "$*" >&2; exit 1; }

command -v git >/dev/null 2>&1 || die "Git is not installed."

echo
echo "╭────────────────────────────────────╮"
echo "│      Dotfiles-2.0 Installation     │"
echo "╰────────────────────────────────────╯"
echo

# ─────────────────────────────────────
# Backup
# ─────────────────────────────────────

echo "Would you like to backup your current configurations?"
echo
echo "  [1] Yes"
echo "  [2] No"
echo

read -rp "Select an option [1/2]: " BACKUP_CHOICE

case "$BACKUP_CHOICE" in
    1)
        DO_BACKUP=true
        BACKUP_DIR="$HOME/.config/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
        ;;
    2)
        DO_BACKUP=false
        ;;
    *)
        die "Invalid option."
        ;;
esac

echo

# ─────────────────────────────────────
# Repository
# ─────────────────────────────────────

log "Checking repository..."

if [[ -d "$REPO_DIR/.git" ]]; then
    log "Repository already exists:"
    echo "  $REPO_DIR"
    echo

    read -rp "Would you like to update it with git pull? [Y/n]: " UPDATE

    if [[ -z "$UPDATE" || "$UPDATE" =~ ^[Yy]$ ]]; then
        git -C "$REPO_DIR" pull --ff-only
    fi
else
    if [[ -e "$REPO_DIR" ]]; then
        die "$REPO_DIR exists but is not a Git repository."
    fi

    mkdir -p "$(dirname "$REPO_DIR")"

    log "Cloning Dotfiles-2.0..."
    git clone "$REPO_URL" "$REPO_DIR"
fi

mkdir -p "$CONFIG_DIR"

# ─────────────────────────────────────
# Configurations
# ─────────────────────────────────────

configs=(
    "niri"
    "quickshell"
    "matugen"
)

echo
log "Configurations:"
printf '  • %s\n' "${configs[@]}"
echo

# ─────────────────────────────────────
# Backup existing configs
# ─────────────────────────────────────

for name in "${configs[@]}"; do
    target="$CONFIG_DIR/$name"
    source="$REPO_DIR/$name"

    [[ -e "$source" || -L "$source" ]] || {
        warn "Missing $source; skipping."
        continue
    }

    # Already points to the repository
    if [[ -L "$target" ]] &&
       [[ "$(readlink -f "$target")" == "$(readlink -f "$source")" ]]; then
        ok "$name is already installed."
        continue
    fi

    # Existing configuration that will be replaced
    if [[ -e "$target" || -L "$target" ]]; then

        if [[ "$DO_BACKUP" == true ]]; then
            mkdir -p "$BACKUP_DIR"

            log "Backing up $name..."
            mv "$target" "$BACKUP_DIR/$name"

            ok "$name backed up."
        else
            warn "Removing existing configuration: $target"
            rm -rf "$target"
        fi
    fi
done

# ─────────────────────────────────────
# Symlinks
# ─────────────────────────────────────

echo
log "Installing configurations..."

for name in "${configs[@]}"; do
    source="$REPO_DIR/$name"
    target="$CONFIG_DIR/$name"

    [[ -e "$source" || -L "$source" ]] || continue

    ln -sfn "$source" "$target"

    ok "$target -> $source"
done

# ─────────────────────────────────────
# Summary
# ─────────────────────────────────────

echo
echo "╭────────────────────────────────────╮"
echo "│        Installation complete       │"
echo "╰────────────────────────────────────╯"
echo

echo "Repository:"
echo "  $REPO_DIR"
echo

echo "Configurations:"
for name in "${configs[@]}"; do
    if [[ -L "$CONFIG_DIR/$name" ]]; then
        echo "  ✓ $name"
    fi
done

if [[ "$DO_BACKUP" == true && -d "$BACKUP_DIR" ]]; then
    echo
    echo "Backup:"
    echo "  $BACKUP_DIR"
fi

echo
ok "Dotfiles installed successfully."
echo
warn "Restart Quickshell/Niri if necessary to apply the changes."
```

