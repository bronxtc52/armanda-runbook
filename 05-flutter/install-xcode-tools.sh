#!/usr/bin/env bash
# ============================================================================
# install-xcode-tools.sh — настроить Xcode (цех для iPhone) и iOS-платформу.
#
# ЧТО ДЕЛАЕТ:
#   1) проверяет, установлен ли полноценный Xcode (его ставят из App Store —
#      это делает человек, скрипт не может купить/скачать его за тебя);
#   2) указывает системе на Xcode (xcode-select -s) и проводит первый запуск;
#   3) принимает лицензию Xcode;
#   4) докачивает поддержку iOS и симулятора (downloadPlatform iOS).
# ЧТО МЕНЯЕТ НА МАШИНЕ: переключает активные инструменты разработчика на
#   Xcode.app; принимает лицензию Apple; скачивает iOS-платформу.
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: ДА — шаги 2 и 3 идут через sudo (системная настройка).
#   Скрипт предупреждает заранее и не прячет sudo.
# СКОЛЬКО ВРЕМЕНИ: 10–30 минут (iOS-платформа большая).
#
# Идемпотентно: если уже настроено/принято — повторно не навязывает.
# Источник: https://docs.flutter.dev/platform-integration/ios/setup
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

require_macos

# --- Шаг 1. Наличие Xcode из App Store --------------------------------------
step "Шаг 1. Полноценный Xcode (цех для iPhone)"
if [ ! -d "/Applications/Xcode.app" ]; then
  warn "Xcode пока не установлен. Его ставят из App Store — это нужно сделать вручную."
  pause_for_human "Открой App Store → найди «Xcode» → нажми «Загрузить»/«Установить» (это несколько ГБ, может идти долго). Открой Xcode один раз и согласись поставить доп.компоненты, если попросит. Когда Xcode установлен — продолжай."
fi
if [ ! -d "/Applications/Xcode.app" ]; then
  err "Xcode по-прежнему не найден в /Applications/Xcode.app."
  note "Заверши установку Xcode из App Store и запусти этот скрипт снова."
  exit 1
fi
ok "Xcode найден: /Applications/Xcode.app"

# --- Шаг 2. Указать систему на Xcode + первый запуск ------------------------
step "Шаг 2. Подключить Xcode как активный набор инструментов"
ACTIVE="$(xcode-select -p 2>/dev/null || true)"
if [ "$ACTIVE" = "/Applications/Xcode.app/Contents/Developer" ]; then
  ok "Система уже указывает на Xcode — пропускаю переключение."
else
  log "Переключаю активные инструменты на Xcode и провожу первый запуск."
  warn_password
  warn "Команда выполнится через sudo (нужны системные права):"
  note "sudo sh -c 'xcode-select -s /Applications/Xcode.app/Contents/Developer && xcodebuild -runFirstLaunch'"
  pause_for_human "Готов ввести пароль от Mac для системной настройки Xcode?"
  sudo sh -c 'xcode-select -s /Applications/Xcode.app/Contents/Developer && xcodebuild -runFirstLaunch'
  ok "Xcode подключён."
fi

# --- Шаг 3. Лицензия Xcode --------------------------------------------------
step "Шаг 3. Принять лицензию Xcode"
# Проверка статуса лицензии НЕ требует sudo — никаких скрытых запросов пароля.
if xcodebuild -license check >/dev/null 2>&1; then
  ok "Лицензия Xcode уже принята — пропускаю."
else
  log "Нужно принять лицензию Apple. Откроется текст: листай пробелом, в конце согласись."
  warn "Команда через sudo: sudo xcodebuild -license"
  pause_for_human "Готов прочитать и принять лицензию Xcode? (потребуется пароль от Mac)"
  sudo xcodebuild -license
fi

# --- Шаг 4. Докачать iOS-платформу и симулятор ------------------------------
step "Шаг 4. Скачать поддержку iOS и симулятора"
log "Докачиваю iOS-платформу (нужна для игрушечного iPhone). Может идти долго."
xcodebuild -downloadPlatform iOS || warn "Загрузка iOS-платформы не завершилась — можно повторить запуск позже."

step "Проверка"
ok "Xcode настроен. Активный путь: $(xcode-select -p)"
note "Игрушечный iPhone откроем командой:  open -a Simulator  (на шаге первой победы)."
mark_step "05-flutter:xcode"
