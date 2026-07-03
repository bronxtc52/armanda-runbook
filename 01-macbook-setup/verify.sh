#!/usr/bin/env bash
# ============================================================================
# verify.sh — проверка фазы 01: применились ли ключевые настройки Mac.
#
# ЧТО ДЕЛАЕТ: читает несколько настроек через `defaults read` и проверяет, что
#   они выставлены. Ничего не меняет.
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет.   СКОЛЬКО ВРЕМЕНИ: секунды.
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

fail=0

step "Проверка фазы 01 — настройка MacBook"

check_default() { # check_default "описание" <domain> <key> <ожидаемое>
  local desc="$1" domain="$2" key="$3" want="$4" got
  got="$(defaults read "$domain" "$key" 2>/dev/null || echo '—')"
  if [ "$got" = "$want" ]; then ok "$desc"; else warn "ещё нет — $desc (сейчас: $got)"; fail=1; fi
}

check_default "Finder: показ скрытых файлов включён" com.apple.finder AppleShowAllFiles 1
check_default "Finder: полный путь в заголовке"       com.apple.finder _FXShowPosixPathInTitle 1
check_default "Все расширения файлов видны"           NSGlobalDomain AppleShowAllExtensions 1
check_default "Dock: автоскрытие включено"            com.apple.dock autohide 1
check_default "Пароль сразу после сна"                com.apple.screensaver askForPassword 1

# Папка скриншотов
if [ -d "$HOME/Pictures/Screenshots" ]; then ok "Папка для скриншотов создана."; else warn "Папки ~/Pictures/Screenshots нет."; fail=1; fi

if [ "$fail" -eq 0 ]; then
  ok "Фаза 01 пройдена. Дальше — 02-foundation/ (ставим Homebrew)."
  mark_step "01-macbook-setup:verified"
else
  warn "Часть настроек не применилась. Запусти setup-mac-defaults.sh ещё раз (это безопасно)."
  note "Иногда настройки Finder/Dock видны только после перезапуска Finder/Dock или перезагрузки Mac."
  # verify — гейт фазы: возвращаем ненулевой код, как и в остальных фазах,
  # чтобы агент не пошёл дальше с незакрытыми пунктами.
  exit 1
fi
