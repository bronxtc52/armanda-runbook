#!/usr/bin/env bash
# ============================================================================
# verify.sh — проверка фазы 03: Git, gh, вход в GitHub, подпись Git.
#
# ЧТО ДЕЛАЕТ: вызывает git --version, gh --version, gh auth status и читает
#   подпись Git. Ничего не меняет.
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет.   СКОЛЬКО ВРЕМЕНИ: секунды.
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

ensure_brew_in_path
fail=0

step "Проверка фазы 03 — Git и GitHub"

if has_cmd git && git --version >/dev/null 2>&1; then
  ok "Git: $(git --version)"
else err "Git не установлен."; fail=1; fi

if has_cmd gh && gh --version >/dev/null 2>&1; then
  ok "gh: $(gh --version | head -n1)"
else err "gh не установлен."; fail=1; fi

if has_cmd gh && gh auth status >/dev/null 2>&1; then
  ok "Вход в GitHub выполнен."
else err "Вход в GitHub не выполнен (gh auth login --web)."; fail=1; fi

NAME="$(git config --global user.name  || true)"
EMAIL="$(git config --global user.email || true)"
if [ -n "$NAME" ] && [ -n "$EMAIL" ]; then
  ok "Подпись Git: $NAME <$EMAIL>"
else err "Подпись Git не задана (setup-git-identity.sh)."; fail=1; fi

# --- Защита от утечки секретов (setup-secret-guard.sh) ---
if has_cmd gitleaks; then
  ok "Сторож секретов: gitleaks $(gitleaks version 2>/dev/null | head -n1)"
else err "Сторож секретов не установлен (03-git-github/setup-secret-guard.sh)."; fail=1; fi

HOOKS_PATH="$(git config --global core.hooksPath || true)"
if [ -n "$HOOKS_PATH" ] && [ -x "$HOOKS_PATH/pre-commit" ]; then
  ok "Проверка секретов перед коммитом включена."
else err "pre-commit хук секретов не настроен (setup-secret-guard.sh)."; fail=1; fi

if [ -n "$(git config --global core.excludesfile || true)" ]; then
  ok "Секретные файлы (.env и др.) игнорируются во всех проектах."
else warn "Глобальный список секретных файлов не подключён (не критично)."; fi

if [ "$fail" -eq 0 ]; then
  ok "Фаза 03 пройдена. Дальше — 04-ai-helpers/."
  mark_step "03-git-github:verified"
else
  err "Есть незакрытые пункты. Вернись к скриптам фазы 03 или открой TROUBLESHOOTING.md."
  exit 1
fi
