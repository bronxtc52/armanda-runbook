#!/usr/bin/env bash
# ============================================================================
# verify.sh — проверка фазы 06w: сайт создан, под Git, в GitHub, опубликован.
#
# ЧТО ДЕЛАЕТ: только проверяет. Ничего не меняет и не публикует.
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет.   СКОЛЬКО ВРЕМЕНИ: секунды.
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

SITE_DIR="$HOME/vibecoding/vibecoding_first_site"
fail=0

step "Проверка фазы 06w — первый сайт"

if [ -f "$SITE_DIR/index.html" ]; then
  ok "Сайт на месте: $SITE_DIR"
else
  err "Сайт не найден. Запусти create-site.sh"; fail=1
fi

if [ -f "$SITE_DIR/AGENTS.md" ]; then
  ok "Правила для ИИ-агента (AGENTS.md) лежат в проекте."
else
  warn "AGENTS.md в проекте нет — запусти create-site.sh ещё раз (он доложит файл)."
fi

if [ -d "$SITE_DIR/.git" ]; then
  ok "Git включён в проекте."
  if git -C "$SITE_DIR" rev-parse HEAD >/dev/null 2>&1; then
    ok "Есть коммит: $(git -C "$SITE_DIR" log -1 --pretty='%s')"
  else
    warn "Коммитов пока нет. Запусти publish-site.sh"
  fi
  if git -C "$SITE_DIR" remote get-url origin >/dev/null 2>&1; then
    ok "Привязан к GitHub: $(git -C "$SITE_DIR" remote get-url origin)"
  else
    warn "Сайт ещё не в GitHub. Это Шаг 3 в publish-site.sh"
  fi
else
  warn "Git в проекте не включён — запусти publish-site.sh"
fi

if [ -f "$SITE_DIR/.netlify/state.json" ]; then
  ok "Сайт привязан к Netlify (публикация была)."
else
  warn "Сайт ещё не публиковался на Netlify. Это Шаг 4 в publish-site.sh"
fi

step "Глазами (это проверяет человек)"
note "Сайт открывается по ссылке Netlify — с Mac и с телефона?"
note "После правки ИИ и нового деплоя на сайте виден новый текст?"

if [ "$fail" -eq 0 ]; then
  ok "Техническая часть фазы 06w на месте. Дальше — 07-checkpoint/."
  mark_step "06w-first-site:verified"
else
  err "Есть незакрытые пункты. Вернись к скриптам фазы 06w или открой TROUBLESHOOTING.md."
  exit 1
fi
