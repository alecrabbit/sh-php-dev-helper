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
    if [ "${PTS_CONTAINER_STARTED}" -eq "${PTS_TRUE}" ]
    then

        if ! docker-compose images | grep -q "${PTS_DEBUG_IMAGE}"
        then
            _log_debug "REGULAR IMAGE USED"
            return "${PTS_FALSE}"
        else
            _log_debug "DEBUG IMAGE USED"
            return "${PTS_TRUE}"
        fi   
    fi
}

_is_container_started () {
    if docker-compose images | grep -q "$(basename "${WORK_DIR}")"
    then
        _log_debug "Container started in '${WORK_DIR}'"
        return "${PTS_TRUE}"
    fi
    _log_debug "Container NOT Started in '${WORK_DIR}'"
    return "${PTS_FALSE}"
}

