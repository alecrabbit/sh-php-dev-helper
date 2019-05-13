#!/usr/bin/env sh
_show_option () {
    __option_name="${2}"
    __option_value="${1:-${PTS_FALSE}}"
    __value="$(_color_dark "--")"
    if [ "${__option_value}" -eq  "${PTS_TRUE}" ]
    then
        __value="$(_color_bold_green "ON")"
    fi
    _log_print "[ ${__value} ] $(_color_bold "${__option_name}")"
    unset __value __option_name __option_value
}

_is_debug_image_used () {
    if ! docker-compose images | grep -q "${PTS_DEBUG_IMAGE}"
    then
        _log_warn "REGULAR IMAGE"
    else
        _log_warn "DEBUG IMAGE"
    fi
}

