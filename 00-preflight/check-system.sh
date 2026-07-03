#!/usr/bin/env bash
# ============================================================================
# check-system.sh — проверка машины ПЕРЕД стартом.
#
# ЧТО ДЕЛАЕТ: смотрит, какой чип, какая версия macOS и что из инструментов
#             курса уже стоит. Ничего не устанавливает.
# ЧТО МЕНЯЕТ НА МАШИНЕ: ничего. Это только осмотр (read-only).
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет.
# СКОЛЬКО ВРЕМЕНИ: ~10 секунд.
#
# Запускать можно сколько угодно раз — он только читает состояние.
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

require_macos

step "Осмотр компьютера (ничего не меняю, только смотрю)"

log "Какой у тебя Mac"
note "Чип: $(arch_human)  [$(detect_arch)]"
note "Homebrew для твоего чипа будет жить в: $(brew_prefix)"

log "Версия macOS"
if has_cmd sw_vers; then
  note "$(sw_vers -productName) $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
fi

log "Оболочка Терминала"
note "SHELL = ${SHELL:-неизвестно}  (курс рассчитан на zsh — он по умолчанию в современном macOS)"

step "Что из инструментов курса уже установлено"
# Список инструментов Фазы 0. Для каждого — есть/нет, без установки.
TOOLS="brew git gh node npm claude codex flutter pod tree xcodebuild"
have=0; miss=0
for t in $TOOLS; do
  if has_cmd "$t"; then
    printf '  ✅ %-10s — есть  (%s)\n' "$t" "$(command -v "$t")"
    have=$((have+1))
  else
    printf '  ⬜ %-10s — пока нет\n' "$t"
    miss=$((miss+1))
  fi
done

log "Командные инструменты Apple (Command Line Tools)"
if xcode-select -p >/dev/null 2>&1; then
  note "Есть: $(xcode-select -p)"
else
  note "Пока нет — поставим на шаге Homebrew (Apple покажет окно с кнопкой «Установить»)."
fi

log "Полноценный Xcode (нужен для iPhone-симулятора)"
if [ -d "/Applications/Xcode.app" ]; then
  note "Есть: /Applications/Xcode.app"
else
  note "Пока нет — поставим из App Store на шаге Flutter."
fi

step "Итог"
ok "Уже стоит: $have из $((have+miss)) инструментов. Осталось доустановить: $miss."
note "Это не оценка и не экзамен — просто карта, с чего начинать."
note "Дальше иди по INDEX.md, начиная с папки 01-macbook-setup/."

mark_step "00-preflight:checked"
