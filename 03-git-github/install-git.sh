#!/usr/bin/env bash
# ============================================================================
# install-git.sh — поставить Git («машину времени» проекта).
#
# ЧТО ДЕЛАЕТ: ставит git через Homebrew (если ещё не стоит) и проверяет версию.
# ЧТО МЕНЯЕТ НА МАШИНЕ: добавляет пакет git через Homebrew.
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет.   СКОЛЬКО ВРЕМЕНИ: 1–2 минуты.
#
# Идемпотентно. Источник: https://git-scm.com/install/mac
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

step "Git — машина времени для проекта"
if has_cmd git && brew_pkg_installed git; then
  ok "Git уже установлен через Homebrew — пропускаю."
elif has_cmd git; then
  log "Git уже есть в системе. Ставлю свежую версию из Homebrew поверх (так советует курс)."
  brew install git
else
  log "Ставлю Git — он умеет делать снимки проекта, чтобы можно было вернуться назад."
  brew install git
fi

step "Проверка"
if has_cmd git && git --version >/dev/null 2>&1; then
  ok "Сработало: $(git --version)"
  mark_step "03-git-github:git"
else
  err "git не отвечает. См. TROUBLESHOOTING.md."
  exit 1
fi
