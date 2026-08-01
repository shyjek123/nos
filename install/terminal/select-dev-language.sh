#!/bin/bash

# Install default programming languages
if [[ -v NOS_FIRST_RUN_LANGUAGES ]]; then
  languages=$NOS_FIRST_RUN_LANGUAGES
else
  AVAILABLE_LANGUAGES=("C/C++" "Zig" "Odin" "Node.js" "Go" "PHP" "Python" "Rust" "Java")
  languages=$(gum choose "${AVAILABLE_LANGUAGES[@]}" --no-limit --height 10 --header "Select programming languages")
fi

install_with_mise() {
  local tool=$1
  if ! mise use --global "$tool"; then
    echo "WARNING: mise failed to install $tool — continuing install."
    return 0
  fi
}

if [[ -n "$languages" ]]; then
  # Avoid word-splitting language names; gum returns one choice per line
  while IFS= read -r language; do
    [[ -z "$language" ]] && continue
    case $language in
    C/C++)
      sudo apt install -y build-essential clang clang-tools cmake ninja-build gdb gdb-multiarch lldb
      ;;
    Zig)
      # zig@latest can fail on bad/empty download mirrors (wget: "http://: Invalid host name")
      if ! mise use --global zig@latest; then
        echo "WARNING: zig@latest failed; trying zig@0.15.2..."
        mise use --global zig@0.15.2 || echo "WARNING: Zig install failed — install later with: mise use -g zig@latest"
      fi
      ;;
    Odin)
      # Odin isn't in mise by default; install from latest release
      cd /tmp
      ODIN_URL=$(curl -fsSL https://api.github.com/repos/odin-lang/Odin/releases/latest | grep -Po '"browser_download_url": "\K[^"]*linux[^"]*\.zip' | head -1)
      if [[ -z "$ODIN_URL" ]]; then
        echo "WARNING: Could not resolve Odin download URL — skipping."
      else
        wget -O odin.zip "$ODIN_URL"
        unzip -o odin.zip -d odin-dist
        sudo mkdir -p /usr/local/lib/odin
        sudo cp -a odin-dist/. /usr/local/lib/odin/
        sudo ln -sf /usr/local/lib/odin/odin /usr/local/bin/odin
        rm -rf odin.zip odin-dist
      fi
      cd -
      ;;
    Node.js)
      install_with_mise node@lts
      ;;
    Go)
      install_with_mise go@latest
      ;;
    PHP)
      sudo apt -y install php php-{curl,apcu,intl,mbstring,opcache,pgsql,mysql,sqlite3,redis,xml,zip} --no-install-recommends || true
      if php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" 2>/dev/null; then
        php composer-setup.php --quiet && sudo mv composer.phar /usr/local/bin/composer || echo "WARNING: Composer install failed"
        rm -f composer-setup.php
      fi
      ;;
    Python)
      install_with_mise python@latest
      ;;
    Rust)
      bash -c "$(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs)" -- -y \
        || echo "WARNING: Rustup install failed — install later with rustup"
      ;;
    Java)
      install_with_mise java@latest
      ;;
    esac
  done <<<"$languages"
fi
