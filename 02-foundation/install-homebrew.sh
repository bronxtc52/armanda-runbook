#!/usr/bin/env bash
# ============================================================================
# install-homebrew.sh — поставить «магазин инструментов» Homebrew.
#
# ЧТО ДЕЛАЕТ:
#   1) убеждается, что есть Command Line Tools от Apple (если нет — просит
#      нажать «Установить» в окне Apple);
#   2) ставит Homebrew официальной командой с brew.sh (если ещё не стоит);
#   3) прописывает Homebrew в «адресную книгу» Терминала (PATH в ~/.zprofile)
#      правильно для твоего чипа — без дублей.
# ЧТО МЕНЯЕТ НА МАШИНЕ: ставит Homebrew в /opt/homebrew (Apple Silicon) или
#   /usr/local (Intel); дописывает 1 строку в ~/.zprofile (если её там нет).
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: да — установщик Homebrew и Apple CLT попросят пароль
#   от Mac. Скрипт предупредит заранее и остановится.
# СКОЛЬКО ВРЕМЕНИ: 3–10 минут (зависит от интернета).
#
# Идемпотентно: повторный запуск ничего не ломает и не дублирует строки.
# Источник команды установки — официальный сайт https://brew.sh
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

require_macos

# --- Шаг 1. Command Line Tools от Apple -------------------------------------
step "Шаг 1. Командные инструменты Apple (коробка с отвёртками)"
if xcode-select -p >/dev/null 2>&1; then
  ok "Command Line Tools уже есть — пропускаю."
else
  log "Нужны командные инструменты Apple. Сейчас откроется маленькое окно Apple с кнопкой «Установить»."
  # Сначала вызываем установщик — и только потом просим человека нажать кнопку.
  # Не падаем, если установка уже идёт/недоступна.
  xcode-select --install >/dev/null 2>&1 || true
  pause_for_human "На экране появилось окно «Установить инструменты командной строки»? Нажми «Установить» и дождись, пока установка ПОЛНОСТЬЮ закончится. Потом вернись сюда и нажми Enter. (Если окно не появилось — инструменты, скорее всего, уже стоят: просто нажми Enter.)"
  # Системе иногда нужно несколько секунд, чтобы «увидеть» свежие инструменты.
  for _ in 1 2 3 4 5 6; do
    xcode-select -p >/dev/null 2>&1 && break
    sleep 5
  done
  if xcode-select -p >/dev/null 2>&1; then
    ok "Command Line Tools на месте."
  else
    warn "Command Line Tools пока не видны. Если установка ещё идёт — дождись окончания и запусти этот скрипт снова."
  fi
fi

# --- Шаг 2. Установка Homebrew ----------------------------------------------
step "Шаг 2. Homebrew — магазин команд для Терминала"
ensure_brew_in_path
if has_cmd brew; then
  ok "Homebrew уже установлен ($(command -v brew)) — установку пропускаю."
else
  log "Ставлю Homebrew — это магазин маленьких программ для твоего Mac. Пара минут."
  warn_password
  pause_for_human "Сейчас запустится официальный установщик Homebrew. Он может спросить Enter и пароль от Mac. Готов продолжить?"
  # Официальная install-строка с https://brew.sh (не из случайных мест).
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ensure_brew_in_path
fi

# --- Шаг 3. Прописать Homebrew в PATH (правильно для чипа) -------------------
step "Шаг 3. Запомнить, где лежит магазин (PATH)"
PREFIX="$(brew_prefix)"
SHELLENV_LINE="eval \"\$(${PREFIX}/bin/brew shellenv)\""
log "Твой чип: $(arch_human). Homebrew живёт в $PREFIX."
append_line_once "$HOME/.zprofile" "$SHELLENV_LINE"
# Применяем в текущей сессии, чтобы проверка ниже сработала сразу.
if [ -x "$PREFIX/bin/brew" ]; then
  eval "$("$PREFIX/bin/brew" shellenv)"
fi

# --- Проверка ---------------------------------------------------------------
step "Проверка"
if has_cmd brew && brew --version >/dev/null 2>&1; then
  ok "Homebrew работает: $(brew --version | head -n1)"
  mark_step "02-foundation:homebrew"
else
  err "Команда brew пока не отвечает в этой сессии."
  note "Закрой Терминал, открой заново и запусти: brew --version"
  note "Если всё ещё не работает — загляни в TROUBLESHOOTING.md (раздел «command not found: brew»)."
  exit 1
fi
