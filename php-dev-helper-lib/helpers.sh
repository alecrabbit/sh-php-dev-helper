#!/usr/bin/env sh
__is_debug_image_used () {
    __message="unable to define image(container not running)"
    PTS_DEBUG_IMAGE_USED="${CR_ERROR}"
    if [ "${PTS_CONTAINER_STARTED}" -eq "${CR_TRUE}" ]; then
        if docker-compose images | grep -q "${PTS_DEBUG_IMAGE}"
        then
            __message="Debug"
            PTS_DEBUG_IMAGE_USED="${CR_TRUE}"
        else
            __message="Regular"
            PTS_DEBUG_IMAGE_USED=${CR_FALSE}
        fi
    fi
    console_debug "Image used: ${__message}"
    export PTS_DEBUG_IMAGE_USED
    unset __message
}

__check_container () {
    PTS_DEBUG_IMAGE_USED="${CR_ERROR}"
    PTS_CONTAINER_STARTED="${CR_FALSE}"
    if docker_compose_is_container_started "${WORK_DIR}"
    then
        PTS_CONTAINER_STARTED="${CR_TRUE}"
        console_debug "Container is running"
        if docker_compose_is_debug_image_used "${WORK_DIR}"
        then
            __message="Debug"
            PTS_DEBUG_IMAGE_USED="${CR_TRUE}"
        else
            __message="Regular"
            PTS_DEBUG_IMAGE_USED=${CR_FALSE}
        fi
    else
        console_debug "Container is NOT running"
    fi
    console_debug "Image used: ${__message:-unable to define image(container not running)}"
    export PTS_CONTAINER_STARTED
    export PTS_DEBUG_IMAGE_USED
}

_pts_helper_check_container () {        
    console_debug "Checking container"
    __check_container "${WORK_DIR}"
    if [ "${PTS_CONTAINER_STARTED}" -eq "${CR_TRUE}" ]; then
        console_debug "Container is running"
    else
        console_comment "Container is not running"
        console_info "Trying to start container"
        console_debug "Using debug image by default"
        _pts_helper_start_container "${_DOCKER_COMPOSE_FILE_DEBUG}"
        PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE_DEBUG}"
        __check_container
    fi

    if [ "${PTS_REQUIRE_DEBUG_IMAGE}" -eq "${CR_TRUE}" ]; then
        console_debug "Debug image required, need to restart container?"
        PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE_DEBUG}"
        if [ "${PTS_DEBUG_IMAGE_USED}" -eq "${CR_TRUE}" ]; then
            console_debug "No restart needed: debug image used"
        else
            console_info "Debug image required - restarting..."
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
