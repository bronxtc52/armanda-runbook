#!/usr/bin/env bash
# ============================================================================
# lib.sh — общие функции для всех «волшебных кнопок» runbook'а.
#
# ЧТО ЭТО: библиотека помощников (лог, проверки, идемпотентность, детект чипа).
# ЧТО МЕНЯЕТ НА МАШИНЕ: ничего сам по себе. Это только набор функций.
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет.
# СКОЛЬКО ВРЕМЕНИ: мгновенно (подключается, не выполняется отдельно).
#
# КАК ПОДКЛЮЧАТЬ в начале каждого скрипта:
#   set -euo pipefail
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   source "$SCRIPT_DIR/../scripts/lib.sh"
# ============================================================================

# ----- Лог простым языком, в стиле курса (эмодзи) ---------------------------
log()   { printf '\n👉 %s\n' "$*"; }            # перед действием: что сейчас будет
ok()    { printf '✅ %s\n' "$*"; }              # получилось
warn()  { printf '⚠️  %s\n' "$*"; }             # внимание, но не ошибка
err()   { printf '❌ %s\n' "$*" >&2; }          # ошибка (в stderr)
note()  { printf '   %s\n' "$*"; }              # пояснение/подсказка
step()  { printf '\n— — — — —  %s  — — — — —\n' "$*"; }  # заголовок шага

# ----- Базовые проверки -----------------------------------------------------

# has_cmd <команда> — доступна ли команда в Терминале. Вернёт 0, если да.
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# require_macos — мягко убедиться, что мы на Mac. Иначе остановиться.
require_macos() {
  if [ "$(uname -s)" != "Darwin" ]; then
    err "Этот runbook рассчитан на macOS. Сейчас система: $(uname -s)."
    exit 1
  fi
}

# ----- Детект железа (Apple Silicon vs Intel) -------------------------------

# detect_arch — печатает 'arm64' (Apple Silicon) или 'x86_64' (Intel).
detect_arch() { uname -m; }

# brew_prefix — печатает правильную «полку» Homebrew по чипу.
#   Apple Silicon → /opt/homebrew     Intel → /usr/local
brew_prefix() {
  case "$(uname -m)" in
    arm64) printf '/opt/homebrew' ;;
    *)     printf '/usr/local' ;;
  esac
}

# arch_human — человеческое имя чипа для сообщений новичку.
arch_human() {
  case "$(uname -m)" in
    arm64) printf 'Apple Silicon (M1/M2/M3/M4)' ;;
    *)     printf 'Intel' ;;
  esac
}

# ----- Homebrew в текущей сессии --------------------------------------------

# ensure_brew_in_path — если Homebrew установлен, но команда `brew` ещё не
# видна в этой сессии Терминала — подцепить её через brew shellenv.
ensure_brew_in_path() {
  if has_cmd brew; then return 0; fi
  local pfx; pfx="$(brew_prefix)"
  if [ -x "$pfx/bin/brew" ]; then
    eval "$("$pfx/bin/brew" shellenv)"
  fi
}

# brew_pkg_installed <имя> — установлена ли формула ИЛИ каск с таким именем.
brew_pkg_installed() {
  brew list --formula "$1" >/dev/null 2>&1 || brew list --cask "$1" >/dev/null 2>&1
}

# ----- Идемпотентная правка профиля -----------------------------------------

# append_line_once <файл> <строка> — дописать строку в файл ТОЛЬКО если её там
# ещё нет. Защита от дублей в ~/.zprofile / ~/.zshrc.
append_line_once() {
  local file="$1" line="$2"
  [ -f "$file" ] || touch "$file"
  if grep -Fqx "$line" "$file" 2>/dev/null; then
    ok "Уже прописано в $(basename "$file") — не дублирую."
  else
    printf '%s\n' "$line" >> "$file"
    ok "Добавил строку в $(basename "$file")."
  fi
}

# ----- Взаимодействие с человеком -------------------------------------------

# ask_yes_no "вопрос" — вернуть 0 на «да». Если ввода нет (не-интерактивно),
# безопасно считаем «нет» и предупреждаем — никаких тихих авто-«да».
ask_yes_no() {
  local prompt="$1" reply
  if [ ! -t 0 ]; then
    warn "Нет интерактивного ввода — считаю ответ «нет»: $prompt"
    return 1
  fi
  printf '❓ %s [y/N] ' "$prompt"
  read -r reply
  case "$reply" in [yYдД]*) return 0 ;; *) return 1 ;; esac
}

# pause_for_human "что сделать" — ОСТАНОВКА перед паролем / GUI-окном / входом
# в аккаунт. Скрипт не делает это за человека — он ждёт.
pause_for_human() {
  printf '\n'
  warn "СЕЙЧАС НУЖНО ДЕЙСТВИЕ ЧЕЛОВЕКА (скрипт не делает это сам):"
  printf '   %s\n' "$1"
  if [ -t 0 ]; then
    printf '   Когда сделаешь — нажми Enter, чтобы продолжить… '
    read -r _
  else
    warn "Неинтерактивный режим — пропускаю ожидание, но этот шаг требует человека."
  fi
}

# warn_password — предупредить, что Mac сейчас попросит пароль.
warn_password() {
  warn "Сейчас Mac может попросить пароль от компьютера."
  note "Когда печатаешь пароль в Терминале — символы НЕ видны. Это нормально."
  note "Введи пароль и нажми Enter."
}

# ----- Прогресс (best-effort, без сторонних зависимостей) -------------------

# mark_step "<id-шага>" — отметить шаг как сделанный.
# Пишем простую строку-маркер в state/progress.log. Полный JSON ведёт Codex
# по FOR-CODEX.md; этот маркер — подстраховка и след для человека.
mark_step() {
  local runbook_root state_dir
  runbook_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  state_dir="$runbook_root/state"
  [ -d "$state_dir" ] || mkdir -p "$state_dir"
  # без дублей
  if ! grep -Fqx "$1" "$state_dir/progress.log" 2>/dev/null; then
    printf '%s\n' "$1" >> "$state_dir/progress.log"
  fi
}
