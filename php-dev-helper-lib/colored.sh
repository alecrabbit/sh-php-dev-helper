#!/usr/bin/env sh
### Define constants
true; COL_TRUE=${CORE_TRUE:-$?}
false; COL_FALSE=${CORE_FALSE:-$?}

### Color Constants
__COL_ANSI_DARK="\033[2m"
__COL_ANSI_BOLD="\033[1m"

__COL_ANSI_NONE="\033[0m"
__COL_ANSI_RED="\033[0;31m"
__COL_ANSI_BOLD_RED="\033[1;31m"
__COL_ANSI_GREEN="\033[0;32m"
__COL_ANSI_BOLD_GREEN="\033[1;32m"
__COL_ANSI_YELLOW="\033[0;33m"
__COL_ANSI_BOLD_YELLOW="\033[1;33m"
__COL_ANSI_CYAN="\033[0;36m"
__COL_ANSI_BOLD_CYAN="\033[1;36m"

### Define
__col_reset_colors () {
    __col_ansi_none=""
    __col_ansi_dark=""
    __col_ansi_red=""
    __col_ansi_green=""
    __col_ansi_yellow=""
    __col_ansi_cyan=""
    __col_ansi_bold=""
    __col_ansi_bold_red=""
    __col_ansi_bold_green=""
    __col_ansi_bold_yellow=""
    __col_ansi_bold_cyan=""
}
__col_set_colors () {
    __col_ansi_none=${__COL_ANSI_NONE}
    __col_ansi_dark=${__COL_ANSI_DARK}
    __col_ansi_red=${__COL_ANSI_RED}
    __col_ansi_green=${__COL_ANSI_GREEN}
    __col_ansi_yellow=${__COL_ANSI_YELLOW}
    __col_ansi_cyan=${__COL_ANSI_CYAN}
    __col_ansi_bold=${__COL_ANSI_BOLD}
    __col_ansi_bold_red=${__COL_ANSI_BOLD_RED}
    __col_ansi_bold_green=${__COL_ANSI_BOLD_GREEN}
    __col_ansi_bold_yellow=${__COL_ANSI_BOLD_YELLOW}
    __col_ansi_bold_cyan=${__COL_ANSI_BOLD_CYAN}
}

colored_bold () {
    echo "${__col_ansi_bold}$*${__col_ansi_none}"
}
colored_dark () {
    echo "${__col_ansi_dark}$*${__col_ansi_none}"
}
colored_red () {
    echo "${__col_ansi_red}$*${__col_ansi_none}"
}
colored_green () {
    echo "${__col_ansi_green}$*${__col_ansi_none}"
}
colored_yellow () {
    echo "${__col_ansi_yellow}$*${__col_ansi_none}"
}
colored_cyan () {
    echo "${__col_ansi_cyan}$*${__col_ansi_none}"
}
colored_bold_red () {
    echo "${__col_ansi_bold_red}$*${__col_ansi_none}"
}
colored_bold_green () {
    echo "${__col_ansi_bold_green}$*${__col_ansi_none}"
}
colored_bold_yellow () {
    echo "${__col_ansi_bold_yellow}$*${__col_ansi_none}"
}
colored_bold_cyan () {
    echo "${__col_ansi_bold_cyan}$*${__col_ansi_none}"
}

_colored_configureColor() {
  __col_color=${COL_FALSE}  # By default, no color.
  __col_reset_colors
  case ${1} in
    'always') __col_color=${COL_TRUE} ;;
    'auto')
      ( exec tput >/dev/null 2>&1 )  # Check for existence of tput command.
      if [ $? -lt 127 ]; then
        __col_tput_=$(tput colors)
        # shellcheck disable=SC2166,SC2181
        [ $? -eq 0 -a "${__col_tput_}" -ge 16 ] && __col_color=${COL_TRUE}
      fi
      ;;
    'never') ;;
    *) console_log_fatal "Unrecognized color option '${1}'" ;;
  esac

  case ${__col_color} in
    ${COL_TRUE})
      __col_set_colors
      ;;
    ${COL_FALSE})
      __col_reset_colors
      ;;
  esac

  unset __col_color __col_tput_
}

_colored_configureColor "${COLOR:-auto}" # Options are 'never', 'always', or 'auto'