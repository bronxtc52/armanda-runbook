# course-setup-runbook

Runbook для установки среды курса **«Вайбкодинг»** на чистом MacBook (Apple Silicon или Intel). Это набор пошаговых инструкций (`runbook.md`) и готовых скриптов-«волшебных кнопок» (`*.sh`), по которым агент **Codex** проводит **абсолютного новичка** от пустого Mac до рабочей среды и **первой видимой победы** — запущенного приложения и первого коммита в GitHub.

## Для кого это
- **Новичок** — взрослый человек, никогда не писавший код. Он не читает эти файлы напрямую: с ним работает Codex, проговаривая всё простым языком.
- **Codex** — агент в Терминале. Его инструкция — [`FOR-CODEX.md`](FOR-CODEX.md). Он идёт по [`INDEX.md`](INDEX.md), запускает скрипты, останавливается перед паролями/входами, ведёт прогресс.
- **Ты (владелец курса)** — забираешь эту папку и отдаёшь её Codex.

## Что делается
Сначала **настройка самого MacBook** (Finder, режим сна, клавиатура, безопасность, Dock — материал «настройка MacBook»), затем установка стека курса (взят из реальных уроков Фазы 0):
Homebrew · `tree` · Git · GitHub CLI (`gh`) · Node/npm · **Claude Code** · **Codex** · Flutter · Xcode · Android Studio · CocoaPods · iOS Simulator → готовое приложение + первый коммит/push.

> Дополнительные инструменты Фазы 2 (Python/venv, Railway) — в [`99-appendix-backend/`](99-appendix-backend/), **по требованию**, не в первом маршруте.

## Как этим пользуется Codex
1. Читает [`FOR-CODEX.md`](FOR-CODEX.md).
2. Запускает `00-preflight/check-system.sh` — осмотр машины.
3. Идёт по [`INDEX.md`](INDEX.md) фаза за фазой: `runbook.md` → скрипты → `verify.sh`.
4. Ведёт прогресс в `state/progress.json`. Ошибки — по [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md).
5. Финал — `07-checkpoint/self-check.sh` (8 из 10 → среда готова).

## Структура
```
course-setup-runbook/
  README.md · FOR-CODEX.md · RITUALS.md · INDEX.md · TROUBLESHOOTING.md
  scripts/lib.sh                  # общие функции (лог, проверки, идемпотентность, детект чипа)
  03-git-github/setup-secret-guard.sh  # сторож секретов (gitleaks + глобальный pre-commit)
  state/progress-template.json    # шаблон прогресса (Codex копирует в progress.json)
  00-preflight/                   # осмотр машины (read-only)
  01-macbook-setup/               # настройка Mac: Finder, сон, клавиатура, безопасность, Dock
  02-foundation/                  # Homebrew + tree
  03-git-github/                  # Git + GitHub
  04-ai-helpers/                  # Node + Claude Code + Codex
  05-flutter/                     # Flutter + Xcode + Android Studio + CocoaPods
  06-first-win/                   # готовое приложение + первый коммит  ← видимая победа
  07-checkpoint/                  # самопроверка Фазы 0
  99-appendix-backend/            # Python/venv + Railway (по требованию)
```

## Принципы скриптов
- `set -euo pipefail`; **идемпотентность** (повторный запуск безопасен, без дублей в `~/.zprofile`);
- **детект чипа** (`uname -m`) → правильный префикс Homebrew (`/opt/homebrew` vs `/usr/local`);
- **никаких** `rm -rf`, скрытого `sudo`, хардкод-секретов;
- перед паролем / GUI / входом в аккаунт скрипт **останавливается и предупреждает**;
- после установки — **реальная проверка** (`--version`, тестовый запуск), а не предположение;
- весь вывод — **по-русски, на «ты», без жаргона**.

## Запуск (вручную, для проверки)
Все команды — из этой папки. Полная шпаргалка в [`INDEX.md`](INDEX.md):
```bash
bash 00-preflight/check-system.sh
bash 02-foundation/install-homebrew.sh
# … далее по INDEX.md …
```

## Источник истины
Стек и порядок шагов взяты из материалов курса (`Курс_Вайбкодинг/`, Фаза 0, уроки 0.1–0.8; аппендикс — уроки 2.2 и 2.7). Команды — дословно из уроков, со ссылками на официальные источники внутри самих уроков.
