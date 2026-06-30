#!/usr/bin/env bash
# ============================================================================
# first-edit-commit.sh — сохранить первую правку коммитом и отправить в GitHub.
#
# ВАЖНО: саму правку текста делает ИИ-помощник (claude/codex) по твоему промпту —
#   это интерактивный шаг из runbook.md, НЕ этот скрипт. Скрипт берёт на себя
#   «машину времени»: показать изменения, сделать аккуратный коммит и отправить
#   проект в облачный сейф.
#
# ЧТО ДЕЛАЕТ:
#   1) включает Git в проекте (git init / ветка main) — если ещё не включён;
#   2) показывает git status и git diff (что именно изменилось);
#   3) делает атомарный коммит правки lib/main.dart;
#   4) отправляет проект в GitHub (gh repo create … --push) или git push.
# ЧТО МЕНЯЕТ НА МАШИНЕ: создаёт коммит в локальном репозитории; создаёт
#   приватный репозиторий на GitHub и пушит в него (с твоего согласия).
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет. Нужен вход в GitHub (уже сделан в фазе 03).
# СКОЛЬКО ВРЕМЕНИ: 3–5 минут.
#
# Идемпотентно: повторный запуск не плодит мусор; «нечего коммитить» — не ошибка.
# Источник: https://cli.github.com/manual/gh_repo_create
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

require_macos
APP_DIR="$HOME/vibecoding/vibecoding_first_app"
if [ ! -f "$APP_DIR/pubspec.yaml" ]; then
  err "Проект не найден: $APP_DIR. Сначала запусти 06-first-win/create-and-run.sh"
  exit 1
fi
cd "$APP_DIR"
if ! has_cmd git; then err "Git не найден. Вернись в 03-git-github/."; exit 1; fi

REPO_NAME="vibecoding-first-app"

step "Шаг 1. Включить машину времени Git в проекте"
if [ -d .git ]; then
  ok "Git уже включён в этом проекте."
else
  log "Включаю Git и называю основную ветку main."
  git init
  git branch -M main
fi

step "Шаг 2. Посмотреть, что изменилось"
log "Состояние файлов (git status):"
git status --short || true
note ""
log "Построчные изменения (git diff). Проверь глазами: ИИ трогал только то, что ты просил."
git --no-pager diff || true

step "Шаг 3. Секрет-проверка перед сохранением"
# Простой предохранитель: не коммитим .env и явные секреты.
if git status --short | grep -qiE '(^|/)\.env( |$)'; then
  err "В изменениях замечен файл .env — секреты в GitHub не отправляем!"
  note "Добавь .env в .gitignore и убери из индекса: git rm --cached .env"
  exit 1
fi

step "Шаг 4. Атомарный коммит правки"
# Добавляем именно правленый файл урока (а не всё подряд).
if [ -f lib/main.dart ]; then
  git add lib/main.dart
fi
# Если правок нет — это не ошибка, просто сообщаем.
if git diff --cached --quiet; then
  warn "Нечего коммитить: изменений в lib/main.dart нет."
  note "Сначала попроси Claude Code/Codex сделать маленькую правку текста (см. runbook.md, Шаг 2), потом запусти скрипт снова."
else
  git commit -m "feat: update first app text"
  ok "Коммит создан."
fi

step "Шаг 5. Отправить проект в GitHub (облачный сейф)"
if git remote get-url origin >/dev/null 2>&1; then
  log "Удалённый репозиторий уже привязан — просто отправляю изменения."
  git push -u origin main || warn "Push не прошёл. Проверь вход: gh auth status"
else
  if has_cmd gh && gh auth status >/dev/null 2>&1; then
    pause_for_human "Сейчас создам ПРИВАТНЫЙ репозиторий «$REPO_NAME» на твоём GitHub и отправлю туда проект. Это безопасно и обратимо. Продолжаем?"
    gh repo create "$REPO_NAME" --private --source=. --remote=origin --push \
      && ok "Готово — проект в облачном сейфе." \
      || warn "Не удалось создать репозиторий. Проверь вход: gh auth status, и попробуй снова."
  else
    warn "Ты не вошёл в GitHub (gh). Вернись в 03-git-github/ и выполни вход, потом запусти скрипт снова."
  fi
fi

step "Проверка"
ok "Чек-лист первой петли:"
note "• git diff показал только нужную правку;"
note "• коммит создан (git log покажет «feat: update first app text»);"
note "• на GitHub появился репозиторий $REPO_NAME (если шаг 5 прошёл)."
mark_step "06-first-win:committed"
