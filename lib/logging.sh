#!/usr/bin/env sh
LOG_NAME=${SCRIPT_NAME:-}
if [ "${LOG_NAME}" != "" ]
then
  LOG_NAME="${LOG_NAME}:"
fi

# shellcheck disable=SC1090
. "${LIB_DIR}/colored.sh"


### Logging functions.

_log_warn () {
  _log_print "⚠️  ${LOG_NAME}$(_color_bold_yellow "WARNING") $*\n" "${PTS_TRUE}" "${PTS_TRUE}"
}
_log_error () {
  _log_print "🛑 ${LOG_NAME}$(_color_bold_red "ERROR") $*\n" "${PTS_TRUE}" "${PTS_TRUE}"
}
_log_fatal () {
  _log_print "🔥 ${LOG_NAME}$(_color_bold_red "FATAL") $*\n" "${PTS_TRUE}" "${PTS_TRUE}"
  exit "${PTS_ERROR}"
}

### Messages functions

# Outputs a message to stderr
#   _log_print "message" 1
# Args:
#   $1 string Message to print.
#   $2 int (Optional)Print new line in the end.
#   $3 int (Optional)Print new line in the begining.
_log_print () {
    if [ "${3:-${PTS_FALSE}}" -eq "${PTS_TRUE}" ]
    then
        __leading_nl="\n"
    else
        __leading_nl=""
    fi
    if [ "${PTS_DEBUG}" -eq 1 ]
    then
        # Debug enabled
        __message="${__leading_nl}$(_color_dark "$(date '+%Y-%m-%d %H:%M:%S') │") ${1}"
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

_log_debug() {
    if [ "${PTS_DEBUG}" -eq 1 ]
    then
        _log_dark "<DEBUG> ${1}"
    fi
}
_log_dark() {
  _log_print "$(_color_dark "$*")"
}
_log_info() {
  _log_print "$(_color_green "$*")"
}
_log_comment() {
  _log_print "$(_color_yellow "$*")"
}
_log_notice() {
  _log_print "$(_color_bold_yellow "$*")"
}
_log_header() {
  _log_print "$(_color_bold_cyan "$*")"
}
