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

helper_check_working_env () {
    if user_is_root
    then
        _log_fatal "DO NOT run this script under root!"
    fi
    _log_debug "Checking user: $(whoami)"

    if ! check_command "docker-compose"
    then 
        _log_fatal "docker-compose is NOT installed!"
    fi
    _log_debug "Checking docker-compose: installed"
}

__is_debug_image_used () {
    __message="Unable to define image: Container not started"
    PTS_DEBUG_IMAGE_USED="${PTS_ERROR}"
    if [ "${PTS_CONTAINER_STARTED}" -eq "${PTS_TRUE}" ]; then
        if docker-compose images | grep -q "${PTS_DEBUG_IMAGE}"
        then
            __message="Debug image is used"
            PTS_DEBUG_IMAGE_USED="${PTS_TRUE}"
        else
            __message="Regular image is used"
            PTS_DEBUG_IMAGE_USED=${PTS_FALSE}
        fi
    fi
    _log_debug "${__message}"
    export PTS_DEBUG_IMAGE_USED
    unset __message
}

__is_container_started () {
    __message="Container NOT started in"
    PTS_CONTAINER_STARTED=${PTS_FALSE}

    if docker-compose images | grep -q -e "$(basename "${WORK_DIR}")" -e "Up"
    then
        __message="Container started in"
        PTS_CONTAINER_STARTED="${PTS_TRUE}"
    fi
    _log_debug "${__message} '${WORK_DIR}'"
    export PTS_CONTAINER_STARTED
    unset __message
}
__check_container () {
    __is_container_started
    __is_debug_image_used
}

_pts_helper_check_container () {        
    _log_debug "Checking container"
    __check_container
    if [ "${PTS_CONTAINER_STARTED}" -eq "${PTS_TRUE}" ]; then
        _log_debug "Container started"
        # if __is_debug_image_used; then
        #     PTS_DEBUG_IMAGE_USED=${PTS_TRUE}
        # fi
    else
        _log_debug "Trying to start container"
        _log_debug "Using debug image by default"
        _pts_helper_start_container "${_DOCKER_COMPOSE_FILE_DEBUG}"
        PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE_DEBUG}"
        __check_container
    fi

    if [ "${PTS_REQUIRE_DEBUG_IMAGE}" -eq "${PTS_TRUE}" ]; then
        _log_debug "Debug image required"
        PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE_DEBUG}"
        if [ "${PTS_DEBUG_IMAGE_USED}" -eq "${PTS_TRUE}" ]; then
            _log_debug "Debug image used"
        else
            _log_debug "Restarting to debug image"
            _pts_helper_restart_container "${_DOCKER_COMPOSE_FILE_DEBUG}"
            __check_container
        fi
    else
        PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE}"
    fi

    export PTS_DOCKER_COMPOSE_FILE
}

_pts_helper_restart_container () {
    docker-compose down && _pts_helper_start_container "${1}"
}

_pts_helper_start_container () {
    _log_debug "Starting container using '${1}'"
    docker-compose -f "${1}" up -d
}
