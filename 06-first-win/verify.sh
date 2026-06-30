#!/usr/bin/env bash
# ============================================================================
# verify.sh — проверка фазы 06: проект создан, коммит есть, отправлен в GitHub.
#
# ЧТО ДЕЛАЕТ: проверяет, что учебный проект существует, что есть хотя бы один
#   коммит и (по возможности) что проект привязан к GitHub.
# ЧТО МЕНЯЕТ НА МАШИНЕ: ничего.
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет.   СКОЛЬКО ВРЕМЕНИ: секунды.
#
# ПРИМЕЧАНИЕ: «увидеть счётчик на симуляторе» проверяется глазами — это делает
#   человек/Codex во время flutter run. Здесь — техническая часть.
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

APP_DIR="$HOME/vibecoding/vibecoding_first_app"
fail=0

step "Проверка фазы 06 — первая победа"

if [ -f "$APP_DIR/pubspec.yaml" ]; then
  ok "Проект на месте: $APP_DIR"
else
  err "Проект не найден. Запусти create-and-run.sh"; fail=1
fi

if [ -d "$APP_DIR/.git" ]; then
  ok "Git включён в проекте."
  if git -C "$APP_DIR" rev-parse HEAD >/dev/null 2>&1; then
    ok "Есть коммит: $(git -C "$APP_DIR" log -1 --pretty='%s')"
  else
    warn "Коммитов пока нет. Запусти first-edit-commit.sh после правки текста."
  fi
  if git -C "$APP_DIR" remote get-url origin >/dev/null 2>&1; then
    ok "Привязан к GitHub: $(git -C "$APP_DIR" remote get-url origin)"
  else
    warn "Проект ещё не в GitHub. Это можно сделать в first-edit-commit.sh (Шаг 5)."
  fi
else
  warn "Git в проекте не включён — запусти first-edit-commit.sh"
fi

step "Глазами (это проверяет человек)"
note "На игрушечном iPhone открылось приложение, и кнопка + увеличивает число?"
note "После правки ИИ на экране появился новый текст («Моё первое приложение»)?"

if [ "$fail" -eq 0 ]; then
  ok "Техническая часть фазы 06 на месте. Дальше — 07-checkpoint/."
  mark_step "06-first-win:verified"
else
  err "Есть незакрытые пункты. Вернись к скриптам фазы 06 или открой TROUBLESHOOTING.md."
  exit 1
fi
