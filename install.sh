#!/bin/bash

WT_SETTINGS_PATH="$(realpath "${1:-"${HOME}/wt-settings"}")"
WT_SETTINGS_FONTS_PATH="${WT_SETTINGS_PATH}/AppData/Local/Microsoft/Windows/Fonts"

do_it() {
  if [ -d "${WT_SETTINGS_PATH}" ]; then
    echo "ngmy/wt-settings already exists in '${WT_SETTINGS_PATH}'."
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

  WIN_USERPROFILE="$(cmd.exe /c "<nul set /p=%UserProfile%" 2>/dev/null)"
  WIN_USERPROFILE_DRIVE="${WIN_USERPROFILE%%:*}:\\"
  USERPROFILE_MOUNT="$(findmnt --noheadings --first-only --output TARGET "${WIN_USERPROFILE_DRIVE}")"
  WIN_USERPROFILE_DIR="${WIN_USERPROFILE#*:}"
  USERPROFILE="${USERPROFILE_MOUNT}${WIN_USERPROFILE_DIR//\\//}"

  BACKUP_DATE="$(date +%Y%m%d_%H%M%S)"
  mv -v "${USERPROFILE}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/settings.json" "${USERPROFILE}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/settings.json.${BACKUP_DATE}"
  ln -fnsv "${WT_SETTINGS_PATH}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/settings.json" "${USERPROFILE}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/settings.json"

  read -p 'Do you want to install fonts? (y/N)' YN_FONTS
  if [ "${YN_FONTS}" = 'y' ]; then
    USER_FONTS_PATH="${USERPROFILE}/AppData/Local/Microsoft/Windows/Fonts"
    echo "Installing fonts to '${USER_FONTS_PATH}'..."
    mv -v "${WT_SETTINGS_FONTS_PATH}/RictyDiminished/*.ttf" "${USER_FONTS_PATH}"
  else
    echo 'The installation of fonts was skipped.'
  fi
}

do_it
