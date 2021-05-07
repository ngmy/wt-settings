#!/bin/bash

set -Ceuxo pipefail

download() {
  if [ -d "${wt_settings_path}" ]; then
    echo "ngmy/wt-settings already exists in '${wt_settings_path}'."
    local yn
    read -p 'Do you want to re-download ngmy/wt-settings and continue the installation? (y/N)' yn
    if [ "${yn}" != 'y' ]; then
      echo 'The installation was canceled.'
      exit 1
    fi
    echo "Downloading ngmy/wt-settings to '${wt_settings_path}'..."
    git -C "${wt_settings_path}" pull origin master
  else
    echo "Downloading ngmy/wt-settings to '${wt_settings_path}'..."
    git clone https://github.com/ngmy/wt-settings.git "${wt_settings_path}"
  fi
  echo "Downloading fonts to '${wt_settings_fonts_path}'..."
  git -C "${wt_settings_path}" submodule update --init
}

backup() {
  local -r backup_date="$(date +%Y%m%d_%H%M%S)"
  mv -v "${user_profile_path}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json" "${user_profile_path}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json.${backup_date}"
}

install() {
  rsync -hv "${wt_settings_path}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json" "${user_profile_path}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState"
}

install_fonts() {
  local yn
  read -p 'Do you want to install fonts? (y/N)' yn
  if [ "${yn}" = 'y' ]; then
    powershell.exe -ExecutionPolicy unrestricted ./Install-Fonts.ps1 \
      HackGen*, \
      RictyDiminished*
  else
    echo 'The installation of fonts was skipped.'
  fi
}

main() {
  local -r wt_settings_path="$(realpath "${1:-"${HOME}/wt-settings"}")"
  local -r wt_settings_fonts_path="${wt_settings_path}/AppData/Local/Microsoft/Windows/Fonts"

  local -r win_user_profile_path="$(cmd.exe /c '<nul set /p=%UserProfile%' 2>/dev/null)"
  local -r win_user_profile_drive="${win_user_profile_path%%:*}:"
  local -r user_profile_mount_path="$(findmnt --noheadings --first-only --output TARGET "${win_user_profile_drive}\\")"
  local -r win_user_profile_path_without_drive="${win_user_profile_path#*:}"
  local -r user_profile_path="${user_profile_mount_path}${win_user_profile_path_without_drive//\\//}"

  download
  backup
  install
  install_fonts
}

main "$@"
