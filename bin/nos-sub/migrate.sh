#!/bin/bash

# Update ~/.local/share/nos from upstream and run pending migrations.
# The install directory is a plain folder — not a git working tree.

NOS_PATH="${NOS_PATH:-$HOME/.local/share/nos}"
STATE_DIR="$NOS_PATH/state"
mkdir -p "$STATE_DIR"

# Previous sync time (unix). Migrations named > this value will run.
if [[ -f "$STATE_DIR/updated-at" ]]; then
  last_updated_at=$(tr -d '[:space:]' <"$STATE_DIR/updated-at")
elif [[ -d "$NOS_PATH/.git" ]]; then
  # Legacy git-based install: use last commit date once, then convert away from git
  last_updated_at=$(git -C "$NOS_PATH" log -1 --format=%cd --date=unix 2>/dev/null || date +%s)
else
  last_updated_at=$(date +%s)
fi

echo "Updating NOS install at $NOS_PATH..."

# Run sync as a separate process so set -euo / traps do not leak into this shell
bash "$NOS_PATH/bin/nos-sub/sync-from-upstream.sh"

# Re-link PATH launcher in case bin/nos changed
if [[ -f "$NOS_PATH/install/terminal/zz-nos-tui.sh" ]]; then
  # shellcheck disable=SC1091
  source "$NOS_PATH/install/terminal/zz-nos-tui.sh"
fi

echo "Running pending migrations (after $last_updated_at)..."
shopt -s nullglob
for file in "$NOS_PATH"/migrations/*.sh; do
  filename=$(basename "$file")
  migrate_at="${filename%.sh}"

  if [[ "$migrate_at" =~ ^[0-9]+$ ]] && (( migrate_at > last_updated_at )); then
    echo "=> migration $migrate_at"
    # shellcheck disable=SC1090
    source "$file"
  fi
done
shopt -u nullglob

date +%s >"$STATE_DIR/updated-at"
rm -rf "$NOS_PATH/.git"

echo "NOS update complete."
