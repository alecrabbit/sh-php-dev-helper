#!/usr/bin/env sh
_SERVICE=${SCRIPT_NAME:-}
if [ "${_SERVICE}" != "" ]
then
    _SERVICE="${_SERVICE}:"
fi

# shellcheck disable=SC1090
. "${MODULES_DIR}/colored.sh"

### Logging functions.

console_log_warn () {
    console_log_print "⚠️  ${_SERVICE}$(colored_bold_yellow "WARNING") $*\n" "${PTS_TRUE}" "${PTS_TRUE}"
}
console_log_error () {
    console_log_print "🛑 ${_SERVICE}$(colored_bold_red "ERROR") $*\n" "${PTS_TRUE}" "${PTS_TRUE}"
}
console_log_fatal () {
    console_log_print "🔥 ${_SERVICE}$(colored_bold_red "FATAL") $*\n" "${PTS_TRUE}" "${PTS_TRUE}"
    exit "${PTS_ERROR}"
}

### Messages functions

# Outputs a message to stderr
#   console_log_print "message" 1
# Args:
#   $1 string Message to print.
#   $2 int (Optional)Print new line in the end.
#   $3 int (Optional)Print new line in the beginning.
console_log_print () {
    if [ "${3:-${PTS_FALSE}}" -eq "${PTS_TRUE}" ]
    then
        __leading_nl="\n"
    else
        __leading_nl=""
    fi
    if [ "${PTS_DEBUG}" -eq 1 ]
    then
        # Debug enabled
        __message="${__leading_nl}$(colored_dark "$(date '+%Y-%m-%d %H:%M:%S') │") ${1}"
    else
        # Debug disabled
        __message="${__leading_nl}${1}"
    fi
    # Echo new line by default
    if [ "${2:-${PTS_TRUE}}" -eq "${PTS_TRUE}" ]; then
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
    if [ "${PTS_DEBUG}" -eq 1 ]
    then
      console_dark "<DEBUG> ${1}"
    fi
}
console_dark () {
    console_log_print "$(colored_dark "$*")"
}
console_info () {
    console_log_print "$(colored_green "$*")"
}
console_log_comment () {
    console_log_print "$(colored_yellow "$*")"
}
console_log_notice () {
    console_log_print "$(colored_bold_yellow "$*")"
}
console_log_header () {
    console_log_print "$(colored_bold_cyan "$*")"
}
