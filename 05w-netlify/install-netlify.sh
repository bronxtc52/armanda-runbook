#!/usr/bin/env bash
# ============================================================================
# install-netlify.sh — поставить Netlify CLI и войти в аккаунт Netlify.
#
# ЧТО ЭТО: Netlify — «издательство сайтов»: отдаёшь ему папку с сайтом,
#   он публикует её в интернете и даёт ссылку. CLI — пульт к нему из Терминала.
# ЧТО МЕНЯЕТ НА МАШИНЕ: ставит npm-пакет netlify-cli (глобально).
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет. Нужен АККАУНТ Netlify — вход через браузер.
# СКОЛЬКО ВРЕМЕНИ: 2–4 минуты.
#
# Идемпотентно: если CLI уже стоит и вход выполнен — просто скажет об этом.
# Источник: https://docs.netlify.com/cli/get-started/
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

require_macos
ensure_brew_in_path

step "Шаг 1. Проверить Node и npm (ставились в фазе 04)"
if ! has_cmd npm; then
  err "npm не найден. Сначала пройди фазу 04: bash 04-ai-helpers/install-node.sh"
  exit 1
fi
ok "npm на месте: $(npm -v)"

step "Шаг 2. Поставить Netlify CLI"
if has_cmd netlify; then
  ok "Netlify CLI уже установлен: $(netlify --version 2>/dev/null | head -1)"
else
  log "Ставлю netlify-cli через npm (глобально). Это займёт минуту-другую."
  npm install -g netlify-cli
  ok "Netlify CLI установлен: $(netlify --version 2>/dev/null | head -1)"
fi

step "Шаг 3. Войти в аккаунт Netlify"
if netlify status 2>/dev/null | grep -q 'Email'; then
  ok "Вход в Netlify уже выполнен."
else
  note "Для публикации сайтов нужен БЕСПЛАТНЫЙ аккаунт Netlify."
  note "Если аккаунта ещё нет — зарегистрируйся на netlify.com (удобнее всего"
  note "кнопкой «Sign up with GitHub» — аккаунт GitHub у тебя уже есть с фазы 03)."
  pause_for_human "Сейчас откроется браузер со страницей входа Netlify. Войди в аккаунт (или сначала зарегистрируйся) и нажми «Authorize». Готов?"
  netlify login
  if netlify status 2>/dev/null | grep -q 'Email'; then
    ok "Вход в Netlify выполнен — издательство сайтов подключено!"
  else
    warn "Похоже, вход не завершился. Запусти скрипт ещё раз — повторная попытка безопасна."
    exit 1
  fi
fi

mark_step "05w-netlify:installed"
ok "Фаза 05w почти готова. Дальше: bash 05w-netlify/verify.sh"
