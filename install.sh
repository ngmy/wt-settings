#!/bin/bash
set -Ceuxo pipefail

download() {
  if [ -d "${WT_SETTINGS_PATH}" ]; then
    echo "ngmy/wt-settings already exists in '${WT_SETTINGS_PATH}'."
    local YN
    read -p 'Do you want to re-download ngmy/wt-settings and continue the installation? (y/N)' YN
    if [ "${YN}" != 'y' ]; then
      echo 'The installation was canceled.'
      exit 1
    fi
    echo "Downloading ngmy/wt-settings to '${WT_SETTINGS_PATH}'..."
    git -C "${WT_SETTINGS_PATH}" pull origin master
  else
    echo "Downloading ngmy/wt-settings to '${WT_SETTINGS_PATH}'..."
    git clone https://github.com/ngmy/wt-settings.git "${WT_SETTINGS_PATH}"
  fi
  echo "Downloading fonts to '${WT_SETTINGS_FONTS_PATH}'..."
  git -C "${WT_SETTINGS_PATH}" submodule update --init
}

backup() {
  local BACKUP_DATE="$(date +%Y%m%d_%H%M%S)"
  mv -v "${USER_PROFILE_PATH}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json" "${USER_PROFILE_PATH}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json.${BACKUP_DATE}"
}

install() {
  rsync -hv "${WT_SETTINGS_PATH}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json" "${USER_PROFILE_PATH}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState"
}

install_fonts() {
  local YN
  read -p 'Do you want to install fonts? (y/N)' YN
  if [ "${YN}" = 'y' ]; then
    local USER_FONTS_PATH="${USER_PROFILE_PATH}/AppData/Local/Microsoft/Windows/Fonts"
    echo "Installing fonts to '${USER_FONTS_PATH}'..."
    rsync -hv --include "*/" --include "*.ttf" --exclude "*" "${WT_SETTINGS_FONTS_PATH}/RictyDiminished/" "${USER_FONTS_PATH}"
  else
    echo 'The installation of fonts was skipped.'
  fi
}

main() {
  local WT_SETTINGS_PATH="$(realpath "${1:-"${HOME}/wt-settings"}")"
  local WT_SETTINGS_FONTS_PATH="${WT_SETTINGS_PATH}/AppData/Local/Microsoft/Windows/Fonts"

  local WIN_USER_PROFILE_PATH="$(cmd.exe /c "<nul set /p=%UserProfile%" 2>/dev/null)"
  local WIN_USER_PROFILE_DRIVE="${WIN_USER_PROFILE_PATH%%:*}:"
  local USER_PROFILE_MOUNT_PATH="$(findmnt --noheadings --first-only --output TARGET "${WIN_USER_PROFILE_DRIVE}\\")"
  local WIN_USER_PROFILE_PATH_WITHOUT_DRIVE="${WIN_USER_PROFILE_PATH#*:}"
  local USER_PROFILE_PATH="${USER_PROFILE_MOUNT_PATH}${WIN_USER_PROFILE_PATH_WITHOUT_DRIVE//\\//}"

  download
  backup
  install
  install_fonts
}

main $1
