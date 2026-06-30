#!/usr/bin/env bash
# ============================================================================
# verify.sh — проверка фазы 05: Flutter, CocoaPods и осмотр flutter doctor.
#
# ЧТО ДЕЛАЕТ: проверяет команды flutter и pod, затем запускает flutter doctor
#   как «медицинскую карту». Красные крестики в докторе — это НЕ провал фазы:
#   главное, что flutter и pod работают и доктор запускается.
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет.   СКОЛЬКО ВРЕМЕНИ: 1–2 минуты (doctor думает).
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

ensure_brew_in_path
fail=0

step "Проверка фазы 05 — Flutter и мобильные цеха"

if has_cmd flutter && flutter --version >/dev/null 2>&1; then
  ok "Flutter: $(flutter --version | head -n1)"
else err "Flutter не установлен."; fail=1; fi

if has_cmd pod && pod --version >/dev/null 2>&1; then
  ok "CocoaPods: $(pod --version)"
else err "CocoaPods не установлен."; fail=1; fi

if [ -d "/Applications/Xcode.app" ]; then ok "Xcode: установлен."; else warn "Xcode не найден — iPhone-симулятор не заработает без него."; fi

step "Медицинская карта: flutter doctor"
if has_cmd flutter; then
  note "Зелёные галочки — хорошо. Красные крестики — это список дел, а не поломка."
  flutter doctor || true
fi

if [ "$fail" -eq 0 ]; then
  ok "Фаза 05 пройдена (flutter и pod работают). Дальше — 06-first-win/."
  note "Если в докторе остались красные пункты — скопируй весь вывод выше и отдай Claude Code/Codex с просьбой объяснить ОДИН следующий безопасный шаг."
  mark_step "05-flutter:verified"
else
  err "Есть незакрытые пункты. Вернись к скриптам фазы 05 или открой TROUBLESHOOTING.md."
  exit 1
fi
