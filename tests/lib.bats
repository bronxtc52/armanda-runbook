#!/usr/bin/env bats
# Юнит-тесты для scripts/lib.sh — идемпотентность и безопасный неинтерактив.
# Имена тестов держим в ASCII: часть версий bats спотыкается на кириллице.

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  # shellcheck disable=SC1091
  source "$REPO_ROOT/scripts/lib.sh"
  TMP="$(mktemp)"
}

teardown() {
  rm -f "$TMP"
}

@test "append_line_once: line added once" {
  append_line_once "$TMP" "export FOO=bar"
  run grep -Fxc "export FOO=bar" "$TMP"
  [ "$output" = "1" ]
}

@test "append_line_once: repeated calls do not duplicate" {
  append_line_once "$TMP" "export FOO=bar"
  append_line_once "$TMP" "export FOO=bar"
  append_line_once "$TMP" "export FOO=bar"
  run grep -Fxc "export FOO=bar" "$TMP"
  [ "$output" = "1" ]
}

@test "append_line_once: distinct lines both land" {
  append_line_once "$TMP" "line A"
  append_line_once "$TMP" "line B"
  run wc -l < "$TMP"
  [ "$(echo "$output" | tr -d ' ')" = "2" ]
}

@test "ask_yes_no: non-interactive input returns no (1)" {
  # stdin не tty → функция должна безопасно вернуть 1, без тихого «да»
  run bash -c "source '$REPO_ROOT/scripts/lib.sh'; ask_yes_no 'proceed?' </dev/null"
  [ "$status" -eq 1 ]
}

@test "_runner_note: emits NOTE marker only under runner" {
  # под раннером (RUNNER_PTY=1) печатает маркер @@RUNNER:NOTE:<текст>@@
  run bash -c "RUNNER_PTY=1; source '$REPO_ROOT/scripts/lib.sh'; _runner_note 'password window'"
  [ "$output" = "@@RUNNER:NOTE:password window@@" ]
}

@test "_runner_note: silent when not under runner" {
  # без RUNNER_PTY обычный человек маркеров не видит
  run bash -c "unset RUNNER_PTY; source '$REPO_ROOT/scripts/lib.sh'; _runner_note 'x'"
  [ -z "$output" ]
}

@test "warn_password: emits NOTE before native dialog under askpass" {
  # под раннером с SUDO_ASKPASS → есть NOTE-веха (тихий sudo больше не тихий)
  run bash -c "RUNNER_PTY=1 SUDO_ASKPASS=/tmp/x; source '$REPO_ROOT/scripts/lib.sh'; warn_password"
  [[ "$output" == *"@@RUNNER:NOTE:"* ]]
}
