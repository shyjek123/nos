#!/bin/bash

# Install default programming languages
if [[ -v NOS_FIRST_RUN_LANGUAGES ]]; then
  languages=$NOS_FIRST_RUN_LANGUAGES
else
  AVAILABLE_LANGUAGES=("C/C++" "Zig" "Odin" "Node.js" "Go" "PHP" "Python" "Rust" "Java")
  languages=$(gum choose "${AVAILABLE_LANGUAGES[@]}" --no-limit --height 10 --header "Select programming languages")
fi


if [[ -n "$languages" ]]; then
  for language in $languages; do
    case $language in
    C/C++)
      sudo apt install -y build-essential clang clang-tools cmake ninja-build gdb gdb-multiarch lldb
      ;;
    Zig)
      mise use --global zig@latest
      ;;
    Odin)
      # Odin isn't in mise by default; install from latest release
      cd /tmp
      ODIN_URL=$(curl -fsSL https://api.github.com/repos/odin-lang/Odin/releases/latest | grep -Po '"browser_download_url": "\K[^"]*linux[^"]*\.zip' | head -1)
      wget -O odin.zip "$ODIN_URL"
      unzip -o odin.zip -d odin-dist
      sudo mkdir -p /usr/local/lib/odin
      sudo cp -a odin-dist/. /usr/local/lib/odin/
      sudo ln -sf /usr/local/lib/odin/odin /usr/local/bin/odin
      rm -rf odin.zip odin-dist
      cd -
      ;;
    Node.js)
      mise use --global node@lts
      ;;
    Go)
      mise use --global go@latest
      ;;
    PHP)
      sudo apt -y install php php-{curl,apcu,intl,mbstring,opcache,pgsql,mysql,sqlite3,redis,xml,zip} --no-install-recommends
      php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
      php composer-setup.php --quiet && sudo mv composer.phar /usr/local/bin/composer
      rm composer-setup.php
      ;;
    Python)
      mise use --global python@latest
      ;;
    Rust)
      bash -c "$(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs)" -- -y
      ;;
    Java)
      mise use --global java@latest
      ;;
    esac
  done
fi
