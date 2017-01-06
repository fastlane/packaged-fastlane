#!/bin/bash

FASTLANE_DIR=~/.fastlane/bin
FASTLANE_DIR_RAW="\$HOME/.fastlane/bin" # used to add to the user's profile if necessary
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set_color() {
  local color=$1
  local color_val=1
  case $color in
    black ) color_val=0 ;;
    red ) color_val=1 ;;
    green ) color_val=2 ;;
    yellow ) color_val=3 ;;
    blue ) color_val=4 ;;
    magenta ) color_val=5 ;;
    cyan ) color_val=6 ;;
    white ) color_val=7 ;;
    * ) color_val=0;;
  esac

  tput setaf $color_val
}

echoc() {
  local message=$1
  local color=$2
  set_color $color
  echo $message
  reset_color
}

reset_color() {
  tput sgr0
}

# Detect shell environment
shell=$(basename $(echo $SHELL))
case "$shell" in
  bash )
    if [ -f "${HOME}/.bashrc" ] && [ ! -f "${HOME}/.bash_profile" ]; then
      profile='~/.bashrc'
    else
      profile='~/.bash_profile'
    fi
    ;;
  zsh )
    profile='~/.zshrc'
    ;;
  fish )
    profile='~/.config/fish/config.fish'
    ;;
  * )
    profile="unknown"
    ;;
esac

profile_expanded="$(eval echo $profile)"
