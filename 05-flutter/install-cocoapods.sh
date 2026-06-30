#!/usr/bin/env bash
# ============================================================================
# install-cocoapods.sh — поставить CocoaPods (менеджер деталей для iOS/macOS).
#
# ЧТО ДЕЛАЕТ: ставит CocoaPods через Homebrew и проверяет версию.
# ЧТО МЕНЯЕТ НА МАШИНЕ: добавляет формулу cocoapods через Homebrew.
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет.   СКОЛЬКО ВРЕМЕНИ: 1–3 минуты.
#
# Идемпотентно. Источник: https://formulae.brew.sh/formula/cocoapods
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

require_macos
ensure_brew_in_path
if ! has_cmd brew; then
  err "Homebrew не найден. Сначала пройди 02-foundation/."
  exit 1
fi

step "CocoaPods — менеджер деталей для iPhone-плагинов"
if has_cmd pod && brew_pkg_installed cocoapods; then
  ok "CocoaPods уже установлен через Homebrew — пропускаю."
elif has_cmd pod; then
  ok "CocoaPods уже есть в системе — установку пропускаю."
else
  log "Ставлю CocoaPods через Homebrew."
  brew install cocoapods
fi

step "Проверка"
if has_cmd pod && pod --version >/dev/null 2>&1; then
  ok "Сработало: CocoaPods $(pod --version)"
  mark_step "05-flutter:cocoapods"
else
  err "pod не отвечает. См. TROUBLESHOOTING.md."
  exit 1
fi
