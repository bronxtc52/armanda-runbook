#!/usr/bin/env bash
# ============================================================================
# install-claude.sh — поставить Claude Code (главный ИИ-помощник курса).
#
# ЧТО ДЕЛАЕТ: ставит Claude Code глобально через npm и проверяет команду.
# ЧТО МЕНЯЕТ НА МАШИНЕ: ставит npm-пакет @anthropic-ai/claude-code глобально
#   (команда `claude` становится доступной в Терминале).
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет. ВХОД В АККАУНТ: при первом запуске `claude`
#   откроется браузер для входа — это делает человек сам, не скрипт.
# СКОЛЬКО ВРЕМЕНИ: 1–3 минуты.
#
# Идемпотентно: если claude уже есть — переустановку не навязывает.
# Стек курса: npm-вариант. Источник:
#   https://www.npmjs.com/package/@anthropic-ai/claude-code
#   https://docs.anthropic.com/en/docs/claude-code/setup
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

require_macos
ensure_brew_in_path
if ! has_cmd npm; then
  err "npm не найден. Сначала запусти 04-ai-helpers/install-node.sh"
  exit 1
fi

step "Claude Code — основной ИИ-помощник"
if has_cmd claude; then
  ok "Claude Code уже установлен ($(command -v claude)) — установку пропускаю."
else
  log "Ставлю Claude Code через npm (как задано стеком курса)."
  npm i -g @anthropic-ai/claude-code
fi

step "Проверка"
if has_cmd claude; then
  # Версия может не показаться до входа — это нормально. Главное, команда есть.
  VER="$(claude --version 2>/dev/null || true)"
  if [ -n "$VER" ]; then
    ok "Claude Code на месте: $VER"
  else
    ok "Команда claude доступна. Версия покажется после первого входа."
  fi
  note "Первый запуск: набери  claude  — откроется браузер для входа в аккаунт."
  note "Если вместо версии открылся вход — это ХОРОШИЙ знак: помощник установлен и ждёт задания."
  mark_step "04-ai-helpers:claude"
else
  err "Команда claude не появилась. См. TROUBLESHOOTING.md (раздел npm -g / PATH)."
  exit 1
fi
