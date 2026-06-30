#!/usr/bin/env bash
# ============================================================================
# install-tree.sh — поставить первый маленький инструмент `tree`.
#
# ЧТО ДЕЛАЕТ: ставит через Homebrew утилиту `tree` (показывает папки деревом).
#   Это «доказательство жизни»: если поставилось — магазин команд работает.
# ЧТО МЕНЯЕТ НА МАШИНЕ: добавляет пакет tree через Homebrew.
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет.
# СКОЛЬКО ВРЕМЕНИ: <1 минуты.
#
# Идемпотентно: если tree уже стоит — просто проверяет версию.
# Источник: https://formulae.brew.sh/formula/tree
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

require_macos
ensure_brew_in_path
if ! has_cmd brew; then
  err "Homebrew не найден. Сначала запусти 02-foundation/install-homebrew.sh"
  exit 1
fi

step "Первый инструмент через Homebrew: tree"
if has_cmd tree && brew_pkg_installed tree; then
  ok "tree уже установлен — пропускаю установку."
else
  log "Ставлю tree — показывает папки в виде дерева, как оглавление книги."
  brew install tree
fi

step "Проверка"
if has_cmd tree && tree --version >/dev/null 2>&1; then
  ok "Сработало: $(tree --version | head -n1)"
  mark_step "02-foundation:tree"
else
  err "tree не отвечает. Загляни в TROUBLESHOOTING.md."
  exit 1
fi
