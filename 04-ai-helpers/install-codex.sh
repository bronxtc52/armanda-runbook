#!/usr/bin/env bash
# ============================================================================
# install-codex.sh — поставить Codex (второй ИИ-помощник, «второй взгляд»).
#
# ЧТО ДЕЛАЕТ: ставит Codex глобально через npm и проверяет команду.
# ЧТО МЕНЯЕТ НА МАШИНЕ: ставит npm-пакет @openai/codex глобально
#   (команда `codex` становится доступной в Терминале).
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет. ВХОД В АККАУНТ: при первом запуске `codex`
#   попросит войти через ChatGPT — это делает человек сам, не скрипт.
# СКОЛЬКО ВРЕМЕНИ: 1–3 минуты.
#
# Идемпотентно. Стек курса: npm-вариант. Источник:
#   https://www.npmjs.com/package/@openai/codex
#   https://github.com/openai/codex
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

step "Codex — второй ИИ-помощник"
if has_cmd codex; then
  ok "Codex уже установлен ($(command -v codex)) — установку пропускаю."
else
  log "Ставлю Codex через npm (как задано стеком курса)."
  npm i -g @openai/codex
fi

step "Проверка"
if has_cmd codex; then
  VER="$(codex --version 2>/dev/null || true)"
  if [ -n "$VER" ]; then
    ok "Codex на месте: $VER"
  else
    ok "Команда codex доступна. Версия покажется после первого входа."
  fi
  note "Первый запуск: набери  codex  — попросит войти через ChatGPT."
  note "Если вместо версии открылся вход — это нормально: помощник установлен и ждёт задания."
  mark_step "04-ai-helpers:codex"
else
  err "Команда codex не появилась. См. TROUBLESHOOTING.md (раздел npm -g / PATH)."
  exit 1
fi
