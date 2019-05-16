#!/usr/bin/env sh
_SERVICE=${SCRIPT_NAME:-}
if [ "${_SERVICE}" != "" ]
then
    _SERVICE="${_SERVICE}:"
fi

# shellcheck disable=SC1090
. "${MODULES_DIR}/colored.sh"

### Logging functions.

console_warning () {
    console_print "⚠️  ${_SERVICE}$(colored_bold_yellow "WARNING") $*\n" "${CR_TRUE}" "${CR_TRUE}"
}
console_error () {
    console_print "🛑 ${_SERVICE}$(colored_bold_red "ERROR") $*\n" "${CR_TRUE}" "${CR_TRUE}"
}
console_fatal () {
    console_print "🔥 ${_SERVICE}$(colored_bold_red "FATAL") $*\n" "${CR_TRUE}" "${CR_TRUE}"
    exit "${CR_ERROR}"
}

### Messages functions

# Outputs a message to stderr
#   console_print "message" 1
# Args:
#   $1 string Message to print.
#   $2 int (Optional)Print new line in the end.
#   $3 int (Optional)Print new line in the beginning.
console_print () {
    if [ "${3:-${CR_FALSE}}" -eq "${CR_TRUE}" ]
    then
        __leading_nl="\n"
    else
        __leading_nl=""
    fi
    if [ "${CR_DEBUG}" -eq 1 ]
    then
        # Debug enabled
        __message="${__leading_nl}$(colored_dark "$(date '+%Y-%m-%d %H:%M:%S') │") ${1}"
    else
        # Debug disabled
        __message="${__leading_nl}${1}"
    fi
    # Echo new line by default
    if [ "${2:-${CR_TRUE}}" -eq "${CR_TRUE}" ]; then
        __message="${__message}\n"
    fi
    # shellcheck disable=SC2059
    printf "${__message}" >&2
    unset __message __leading_nl
}

# Output message
#   _log_<func> "message"
# Args:
#   $1 string Message to print.

console_debug () {
    if [ "${CR_DEBUG}" -eq 1 ]
    then
      console_dark "<DEBUG> ${1}"
    fi
}
console_dark () {
    console_print "$(colored_dark "$*")"
}
console_info () {
    console_print "$(colored_green "$*")"
}
console_log_comment () {
    console_print "$(colored_yellow "$*")"
}
console_log_notice () {
    console_print "$(colored_bold_yellow "$*")"
}
console_log_header () {
    console_print "$(colored_bold_cyan "$*")"
}

console_show_option () {
    __option_name="${2}"
    __option_value="${1:-${CR_FALSE}}"
    __value="$(colored_dark "--")"
    if [ "${__option_value}" -eq  "${CR_TRUE}" ]
    then
        __value="$(colored_bold_green "ON")"
    fi
    console_print " [ ${__value} ] $(colored_bold "${__option_name}")"
    unset __value __option_name __option_value
}
