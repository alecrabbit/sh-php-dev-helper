#!/usr/bin/env sh
__show_option () {
    __option_name="${2}"
    __option_value="${1:-${PTS_FALSE}}"
    __value="$(_color_dark "--")"
    if [ "${__option_value}" -eq  "${PTS_TRUE}" ]
    then
        __value="$(_color_bold_green "ON")"
    fi
    _log_print "[ ${__value} ] $(_color_bold "${__option_name}")"
}