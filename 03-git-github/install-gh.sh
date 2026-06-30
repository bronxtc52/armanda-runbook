#!/usr/bin/env bash
# ============================================================================
# install-gh.sh — поставить GitHub CLI (gh) и войти в GitHub.
#
# ЧТО ДЕЛАЕТ:
#   1) ставит gh через Homebrew (если нужно);
#   2) запускает официальный вход в GitHub через браузер (gh auth login --web).
# ЧТО МЕНЯЕТ НА МАШИНЕ: добавляет пакет gh; сохраняет токен входа GitHub в
#   стандартном хранилище gh (это делает сам gh, мы токенов не трогаем).
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет. НО нужен ВХОД В АККАУНТ GitHub через браузер —
#   скрипт остановится и попросит тебя подтвердить вход самому.
# СКОЛЬКО ВРЕМЕНИ: 3–5 минут.
#
# Идемпотентно: если вход уже выполнен — повторно не логинит.
# Источник: https://cli.github.com  ·  https://cli.github.com/manual/gh_auth_login
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

step "GitHub CLI (gh) — пульт GitHub прямо в Терминале"
if has_cmd gh && brew_pkg_installed gh; then
  ok "gh уже установлен — пропускаю установку."
else
  log "Ставлю GitHub CLI — это «кнопки GitHub без браузерной суеты»."
  brew install gh
fi

if has_cmd gh && gh --version >/dev/null 2>&1; then
  ok "gh на месте: $(gh --version | head -n1)"
else
  err "gh не отвечает. См. TROUBLESHOOTING.md."
  exit 1
fi

step "Вход в GitHub (через браузер)"
if gh auth status >/dev/null 2>&1; then
  ok "Ты уже вошёл в GitHub — повторный вход не нужен."
else
  log "Нужен аккаунт GitHub. Если его ещё нет — заведи бесплатно на https://github.com/signup"
  pause_for_human "Сейчас откроется браузер для входа в GitHub. Выбери GitHub.com, протокол HTTPS, вход через браузер и подтверди. Готов?"
  # Официальный браузерный вход. Без секретных токенов вручную.
  gh auth login --web || {
    warn "Вход не завершился. Это часто бывает с первого раза."
    note "Запусти этот скрипт снова или выполни вручную: gh auth login --web"
    exit 1
  }
fi

step "Проверка"
if gh auth status >/dev/null 2>&1; then
  ok "Облачный сейф открыт — ты вошёл в GitHub."
  mark_step "03-git-github:gh"
else
  err "gh пишет, что вход не выполнен. Попробуй: gh auth login --web"
  exit 1
fi
