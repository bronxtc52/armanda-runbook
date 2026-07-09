#!/usr/bin/env bash
# ============================================================================
# create-site.sh — создать первый учебный сайт и открыть его на экране.
#
# ЧТО ДЕЛАЕТ:
#   1) создаёт папку ~/vibecoding/vibecoding_first_site с готовым сайтом
#      (одна страница: заголовок + кнопка-счётчик — как в мобильной «победе»);
#   2) кладёт в проект AGENTS.md — правила для ИИ-агента (ритм commit → push →
#      deploy, стоп перед публикацией) из templates/project-AGENTS.md;
#   3) открывает сайт в браузере — первая ВИДИМАЯ победа, пока локальная.
# ЧТО МЕНЯЕТ НА МАШИНЕ: создаёт папку с файлами. В интернет НИЧЕГО не уходит.
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет.   СКОЛЬКО ВРЕМЕНИ: меньше минуты.
#
# Идемпотентно: существующие файлы не перезаписывает (правки не потеряются).
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

require_macos
SITE_DIR="$HOME/vibecoding/vibecoding_first_site"

step "Шаг 1. Создать папку первого сайта"
mkdir -p "$SITE_DIR"
ok "Папка на месте: $SITE_DIR"

step "Шаг 2. Положить страницу сайта"
if [ -f "$SITE_DIR/index.html" ]; then
  ok "index.html уже есть — не трогаю (твои правки целы)."
else
  cat > "$SITE_DIR/index.html" <<'HTML'
<!doctype html>
<html lang="ru">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Мой первый сайт</title>
  <style>
    body { font-family: -apple-system, "Segoe UI", sans-serif; display: flex;
           min-height: 100vh; margin: 0; align-items: center; justify-content: center;
           background: #f5f6fa; color: #222; }
    main { text-align: center; padding: 2rem; }
    h1 { font-size: 2rem; margin-bottom: .5rem; }
    p  { color: #555; }
    button { font-size: 1.5rem; padding: .5rem 1.5rem; border: none; border-radius: .75rem;
             background: #2563eb; color: #fff; cursor: pointer; }
    button:active { transform: scale(.97); }
    #count { font-size: 3rem; margin: 1rem 0; }
  </style>
</head>
<body>
  <main>
    <h1>Мой первый сайт</h1>
    <p>Ты нажал на кнопку столько раз:</p>
    <div id="count">0</div>
    <button onclick="document.getElementById('count').textContent = ++n">+</button>
    <script>let n = 0;</script>
  </main>
</body>
</html>
HTML
  ok "Страница создана: index.html (заголовок + кнопка-счётчик)."
fi

step "Шаг 3. Положить правила для ИИ-агента (AGENTS.md)"
if [ -f "$SITE_DIR/AGENTS.md" ]; then
  ok "AGENTS.md уже есть — не трогаю."
else
  cp "$SCRIPT_DIR/../templates/project-AGENTS.md" "$SITE_DIR/AGENTS.md"
  ok "AGENTS.md на месте: теперь любой ИИ-агент в этой папке знает правила —"
  note "коммитить перед деплоем, публиковать только с твоего «да», беречь секреты."
fi

step "Шаг 4. Открыть сайт на экране"
log "Открываю страницу в твоём браузере…"
open "$SITE_DIR/index.html"
ok "🎉 Первая видимая победа: это НАСТОЯЩИЙ сайт, пока живёт только на твоём Mac."
note "Понажимай кнопку «+» — счётчик работает. Дальше опубликуем его в интернете."

mark_step "06w-first-site:created"
ok "Дальше — правка руками ИИ (см. runbook.md, Шаг 2), потом: bash 06w-first-site/publish-site.sh"
