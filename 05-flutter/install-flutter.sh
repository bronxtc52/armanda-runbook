#!/usr/bin/env bash
# ============================================================================
# install-flutter.sh — поставить Flutter («фабрику приложений»).
#
# ЧТО ДЕЛАЕТ: ставит Flutter SDK через Homebrew cask и проверяет версию.
# ЧТО МЕНЯЕТ НА МАШИНЕ: добавляет cask flutter через Homebrew.
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: обычно нет (cask ставит в пользовательскую область),
#   но Homebrew иногда просит пароль для cask — скрипт предупредит.
# СКОЛЬКО ВРЕМЕНИ: 3–10 минут (SDK большой).
#
# Идемпотентно. Источник: https://formulae.brew.sh/cask/flutter
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

step "Flutter — универсальный станок для приложений"
if has_cmd flutter && flutter --version >/dev/null 2>&1; then
  ok "Flutter уже установлен — пропускаю."
elif brew_pkg_installed flutter; then
  ok "Flutter cask уже стоит — пропускаю установку."
else
  log "Ставлю Flutter SDK через Homebrew. Это большой пакет, может занять несколько минут."
  warn "Homebrew может попросить пароль от Mac для установки cask — это нормально."
  brew install --cask flutter
fi

step "Проверка"
if has_cmd flutter && flutter --version >/dev/null 2>&1; then
  ok "Сработало: $(flutter --version | head -n1)"
  mark_step "05-flutter:flutter"
else
  err "flutter не отвечает в этой сессии."
  note "Закрой Терминал, открой заново и проверь: flutter --version"
  note "Если не помогло — TROUBLESHOOTING.md (раздел Flutter / PATH)."
  exit 1
fi
