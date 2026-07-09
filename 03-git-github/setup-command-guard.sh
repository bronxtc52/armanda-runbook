#!/usr/bin/env bash
# ============================================================================
# setup-command-guard.sh — «сторож команд»: страховка от опасных команд агента.
#
# ЧТО ЭТО: второй сторож рядом со сторожем секретов. Тот не пускает ключи в
#   GitHub; этот не даёт ИИ-агенту случайно выполнить разрушительную команду:
#   git push --force, git reset --hard, git clean -f, rm -rf по важным путям,
#   удаление .env, запуск скриптов из интернета через curl | bash.
#   Главный урок за ним: пока работа не отправлена в GitHub (push) — она нигде
#   не сохранена, и такие команды уничтожают её безвозвратно.
#
# ЧТО ДЕЛАЕТ:
#   1) кладёт сторожа в ~/.vibecoding/hooks/command-guard.py и гоняет самотест;
#   2) подключает его к Claude Code (PreToolUse-хук в ~/.claude/settings.json);
#      перед правкой settings.json делает резервную копию.
# ЧТО МЕНЯЕТ НА МАШИНЕ: создаёт ~/.vibecoding/hooks/; правит ~/.claude/settings.json.
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: нет.   СКОЛЬКО ВРЕМЕНИ: секунды.
# ИДЕМПОТЕНТНО: да — повторный запуск обновляет сторожа, дублей не создаёт.
#
# ЧЕСТНАЯ ГРАНИЦА: хук работает для Claude Code. Codex такой механики не имеет —
#   он спрашивает подтверждения своим встроенным режимом одобрения. Обычные
#   команды (status, commit, push, rm -rf node_modules) сторож не трогает.
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

require_macos

step "Сторож команд — страховка от разрушительных команд агента"
note "ИИ-агент старается, но может ошибиться командой. Этот сторож перехватывает"
note "известные опасные команды ДО выполнения — как ограждение у обрыва."

if ! has_cmd python3; then
  err "Нет python3. Сначала пройди фазу 02 (Command Line Tools ставят python3)."
  exit 1
fi

# ----- 1. Положить сторожа и проверить его самотестом ------------------------
GUARD_DIR="$HOME/.vibecoding/hooks"
GUARD="$GUARD_DIR/command-guard.py"
mkdir -p "$GUARD_DIR"
cp "$SCRIPT_DIR/../scripts/command-guard.py" "$GUARD"
chmod +x "$GUARD"

log "Проверяю сторожа самотестом (49 команд: опасные — блок, обычные — проход)…"
if python3 "$GUARD" --selftest >/dev/null; then
  ok "Самотест пройден."
else
  err "Самотест сторожа не прошёл — НЕ подключаю его. Сообщи об этом Claude Code."
  exit 1
fi

# ----- 2. Подключить к Claude Code (PreToolUse-хук) --------------------------
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
mkdir -p "$CLAUDE_DIR"
if [ -f "$SETTINGS" ]; then
  cp "$SETTINGS" "$SETTINGS.backup-command-guard"
  note "Резервная копия настроек: $SETTINGS.backup-command-guard"
fi

GUARD_PATH="$GUARD" SETTINGS_PATH="$SETTINGS" python3 - <<'PY'
import json, os

settings_path = os.environ["SETTINGS_PATH"]
guard_cmd = "python3 " + os.environ["GUARD_PATH"]

cfg = {}
if os.path.exists(settings_path):
    with open(settings_path) as f:
        cfg = json.load(f)

matchers = cfg.setdefault("hooks", {}).setdefault("PreToolUse", [])
already = any(
    "command-guard.py" in h.get("command", "")
    for m in matchers for h in m.get("hooks", [])
)
if not already:
    matchers.append({
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": guard_cmd}],
    })
    with open(settings_path, "w") as f:
        json.dump(cfg, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print("wired")
else:
    print("present")
PY

ok "Сторож команд включён для Claude Code."
note "Codex подключить так нельзя — у него своя встроенная система подтверждений."
note "Если сторож заблокирует нужную команду — это не поломка: см. TROUBLESHOOTING.md."

mark_step "03-git-github:command-guard"
step "Готово — двойная страховка"
note "Сторож секретов бережёт GitHub от ключей, сторож команд — твою работу от"
note "разрушительных команд. Дальше: bash 03-git-github/verify.sh"
