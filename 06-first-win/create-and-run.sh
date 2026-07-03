#!/usr/bin/env bash
# ============================================================================
# create-and-run.sh — создать готовое приложение и запустить его на симуляторе.
#
# ЧТО ДЕЛАЕТ:
#   1) создаёт папку ~/vibecoding и учебный проект vibecoding_first_app
#      (если его ещё нет) командой flutter create;
#   2) открывает игрушечный iPhone (iOS Simulator);
#   3) показывает список устройств;
#   4) запускает приложение через flutter run (живой процесс — отдаёт экран тебе).
# ЧТО МЕНЯЕТ НА МАШИНЕ: создаёт папку ~/vibecoding/vibecoding_first_app.
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет.   СКОЛЬКО ВРЕМЕНИ: 5–15 минут (первая сборка долгая).
#
# Идемпотентно: если проект уже создан — заново не пересоздаёт, просто запускает.
# Источник: https://docs.flutter.dev/reference/flutter-cli
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

require_macos
ensure_brew_in_path
if ! has_cmd flutter; then
  err "Flutter не найден. Сначала пройди 05-flutter/."
  exit 1
fi

PROJECT_ROOT="$HOME/vibecoding"
APP_DIR="$PROJECT_ROOT/vibecoding_first_app"

step "Шаг 1. Готовое учебное приложение"
mkdir -p "$PROJECT_ROOT"
if [ -f "$APP_DIR/pubspec.yaml" ]; then
  ok "Проект уже создан: $APP_DIR — пропускаю flutter create."
else
  log "Flutter сам создаёт готовый учебный проект (как набор LEGO с инструкцией)."
  ( cd "$PROJECT_ROOT" && flutter create vibecoding_first_app )
  ok "Проект создан: $APP_DIR"
fi

step "Шаг 2. Игрушечный iPhone (симулятор)"
log "Открываю iOS Simulator и жду, пока Flutter его увидит (до ~1,5 минут)."
open -a Simulator || warn "Не удалось открыть Simulator. Убедись, что Xcode установлен (см. 05-flutter/)."

# Без этого ожидания flutter run может не найти iPhone и запустить приложение
# не там (например, окном macOS) или задать новичку вопрос про выбор устройства.
FOUND_IPHONE=0
for _ in $(seq 1 18); do
  if (cd "$APP_DIR" && flutter devices 2>/dev/null | grep -qi 'iphone'); then
    FOUND_IPHONE=1
    break
  fi
  sleep 5
done

step "Шаг 3. Какие устройства видит Flutter"
( cd "$APP_DIR" && flutter devices ) || true

step "Шаг 4. Запуск приложения на симуляторе iPhone"
if [ "$FOUND_IPHONE" -ne 1 ]; then
  err "Симулятор iPhone так и не появился в списке устройств."
  note "1) Посмотри на экран: открылся ли Simulator и виден ли в нём iPhone."
  note "2) Если Simulator пустой: меню File → Open Simulator → iOS → любой iPhone."
  note "3) Потом запусти этот скрипт снова — или вручную:"
  note "   cd $APP_DIR && flutter run -d iPhone"
  exit 1
fi
log "Запускаю приложение именно на симуляторе iPhone. Первая сборка может идти долго — это нормально."
note "Когда приложение откроется — нажми кнопку  +  на экране телефона: число должно расти."
note "Чтобы остановить приложение — нажми  q  в этом окне Терминала."
mark_step "06-first-win:created"
note ""
note "Запускаю flutter run… (управление переходит к Flutter)"
# exec: отдаём окно живому процессу flutter run — на конкретном устройстве.
cd "$APP_DIR"
exec flutter run -d iPhone
