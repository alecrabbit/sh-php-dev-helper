#!/usr/bin/env sh

# DEPENDS ON:    
# colored.sh

### Define constants
true; CR_TRUE=${CR_TRUE:-$?}
false; CR_FALSE=${CR_FALSE:-$?}

# shellcheck disable=SC1090
. "${CORE_MODULES_DIR}/colored.sh"

_SERVICE=${SCRIPT_NAME:-}
if [ "${_SERVICE}" != "" ]
then
    # _SERVICE="${_SERVICE}:"
    _SERVICE="$(colored_cyan "${_SERVICE}"):"
fi

### Logging functions.

console_warning () {
    console_print "${EMOJI_WARNING:-}${_SERVICE}$(colored_bold_yellow "WARNING") $*\n" "${CR_TRUE}" "${CR_TRUE}"
}
console_error () {
    console_print "${EMOJI_ERROR:-}${_SERVICE}$(colored_red "ERROR") $*\n" "${CR_TRUE}" "${CR_TRUE}"
}
console_fatal () {
    core_set_terminal_title "${TERM_TITLE:-${WORK_DIR}}"
    console_print "${EMOJI_FATAL:-}${_SERVICE}$(colored_bold_bg_red " FATAL ") $*\n" "${CR_TRUE}" "${CR_TRUE}"
    exit "${CR_ERROR}"
}
console_unable () {
    __error="${1:-}"
    if [ ! "${__error}" = "" ];then
        console_error "${__error}"
    fi
    unset __error
    console_fatal "Unable to proceed"
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
#   console_<func> "message"
# Args:
#   $1 string Message to print.

console_debug () {
    if [ "${CR_DEBUG}" -eq 1 ]
    then
      console_dark "<DEBUG> $*"
    fi
}
console_dark () {
    console_print "$(colored_dark "$*")"
}
console_info () {
    console_print "$(colored_green "$*")"
}
console_comment () {
    console_print "$(colored_yellow "$*")"
}
console_notice () {
    console_print "$(colored_bold_yellow "$*")"
}
console_header () {
    console_print "$(colored_bold_cyan "$*")"
}
console_section () {
    console_print "$(colored_bold_blue "$*")"
}

console_show_option () {
    __option_name="${2}"
    __option_value="${1:-${CR_FALSE}}"
    if [ "${CR_EMOJIS}" -eq "${CR_ENABLED}" ];then
        __value="   "
    else 
        __value="[ ]"
    fi
    if [ "${__option_value}" -eq  "${CR_TRUE}" ]
    then
        if [ "${CR_EMOJIS}" -eq "${CR_ENABLED}" ];then
            __value="${EMOJI_CHECK} "
        else 
            __value="[$(colored_bold_green "X")]"
        fi

    fi
    console_print " ${__value} $(colored_bold "${__option_name}")"
    unset __value __option_name __option_value
}

console_show_messages_samples () {
    console_print "Simple print"
    console_debug "Debug string"
    console_dark "Dark string"
    console_info "Info string"
    console_comment "This is a comment"
    console_notice "Notice sample!" 
    console_header "Header sample" 
    console_section "Section sample" 

    console_warning "Warning sample" 
    console_error "Error sample" 
    console_fatal "Fatal message sample" 
}