#!/usr/bin/env bash
# ============================================================================
# install-android-studio.sh — поставить Android Studio (цех для Android).
#
# ЧТО ДЕЛАЕТ: ставит Android Studio через Homebrew cask. После установки нужно
#   ОДИН РАЗ открыть программу и пройти Setup Wizard (это делает человек), затем
#   принять лицензии Android из Терминала.
# ЧТО МЕНЯЕТ НА МАШИНЕ: добавляет cask android-studio; после Setup Wizard —
#   Android SDK; команда лицензий пишет согласие в SDK.
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет. НО есть GUI-шаг (Setup Wizard) — скрипт остановится.
# СКОЛЬКО ВРЕМЕНИ: 10–30 минут (Android SDK большой).
#
# Идемпотентно. Источник:
#   https://formulae.brew.sh/cask/android-studio
#   https://docs.flutter.dev/get-started/install/macos/mobile-android
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

step "Android Studio — цех для Android-приложений"
if [ -d "/Applications/Android Studio.app" ] || brew_pkg_installed android-studio; then
  ok "Android Studio уже установлена — пропускаю установку."
else
  log "Ставлю Android Studio через Homebrew. Большой пакет, может идти долго."
  brew install --cask android-studio
fi

step "Setup Wizard (нужно открыть программу один раз)"
pause_for_human "Открой «Android Studio» (через Spotlight: Cmd+Пробел → Android Studio). Пройди Setup Wizard со стандартными настройками — он докачает Android SDK, Platform-Tools и эмулятор. Когда мастер закончит и появится стартовый экран — продолжай."

step "Лицензии Android"
if has_cmd flutter; then
  log "Принимаю лицензии Android. На каждый вопрос отвечай  y  (если согласен)."
  note "Если команда напишет, что лицензий нет/уже приняты — это нормально."
  flutter doctor --android-licenses || warn "Часть лицензий не принялась. Можно повторить позже: flutter doctor --android-licenses"
else
  warn "flutter не найден — пропускаю лицензии Android. Сначала установи Flutter (install-flutter.sh), потом запусти: flutter doctor --android-licenses"
fi

step "Проверка"
if [ -d "/Applications/Android Studio.app" ] || brew_pkg_installed android-studio; then
  ok "Android Studio на месте."
  note "Полную картину покажет flutter doctor на следующем шаге."
  mark_step "05-flutter:android"
else
  err "Android Studio не найдена. См. TROUBLESHOOTING.md."
  exit 1
fi
