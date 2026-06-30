#!/usr/bin/env bash
# ============================================================================
# install-node.sh — поставить Node и npm (база для ИИ-помощников).
#
# ЧТО ДЕЛАЕТ: ставит Node через Homebrew (если нужно). Внутри Node идёт npm —
#   «курьер», который потом доставит Claude Code и Codex.
# ЧТО МЕНЯЕТ НА МАШИНЕ: добавляет пакет node через Homebrew.
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет.   СКОЛЬКО ВРЕМЕНИ: 1–3 минуты.
#
# Идемпотентно. Источник: https://formulae.brew.sh/formula/node
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

step "Node и npm — розетка и курьер для ИИ-инструментов"
if has_cmd node && has_cmd npm && brew_pkg_installed node; then
  ok "Node уже установлен через Homebrew — пропускаю."
elif has_cmd node && has_cmd npm; then
  ok "Node и npm уже есть в системе — установку пропускаю."
else
  log "Ставлю Node — среду, в которой работают современные инструменты. npm идёт внутри."
  brew install node
fi

step "Проверка"
if has_cmd node && has_cmd npm && node -v >/dev/null 2>&1 && npm -v >/dev/null 2>&1; then
  ok "Node: $(node -v)"
  ok "npm:  $(npm -v)"
  mark_step "04-ai-helpers:node"
else
  err "node или npm не отвечают. См. TROUBLESHOOTING.md."
  exit 1
fi
