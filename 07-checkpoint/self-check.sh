#!/usr/bin/env bash
# ============================================================================
# self-check.sh — финальная самопроверка всей Фазы 0.
#
# ЧТО ДЕЛАЕТ: проходит по всему чек-листу готовности к Фазе 1 курса и считает,
#   сколько пунктов выполнено. Ничего не устанавливает.
# ЧТО МЕНЯЕТ НА МАШИНЕ: ничего (только проверка).
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет.   СКОЛЬКО ВРЕМЕНИ: 1–2 минуты (flutter doctor).
#
# По курсу: готов к Фазе 1, если выполнено 8 из 10 пунктов.
# Если человек ОТКАЗАЛСЯ от Flutter (05-flutter/skip.sh) — мобильные пункты
# не считаются: чек-лист укорачивается до 6, порог — 5 из 6.
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

ensure_brew_in_path
APP_DIR="$HOME/vibecoding/vibecoding_first_app"

# Пропущен ли Flutter по выбору человека? Маркер ставит 05-flutter/skip.sh.
# Если Flutter потом всё же поставили — маркер игнорируем и считаем полный список.
flutter_skipped=0
if grep -Fqx "05-flutter:skipped" "$SCRIPT_DIR/../state/progress.log" 2>/dev/null \
   && ! has_cmd flutter; then
  flutter_skipped=1
fi

if [ "$flutter_skipped" = "1" ]; then
  pass=0; total=6; threshold=5
else
  pass=0; total=10; threshold=8
fi

check() { # check "описание" <команда-проверки...>
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    ok "$desc"
    pass=$((pass+1))
  else
    warn "ещё нет — $desc"
  fi
}

step "Чек-поинт Фазы 0 — рабочее место режиссёра"

check "Homebrew работает (brew --version)"        bash -c 'brew --version'
check "Git работает (git --version)"              bash -c 'git --version'
check "Вход в GitHub (gh auth status)"            bash -c 'gh auth status'
check "Node и npm работают"                        bash -c 'node -v && npm -v'
check "Claude Code доступен (claude)"              command -v claude
check "Codex доступен (codex)"                     command -v codex
if [ "$flutter_skipped" = "1" ]; then
  note "Flutter пропущен по твоему выбору — мобильные пункты (4 шт.) не считаются."
else
  check "Flutter доктор запускается (flutter doctor)" bash -c 'flutter doctor'
  check "Учебный проект существует"                  test -f "$APP_DIR/pubspec.yaml"
  check "В проекте есть коммит (весь проект под Git)" bash -c "git -C '$APP_DIR' rev-parse HEAD && [ \"\$(git -C '$APP_DIR' ls-files | wc -l)\" -gt 20 ]"
  check "Проект привязан к GitHub"                    bash -c "git -C '$APP_DIR' remote get-url origin"
fi

step "Итог"
ok "Выполнено: $pass из $total пунктов."
if [ "$pass" -ge "$threshold" ]; then
  ok "🎉 Фаза 0 пройдена! Можно идти в Фазу 1 курса (управление ИИ внутри проекта)."
  mark_step "07-checkpoint:passed"
else
  warn "Готовность ниже порога (нужно $threshold из $total)."
  note "Не перепрыгивай. Вернись к нужной фазе runbook'а и закрой пробел."
  note "Промпт для ИИ: «Вот вывод проверочных команд. Скажи, готов ли я к Фазе 1. Если нет — дай ОДИН самый важный следующий шаг простыми словами.»"
fi

step "Чего мы НЕ делали в Фазе 0 (и это правильно)"
note "Не подключали сервер, базу данных, авторизацию, Firebase, платежи, TestFlight."
note "Это не пробелы — это защита от перегруза. Всё придёт в Фазах 2–4, когда появится нужда."
