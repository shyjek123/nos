#!/bin/bash

# Authenticate with GitHub CLI, then optionally clone repos into ~/projects.
# Always tries to install Nvim_Config → ~/.config/nvim (symlink) when available.
# Clone failures must not abort the rest of NOS install.

PROJECTS_DIR="${NOS_PROJECTS_DIR:-$HOME/projects}"

install_nvim_config_from_projects() {
  local src="$PROJECTS_DIR/Nvim_Config/nvim"
  local dest="$HOME/.config/nvim"

  if [[ ! -d "$src" ]]; then
    return 0
  fi

  mkdir -p "$HOME/.config"

  if [[ -L "$dest" ]]; then
    local current
    current=$(readlink -f "$dest" 2>/dev/null || true)
    local target
    target=$(readlink -f "$src" 2>/dev/null || true)
    if [[ -n "$current" && "$current" == "$target" ]]; then
      echo "Neovim config already linked: $dest → $src"
      return 0
    fi
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    if gum confirm "Replace existing ~/.config/nvim with Nvim_Config/nvim (symlink)?"; then
      local bak="$HOME/.config/nvim.bak.$(date +%s)"
      mv "$dest" "$bak"
      echo "Backed up previous config to $bak"
    else
      echo "Keeping existing ~/.config/nvim"
      return 0
    fi
  fi

  ln -sfn "$src" "$dest"
  echo "Installed Neovim config (symlink): $dest → $src"
}

ensure_nvim_config_repo() {
  local dest="$PROJECTS_DIR/Nvim_Config"
  if [[ -d "$dest/nvim" ]]; then
    return 0
  fi
  if [[ -d "$dest/.git" ]]; then
    return 0
  fi

  if ! gum confirm "Clone your Nvim_Config repo into $dest for Neovim?"; then
    echo "Skipping Neovim config install."
    return 0
  fi

  mkdir -p "$PROJECTS_DIR"
  if [[ -e "$dest" ]]; then
    echo "Path exists but has no nvim/ folder: $dest"
    return 0
  fi

  local user
  user=$(gh api user --jq .login 2>/dev/null || true)
  if [[ -z "$user" ]]; then
    echo "Could not resolve GitHub username — clone Nvim_Config manually."
    return 0
  fi

  if ! gh repo clone "$user/Nvim_Config" "$dest"; then
    echo "Failed to clone $user/Nvim_Config — install Neovim config later via: nos install"
    return 0
  fi
}

if ! command -v gh >/dev/null; then
  source "$NOS_PATH/install/terminal/app-github-cli.sh"
fi

if ! gh auth status -h github.com &>/dev/null; then
  echo "Sign in to GitHub (browser or token)…"
  gh auth login || true
fi

if ! gh auth status -h github.com &>/dev/null; then
  echo "GitHub authentication failed or was cancelled — skipping project clone."
  return 0 2>/dev/null || true
fi

CLONE_ALL=false
if gum confirm "Download all of your GitHub repositories to $PROJECTS_DIR?"; then
  CLONE_ALL=true
else
  echo "Skipping full repository clone."
fi

if [[ "$CLONE_ALL" == true ]]; then
  mkdir -p "$PROJECTS_DIR"

  echo "Fetching your repositories…"
  REPOS_JSON=""
  if ! REPOS_JSON=$(gh repo list --limit 1000 --json nameWithOwner,isArchived 2>/dev/null); then
    echo "Failed to list repositories — skipping bulk clone."
    REPOS_JSON="[]"
  fi

  mapfile -t REPOS < <(
    echo "$REPOS_JSON" | jq -r '.[] | select(.isArchived|not) | .nameWithOwner' 2>/dev/null || true
  )

  if [[ ${#REPOS[@]} -eq 0 ]]; then
    echo "No repositories found for this account."
  else
    echo "Cloning ${#REPOS[@]} repositories into $PROJECTS_DIR…"
    for repo in "${REPOS[@]}"; do
      [[ -z "$repo" ]] && continue
      name="${repo##*/}"
      dest="$PROJECTS_DIR/$name"
      if [[ -d "$dest/.git" ]]; then
        echo "skip (exists): $name"
        continue
      fi
      if [[ -e "$dest" ]]; then
        echo "skip (path exists, not a git repo): $name"
        continue
      fi
      echo "cloning: $repo"
      if ! gh repo clone "$repo" "$dest"; then
        echo "failed: $repo (continuing)"
      fi
    done
    echo "Done. Projects are in $PROJECTS_DIR"
  fi
fi

# Neovim config: always attempt (clone just Nvim_Config if missing)
ensure_nvim_config_repo
install_nvim_config_from_projects
