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

_check_working_env () {
    _pts_check_user
    if ! _pts_check_command "docker-compose"
    then 
        _log_fatal "docker-compose is NOT installed!"
    fi
}

_is_debug_image_used () {
    if ! docker-compose images | grep -q "${PTS_DEBUG_IMAGE}"
    then
        _log_debug "REGULAR IMAGE USED"
        return "${PTS_FALSE}"
    else
        _log_debug "DEBUG IMAGE USED"
        return "${PTS_TRUE}"
    fi   
}

_is_container_started () {
    if docker-compose images | grep -q -e "$(basename "${WORK_DIR}")" -e "Up"
    then
        _log_debug "Container started in '${WORK_DIR}'"
        return "${PTS_TRUE}"
    fi
    _log_debug "Container NOT Started in '${WORK_DIR}'"
    return "${PTS_FALSE}"
}

