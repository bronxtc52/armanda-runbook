#!/usr/bin/env bash
# ============================================================================
# verify.sh — проверка фазы 05w: Netlify CLI стоит, вход выполнен.
#
# ЧТО ДЕЛАЕТ: только проверяет. Ничего не устанавливает и не меняет.
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет.   СКОЛЬКО ВРЕМЕНИ: секунды.
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

ensure_brew_in_path
fail=0

step "Проверка фазы 05w — издательство сайтов (Netlify)"

if has_cmd netlify; then
  ok "Netlify CLI установлен: $(netlify --version 2>/dev/null | head -1)"
else
  err "Netlify CLI не найден. Запусти install-netlify.sh"; fail=1
fi

if has_cmd netlify && netlify status 2>/dev/null | grep -q 'Email'; then
  ok "Вход в Netlify выполнен."
else
  err "Вход в Netlify не выполнен. Запусти install-netlify.sh (Шаг 3)."; fail=1
fi

if [ "$fail" -eq 0 ]; then
  ok "🎉 Фаза 05w пройдена! Дальше — 06w-first-site/: первый сайт в интернете."
  mark_step "05w-netlify:verified"
else
  err "Есть незакрытые пункты. Запусти install-netlify.sh ещё раз."
  exit 1
fi
