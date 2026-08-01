#!/bin/bash

# Uninstall programming languages
if [[ -v NOS_FIRST_RUN_LANGUAGES ]]; then
  languages=$NOS_FIRST_RUN_LANGUAGES
else
  AVAILABLE_LANGUAGES=("C/C++" "Zig" "Odin" "Rust" "Python" "Go" "Node.js" "Java" "PHP")
  languages=$(gum choose "${AVAILABLE_LANGUAGES[@]}" --no-limit --height 10 --header "Select programming languages to uninstall")
fi

if [[ -n $languages ]]; then
  for language in $languages; do
    case $language in
    C/C++)
      sudo apt -y purge clang clang-tools cmake ninja-build gdb gdb-multiarch lldb
      sudo apt -y autoremove
      ;;
    Zig)
      mise uninstall zig@latest || true
      ;;
    Odin)
      sudo rm -f /usr/local/bin/odin
      sudo rm -rf /usr/local/lib/odin
      ;;
    Rust)
      rustup self uninstall -y || true
      ;;
    Python)
      mise uninstall python@latest || true
      ;;
    Go)
      mise uninstall go@latest || true
      ;;
    Node.js)
      mise uninstall node@lts || true
      ;;
    Java)
      mise uninstall java@latest || true
      ;;
    PHP)
      sudo apt -y purge php php-{curl,apcu,intl,mbstring,opcache,pgsql,mysql,sqlite3,redis,xml,zip}
      sudo apt -y autoremove
      sudo rm -f /usr/local/bin/composer
      ;;
    esac
  done
fi
