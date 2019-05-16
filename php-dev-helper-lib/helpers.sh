#!/usr/bin/env sh
_show_option () {
    __option_name="${2}"
    __option_value="${1:-${PTS_FALSE}}"
    __value="$(colored_dark "--")"
    if [ "${__option_value}" -eq  "${PTS_TRUE}" ]
    then
        __value="$(colored_bold_green "ON")"
    fi
    console_print " [ ${__value} ] $(colored_bold "${__option_name}")"
    unset __value __option_name __option_value
}

helper_check_working_env () {
    if user_is_root
    then
        console_fatal "DO NOT run this script under root!"
    fi
    console_debug "Checking user: $(whoami)"

    if ! check_command "docker-compose"
    then 
        console_fatal "docker-compose is NOT installed!"
    fi
    console_debug "Checking docker-compose: installed"
    if ! core_is_dir_contains "${WORK_DIR}" "${_DOCKER_COMPOSE_FILE} ${_DOCKER_COMPOSE_FILE_DEBUG}"
    then
        console_fatal "docker-compose file(s) not found"
    fi
}

__is_debug_image_used () {
    __message="unable to define image(container not running)"
    PTS_DEBUG_IMAGE_USED="${PTS_ERROR}"
    if [ "${PTS_CONTAINER_STARTED}" -eq "${PTS_TRUE}" ]; then
        if docker-compose images | grep -q "${PTS_DEBUG_IMAGE}"
        then
            __message="Debug"
            PTS_DEBUG_IMAGE_USED="${PTS_TRUE}"
        else
            __message="Regular"
            PTS_DEBUG_IMAGE_USED=${PTS_FALSE}
        fi
    fi
    console_debug "Image used: ${__message}"
    export PTS_DEBUG_IMAGE_USED
    unset __message
}

docker_compose_is_container_started () {
    __work_dir="${1}"
    __name="$(basename "${__work_dir}")"
    __result="$(cd "${__work_dir}" && docker-compose ps | grep -e "${__name}" -e "Up")"
    if [ "${__result}" != "" ]
    then
        return "${PTS_TRUE}"
    fi
    unset __work_dir __result __name
    return "${PTS_FALSE}"
}

__check_container () {
    if docker_compose_is_container_started "${WORK_DIR}"
    then
        PTS_CONTAINER_STARTED="${PTS_TRUE}"
        console_debug "Container is running"
    else
        PTS_CONTAINER_STARTED="${PTS_FALSE}"
        console_debug "Container is NOT running"
    fi
    export PTS_CONTAINER_STARTED
    __is_debug_image_used
}

_pts_helper_check_container () {        
    console_debug "Checking container"
    __check_container "${WORK_DIR}"
    if [ "${PTS_CONTAINER_STARTED}" -eq "${PTS_TRUE}" ]; then
        console_debug "Container is running"
        # if __is_debug_image_used; then
        #     PTS_DEBUG_IMAGE_USED=${PTS_TRUE}
        # fi
    else
        console_debug "Trying to start container"
        console_debug "Using debug image by default"
        _pts_helper_start_container "${_DOCKER_COMPOSE_FILE_DEBUG}"
        PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE_DEBUG}"
        __check_container
    fi

    if [ "${PTS_REQUIRE_DEBUG_IMAGE}" -eq "${PTS_TRUE}" ]; then
        console_debug "Debug image required, need to restart container?"
        PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE_DEBUG}"
        if [ "${PTS_DEBUG_IMAGE_USED}" -eq "${PTS_TRUE}" ]; then
            console_debug "No restart needed: debug image used"
        else
            console_debug "Restarting to debug image"
            _pts_helper_restart_container "${_DOCKER_COMPOSE_FILE_DEBUG}"
            __check_container
        fi
    else
        PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE}"
    fi

    export PTS_DOCKER_COMPOSE_FILE
}

_pts_helper_restart_container () {
    console_debug "Container: Restarting"
    console_debug "Container: Stopping"
    if docker-compose down 
    then
        console_debug "Container successfully stopped"
    else
        console_fatal "Unable to stop container"
    fi
    _pts_helper_start_container "${1}"
}

_pts_helper_start_container () {
    console_debug "Starting container using '${1}'"
    if docker-compose -f "${1}" up -d
    then
        console_debug "Container successfully started"
    else
        console_fatal "Unable to start container"
    fi
}
