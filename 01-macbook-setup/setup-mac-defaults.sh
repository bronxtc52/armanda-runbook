#!/usr/bin/env bash
# ============================================================================
# setup-mac-defaults.sh — настройка нового MacBook под вайбкодинг.
#
# ЧТО ДЕЛАЕТ: настраивает систему так, чтобы новичку было удобно и безопасно:
#   • Finder: показывает скрытые файлы (.env, .git), полный путь, все расширения;
#   • режим сна: Mac не засыпает при работе от сети (долгие задачи ИИ не рвутся);
#   • клавиатура/трекпад: быстрый отклик, отключена автозамена кавычек (ломает код);
#   • безопасность: пароль сразу после сна, файрвол, stealth-режим;
#   • Dock: автоскрытие, иконки поменьше, без «недавних»;
#   • скриншоты: в ~/Pictures/Screenshots в формате JPG.
# ЧТО МЕНЯЕТ НА МАШИНЕ: пользовательские настройки (`defaults write`), параметры
#   сна (`pmset`, через sudo) и файрвол (через sudo). Файлы/данные не удаляет.
# НУЖЕН ЛИ ПАРОЛЬ/SUDO: ДА — для режима сна и файрвола. Скрипт предупредит и
#   остановится перед вводом пароля. Никакого скрытого sudo.
# СКОЛЬКО ВРЕМЕНИ: 1–2 минуты.
#
# Идемпотентно: `defaults write` просто перезаписывает значение тем же — повтор
#   безопасен. Откат настроек Finder описан в TROUBLESHOOTING.md.
# Источники: macos-defaults.com, Apple Community, гайды для разработчиков 2025–2026.
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

require_macos

# --- Блок 1. Finder ---------------------------------------------------------
step "Блок 1/6. Finder — показать то, что нужно разработчику"
log "Включаю скрытые файлы (.env, .git), полный путь, все расширения, строку пути."
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
chflags nohidden "$HOME/Library" 2>/dev/null || true
ok "Finder настроен."

# --- Блок 2. Клавиатура и трекпад -------------------------------------------
step "Блок 2/6. Клавиатура и трекпад — быстрый отклик, без автозамены"
log "Ускоряю повтор клавиш и отключаю автозамену кавычек/тире (она ломает код)."
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
ok "Клавиатура и трекпад настроены."

# --- Блок 3. Dock и скриншоты -----------------------------------------------
step "Блок 3/6. Dock и скриншоты — больше места под код"
log "Автоскрытие Dock, иконки поменьше; скриншоты — в отдельную папку, в JPG."
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-time-modifier -float 0.4
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock show-recents -bool false
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture type -string "jpg"
defaults write com.apple.screencapture disable-shadow -bool true
ok "Dock и скриншоты настроены."

# --- Блок 4. Пароль после сна (без sudo) ------------------------------------
step "Блок 4/6. Запрашивать пароль сразу после сна"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
ok "Готово."

# --- Блок 5. Сон и файрвол (нужен sudo) -------------------------------------
step "Блок 5/6. Режим сна и файрвол (нужны права администратора)"
log "Чтобы долгие задачи ИИ не прерывались и Mac был защищён, настрою сон и файрвол."
warn_password
pause_for_human "Сейчас понадобится пароль от Mac (sudo) для настройки сна и файрвола. Готов?"
# Сон: от сети не засыпать 30 мин (дисплей 15), от батареи экономнее.
run_sudo pmset -c sleep 30 displaysleep 15 disksleep 0 || warn "Не удалось задать pmset -c (можно пропустить)."
run_sudo pmset -b sleep 10 displaysleep 5            || warn "Не удалось задать pmset -b (можно пропустить)."
run_sudo pmset -a autorestart 1                      || true
# Файрвол + stealth.
run_sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on  >/dev/null 2>&1 || warn "Файрвол: пропущено."
run_sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on  >/dev/null 2>&1 || true
ok "Сон и файрвол настроены."
note "Совет на каждый день: для долгой задачи запусти  caffeinate -i -t 7200  — Mac не уснёт 2 часа."

# --- Блок 6. Применить изменения --------------------------------------------
step "Блок 6/6. Применяю изменения"
log "Перезапускаю Finder и Dock, чтобы настройки подхватились (окна на миг моргнут)."
for app in Finder Dock SystemUIServer; do killall "$app" >/dev/null 2>&1 || true; done

step "Готово"
ok "🎉 MacBook настроен под вайбкодинг."
note "Осталось включить вручную (скрипт намеренно этого не делает) — см. runbook.md:"
note "  • FileVault (шифрование диска);"
note "  • Touch ID для sudo (вход по отпечатку в Терминале)."
note "Дальше — установка инструментов: переходи в 02-foundation/."
mark_step "01-macbook-setup:defaults"
