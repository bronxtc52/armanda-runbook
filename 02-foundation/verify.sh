#!/usr/bin/env bash
# ============================================================================
# verify.sh — проверка, что фундамент (Homebrew + tree) на месте.
#
# ЧТО ДЕЛАЕТ: реально вызывает brew --version и tree --version.
# ЧТО МЕНЯЕТ НА МАШИНЕ: ничего (только проверка).
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет.   СКОЛЬКО ВРЕМЕНИ: секунды.
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

ensure_brew_in_path
fail=0

step "Проверка фазы 02 — фундамент"

if has_cmd brew && brew --version >/dev/null 2>&1; then
  ok "Homebrew: $(brew --version | head -n1)"
else
  err "Homebrew не работает в этой сессии."; fail=1
fi

if has_cmd tree && tree --version >/dev/null 2>&1; then
  ok "tree: $(tree --version | head -n1)"
else
  err "tree не установлен."; fail=1
fi

if [ "$fail" -eq 0 ]; then
  ok "Фаза 02 пройдена. Можно идти в 03-git-github/."
  mark_step "02-foundation:verified"
else
  err "Есть незакрытые пункты. Вернись к install-homebrew.sh / install-tree.sh или открой TROUBLESHOOTING.md."
  exit 1
fi
