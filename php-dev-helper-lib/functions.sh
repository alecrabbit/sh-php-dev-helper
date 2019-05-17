#!/usr/bin/env sh
PROJECT_NAME="$(basename "${WORK_DIR}")"

_pts_check_working_env () {
    console_debug "Working directory: ${WORK_DIR}"
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
        console_notice "\nAre you in the right directory?"
        console_fatal "docker-compose*.yml file(s) not found in current directory"
    fi
    __allowed_file="${HOME}/${PTS_ALLOWED_DIRS_FILE}"
     __disallowed_file="${HOME}/${PTS_DISALLOWED_DIRS_FILE}"
    __check_file_create_if_not_found "${__allowed_file}"
    __check_file_create_if_not_found "${__disallowed_file}"

    __project_allowed="$(__file_contains_string "${__allowed_file}" "${WORK_DIR}" && echo "${CR_TRUE}" || echo "${CR_FALSE}")"
    __project_disallowed="$(__file_contains_string "${__disallowed_file}" "${WORK_DIR}" && echo "${CR_TRUE}" || echo "${CR_FALSE}")"

    __result="$(echo "${PROJECT_NAME}" | grep -i "${WORKING_PREFIX}")"
    if [ "${__result}" != "" ]; then
        console_debug "Your project name contains '${WORKING_PREFIX}'"
    else
        if [ "${__project_allowed}" = "${CR_TRUE}" ] || [ "${__project_disallowed}" = "${CR_TRUE}" ]; then
            console_debug "Your project dir '${WORK_DIR}' is registered"
            console_debug "Allowed: $(core_int_to_string "${__project_allowed}") Disallowed: $(core_int_to_string "${__project_disallowed}")"
            if [ "${__project_disallowed}" = "${CR_TRUE}" ]; then
                console_fatal "Disallowed project"
            fi
        else
            console_warning "Your project dir '${WORK_DIR}' is NOT registered"
            if core_ask_question "Allow or disallow project?" "${CR_FALSE}" "ad"; then
                console_debug "Register your project dir '${WORK_DIR}' as allowed"
                echo "${WORK_DIR}" >> "${__allowed_file}"
                __project_allowed="${CR_TRUE}"
            else
                console_debug "Register your project dir '${WORK_DIR}' as disallowed"
                echo "${WORK_DIR}" >> "${__disallowed_file}"
                __project_disallowed="${CR_TRUE}"
                console_fatal "Disallowed project"
            fi
        fi
    fi
    console_print "$(colored_green "Testing project":) $(colored_cyan "${PROJECT_NAME}")"

    unset __allowed_file __disallowed_file __result __project_allowed __project_disallowed
}

__file_contains_string () {
    __file="${1}"
    __string="${2}"
    __result="$(grep "${__string}" "${__file}")"
    console_debug  "s'${__string}' f'${__file}' r'${__result}'"
    if [ "${__result}" != "" ]; then
        unset __file __string __result
        return "${CR_TRUE}"
    fi
    unset __file __string __result
    return "${CR_FALSE}"
}

__check_file_create_if_not_found () {
    __file="${1}"
    if [ -e "${__file}" ];
    then
        console_debug "File '${__file}' found"
    else
        console_debug "File '${__file}' NOT found"
        console_debug "Creating file '${__file}'"
        touch "${__file}"
    fi
    unset __file
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

_pts_check_container () {        
    console_debug "Checking container"
    __check_container "${WORK_DIR}"
    if [ "${PTS_CONTAINER_STARTED}" -eq "${CR_FALSE}" ]; then
        console_comment "Container is not running"
        console_info "Trying to start container"
        console_debug "Using debug image by default"
        __start_container "${_DOCKER_COMPOSE_FILE_DEBUG}"
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
            __restart_container "${_DOCKER_COMPOSE_FILE_DEBUG}"
            __check_container
        fi
    else
        PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE}"
    fi

    export PTS_DOCKER_COMPOSE_FILE
}

__restart_container () {
    console_debug "Container: Restarting"
    console_debug "Container: Stopping"
    if docker-compose down 
    then
        console_debug "Container successfully stopped"
    else
        console_fatal "Unable to stop container"
    fi
    __start_container "${1}"
}

__start_container () {
    console_debug "Starting container using '${1}'"
    if docker-compose -f "${1}" up -d
    then
        console_debug "Container successfully started"
    else
        console_fatal "Unable to start container"
    fi
}


_pts_generate_report_file () {
    cat <<EOF > "${PTS_TEST_REPORT_INDEX}"
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
  <title>${PROJECT_NAME}</title>
</head>
<body>

<h1>Report &lt;${PROJECT_NAME}&gt;</h1>

<p>Some links could be empty</p>
<a href='${PTS_TMP_DIR_PARTIAL}/${PTS_COVERAGE_DIR}/html/index.html'>Coverage report</a><br>
<a href='${PTS_TMP_DIR_PARTIAL}/${PTS_PHPMETRICS_DIR}/index.html'>Phpmetrics report</a><br>

</body>
</html> 
EOF
}