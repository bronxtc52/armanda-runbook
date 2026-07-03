#!/usr/bin/env bats
# Юнит-тесты секрет-регекса из 06-first-win/first-edit-commit.sh.
# Регекс НЕ дублируем — извлекаем прямо из скрипта, чтобы не было дрейфа.
# Имена тестов держим в ASCII: часть версий bats спотыкается на кириллице.

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  SRC="$REPO_ROOT/06-first-win/first-edit-commit.sh"
  # Достаём значение SECRET_FILE_RE='...' из скрипта (одна строка).
  SECRET_FILE_RE="$(sed -n "s/^SECRET_FILE_RE='\(.*\)'$/\1/p" "$SRC")"
  [ -n "$SECRET_FILE_RE" ] || {
    echo "не удалось извлечь SECRET_FILE_RE из $SRC" >&2
    return 1
  }
}

# Возвращает 0, если путь ловится регексом (значит блокируется как секрет).
caught() { printf '%s\n' "$1" | grep -qE "$SECRET_FILE_RE"; }

# --- 6 позитивных: должны ловиться ---
@test "secret: root .env" { caught ".env"; }
@test "secret: nested .env.local" { caught "app/config/.env.local"; }
@test "secret: private key id_rsa" { caught "id_rsa"; }
@test "secret: certificate .pem" { caught "certs/server.pem"; }
@test "secret: key bundle .p12" { caught "ios/dist.p12"; }
@test "secret: android keystore" { caught "android/app/release.keystore"; }

# --- 3 негативных: НЕ должны ловиться ---
@test "clean: README.md" { ! caught "README.md"; }
@test "clean: lib/main.dart" { ! caught "lib/main.dart"; }
@test "clean: environment.dart (not .env)" { ! caught "lib/config/environment.dart"; }
