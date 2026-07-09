# INDEX — карта runbook'а и порядок прохождения

Иди строго сверху вниз. Каждую фазу заканчивай её `verify.sh` — и только потом следующая.

> Codex ведёт саму сессию по [`RITUALS.md`](RITUALS.md): что назвать человеку в начале, как продолжить с прошлого раза, когда остановиться и как завершить встречу.

| № | Папка | Что ставим | Заканчивается на | Стоп для человека |
|---|-------|------------|------------------|-------------------|
| 0 | `00-preflight/`   | ничего (осмотр) | карта: чип, macOS, что уже стоит | — |
| 1 | `01-macbook-setup/` | настройка Mac (Finder, сон, клавиатура, безопасность, Dock) | `🎉 MacBook настроен` | пароль Mac (sudo); FileVault — вручную |
| 2 | `02-foundation/`  | Command Line Tools, **Homebrew**, `tree` | `brew --version`, `tree --version` | пароль Mac; окно CLT |
| 3 | `03-git-github/`  | **Git**, **GitHub CLI**, подпись Git, **защита от секретов** | `gh auth status` = вошёл, сторож секретов включён | вход в GitHub (браузер) |
| 4 | `04-ai-helpers/`  | **Node/npm**, **Claude Code**, **Codex** | `claude` и `codex` запускаются | вход в Claude/ChatGPT |
| 5 | `05-flutter/` ⭐ по желанию | **Flutter**, **Xcode**, **Android Studio**, **CocoaPods** | `flutter doctor` выдаёт карту | App Store (Xcode); пароль Mac (sudo); Setup Wizard |
| 6 | `06-first-win/`   | учебное приложение + первый коммит | **счётчик на симуляторе** + push в GitHub | вход в GitHub уже есть |
| 7 | `07-checkpoint/`  | ничего (самопроверка) | 8 из 10 пунктов готовы → Фаза 1 курса (без Flutter — 5 из 6) | — |
| 99 | `99-appendix-backend/` | Python/venv, Railway | **по требованию** (Фаза 2), НЕ сейчас | — |

> ⭐ **Фаза 5 — по желанию.** Flutter/Xcode/Android Studio нужны только для мобильной разработки.
> Перед стартом фазы гид **предлагает** её и честно предупреждает: отказ = пропуск и фазы 6
> «Первая победа» (она целиком на Flutter). Отказ фиксируется кнопкой `05-flutter/skip.sh`,
> после чего маршрут идёт сразу в фазу 7 — чек-поинт сам считает укороченный список (5 из 6).
> Передумал позже — просто запусти скрипты фазы 5: пропуск этому не мешает.

## Порядок команд (шпаргалка)

```bash
# Фаза 0 — проверка машины
bash 00-preflight/check-system.sh

# Фаза 1 — настройка MacBook
bash 01-macbook-setup/setup-mac-defaults.sh
bash 01-macbook-setup/verify.sh
# bash 01-macbook-setup/install-extra-apps.sh   # по желанию, после Homebrew (фаза 2)

# Фаза 2 — фундамент
bash 02-foundation/install-homebrew.sh
bash 02-foundation/install-tree.sh
bash 02-foundation/verify.sh

# Фаза 3 — Git и GitHub
bash 03-git-github/install-git.sh
bash 03-git-github/install-gh.sh
bash 03-git-github/setup-git-identity.sh
bash 03-git-github/setup-secret-guard.sh    # сторож секретов (общий для всех проектов)
bash 03-git-github/verify.sh

# Фаза 4 — ИИ-помощники
bash 04-ai-helpers/install-node.sh
bash 04-ai-helpers/install-claude.sh
bash 04-ai-helpers/install-codex.sh
bash 04-ai-helpers/verify.sh

# Фаза 5 — Flutter и мобильные цеха (ПО ЖЕЛАНИЮ: сначала предложи; отказ ↓)
# bash 05-flutter/skip.sh                    # человек отказался → пропуск 5 и 6, дальше фаза 7
bash 05-flutter/install-flutter.sh
bash 05-flutter/install-xcode-tools.sh
bash 05-flutter/install-android-studio.sh
bash 05-flutter/install-cocoapods.sh
bash 05-flutter/verify.sh

# Фаза 6 — первая победа
bash 06-first-win/create-and-run.sh        # запускает приложение (нажми q, чтобы выйти)
# … затем правка через claude и hot reload (r) — см. 06-first-win/runbook.md …
bash 06-first-win/first-edit-commit.sh
bash 06-first-win/verify.sh

# Фаза 7 — чек-поинт
bash 07-checkpoint/self-check.sh
```

> Все команды запускаются из корня `course-setup-runbook/`. Каждый шаг подробно описан в `runbook.md` своей папки — Codex проговаривает их новичку простым языком.

## Если прервались
Прогресс — в `state/progress.json` (Codex его ведёт) и `state/progress.log` (маркеры от скриптов). Можно вернуться к любой фазе и продолжить: скрипты идемпотентны, повторный запуск безопасен.

Ошибки — в `TROUBLESHOOTING.md`.
