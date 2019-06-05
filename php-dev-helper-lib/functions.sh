#!/usr/bin/env sh
PROJECT_NAME="$(basename "${WORK_DIR}")"

_pts_check_working_env () {
    func_check_user

    if ! check_command "docker-compose"
    then 
        console_fatal "docker-compose is NOT installed!"
    fi
    console_debug "Checking docker-compose: installed"
    if [ "${PTS_WITH_COMPOSER}" -eq "${CR_TRUE}" ]; then
        __composer_file=" ${_COMPOSER_JSON_FILE}"
    else
        __composer_file=""
    fi
    if ! core_is_dir_contains "${WORK_DIR}" "${_DOCKER_COMPOSE_FILE} ${_DOCKER_COMPOSE_FILE_DEBUG}${__composer_file}" "${CR_TRUE}"
    then
        console_notice "\nAre you in the right directory?"
        console_fatal "Required file(s) not found in current directory"
    fi
    if [ "${DIR_CONTROL}" -eq "${CR_ENABLED}" ]; then
        console_warning "DIR_CONTROL is an experimental feature"
        __dir_control
    fi
    unset __composer_file
}

func_check_user () {
    console_debug "Checking user: $(whoami)"
    if user_is_root
    then
        console_fatal "DO NOT run this script under root!"
    fi
}

__dir_control () {
    __check_file_create_if_not_found "${PTS_ALLOWED_DIRS_FILE}"
    __check_file_create_if_not_found "${PTS_DISALLOWED_DIRS_FILE}"

    __project_allowed="$(core_file_contains_string "${PTS_ALLOWED_DIRS_FILE}" "${WORK_DIR}" && echo "${CR_TRUE}" || echo "${CR_FALSE}")"
    __project_disallowed="$(core_file_contains_string "${PTS_DISALLOWED_DIRS_FILE}" "${WORK_DIR}" && echo "${CR_TRUE}" || echo "${CR_FALSE}")"

    if [ "${USE_DIR_PREFIX}" -eq "${CR_ENABLED}" ]; then
        console_debug "USE_DIR_PREFIX enabled"
        __result="$(echo "${PROJECT_NAME}" | grep -i "${WORKING_PREFIX}")"
    fi

    if [ "${__result:-}" != "" ]; then
        console_debug "Your project allowed by name '${PROJECT_NAME}'"
        console_debug "Your project name contains '${WORKING_PREFIX}'"
    else
        if [ "${__project_allowed}" = "${CR_TRUE}" ] || [ "${__project_disallowed}" = "${CR_TRUE}" ]; then
            console_debug "Your project dir '${WORK_DIR}' is registered"
            console_debug "Allowed: $(core_bool_to_string "${__project_allowed}") Disallowed: $(core_bool_to_string "${__project_disallowed}")"
            if [ "${__project_disallowed}" = "${CR_TRUE}" ]; then
                console_fatal "Disallowed project"
            fi
        else
            console_dark "Files:"
            console_dark "${PTS_ALLOWED_DIRS_FILE}"
            console_dark "${PTS_DISALLOWED_DIRS_FILE}"
            console_warning "Your project dir '${WORK_DIR}' is NOT registered"
            console_dark "This can not be canceled - you should select one of options"
            if core_ask_question "Allow(a) or disallow(d) to test project?" "${CR_FALSE}" "ad"; then
                console_debug "Register your project dir '${WORK_DIR}' as allowed"
                echo "${WORK_DIR}" >> "${PTS_ALLOWED_DIRS_FILE}"
                __project_allowed="${CR_TRUE}"
            else
                console_debug "Register your project dir '${WORK_DIR}' as disallowed"
                echo "${WORK_DIR}" >> "${PTS_DISALLOWED_DIRS_FILE}"
                __project_disallowed="${CR_TRUE}"
                console_fatal "Disallowed project"
            fi
        fi
    fi
    unset __result __project_allowed __project_disallowed
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
    __dir="${WORK_DIR}"
    PTS_DEBUG_IMAGE_USED="${CR_ERROR}"
    PTS_CONTAINER_STARTED="${CR_FALSE}"
    if docker_compose_is_container_started "${__dir}"
    then
        PTS_CONTAINER_STARTED="${CR_TRUE}"
        console_debug "Container is running"
        if docker_compose_is_debug_image_used "${__dir}"
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
    unset __dir
}

_pts_check_container () {        
    console_debug "Checking container"
    __check_container "${WORK_DIR}"
    if [ "${PTS_CONTAINER_STARTED}" -eq "${CR_FALSE}" ]; then
        console_comment "Container is not running"
        console_info "Trying to start container"
        if [ "${PTS_REQUIRE_DEBUG_IMAGE}" -eq "${CR_TRUE}" ]; then
            PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE_DEBUG}"
        else
            PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE}"
        fi
        __start_container "${PTS_DOCKER_COMPOSE_FILE}"
        __check_container "${WORK_DIR}"
    fi

    if [ "${PTS_REQUIRE_DEBUG_IMAGE}" -eq "${CR_TRUE}" ]; then
        console_debug "Debug image required, need to restart container?"
        PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE_DEBUG}"
        if [ "${PTS_DEBUG_IMAGE_USED}" -eq "${CR_TRUE}" ]; then
            console_debug "No restart needed: debug image used"
        else
            console_info "Debug image required - restarting..."
            console_debug "Restarting to debug image"
            __restart_container "${PTS_DOCKER_COMPOSE_FILE}"
            __check_container "${WORK_DIR}"
        fi
    else
        PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE}"
    fi

    export PTS_DOCKER_COMPOSE_FILE
}

_pts_check_vendor_dir () {
    if [ "${PTS_WITH_COMPOSER}" -eq "${CR_TRUE}" ]; then
        if core_check_if_dir_exists "${WORK_DIR}/vendor"; then
            console_debug "Dir 'vendor' found"
        else 
            console_error "No 'vendor' dir"
            console_comment "Installing..."
            __execute_command "${PTS_DOCKER_COMPOSE_FILE}" "composer install"
        fi
    fi
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

__execute_command () {
    console_debug "Executing command '${2}' using '${1}'"
    __command="docker-compose -f ${1} exec app ${2}"
    console_debug "${__command}"
    if ${__command}
    then
        console_debug "Command successfully executed"
    else
        console_fatal "Unable to to execute command '${2}'"
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

__do_not_update_dev () {
    __dir=${1:-.}
    __repository=${2}
        if core_check_if_dir_exists "${__dir}/.git"
    then
        __remote="$(cd "${__dir}" && git remote -v)"
        console_debug "Remote:\n${__remote}"
        __result="$(echo "${__remote}" | grep -e "${__repository}")"
        if [ "${__result}" != "" ]; then
            console_fatal "It seems you are trying to update lib sources"
        fi
        unset __remote __result
    fi
}

_pts_updater_run () {
    __REQUIRED_VERSION="${1:-}"
    __do_not_update_dev "${SCRIPT_DIR}" "${PDH_REPOSITORY}"

    if [ "${__REQUIRED_VERSION}" != "" ]; then
        if [ "${__REQUIRED_VERSION}" != "${SCRIPT_VERSION}" ] \
        || [ "${__REQUIRED_VERSION}" = "${VERSION_MASTER}"  ] \
        || [ "${__REQUIRED_VERSION}" = "${VERSION_DEVELOP}"  ]; then
            console_comment "User required version: ${__REQUIRED_VERSION}"
            __updater_install "${HOME}/${PTS_UPDATER_TMP_DIR}" "${PDH_REPOSITORY}" "${PDH_PACKAGE}" "${__REQUIRED_VERSION}"
        else
            console_comment "You are already using this version: ${SCRIPT_VERSION}"
        fi
        unset __REQUIRED_VERSION _LATEST_VERSION 
        return "${CR_TRUE}"
    fi
    console_debug "Updater: checking install"
    _LATEST_VERSION="$(github_get_latest_version "${PDH_REPOSITORY}" 2>&1)"
    if [ $? -ne "${CR_TRUE}" ];then
        console_fatal "${_LATEST_VERSION}"
    fi
    console_debug "Github last version: ${_LATEST_VERSION}"
    if version_update_needed "${_LATEST_VERSION}"; then
        console_comment "Current version: ${SCRIPT_VERSION}"
        console_info "New version found: ${_LATEST_VERSION}"
        console_info "Updating..."
        __updater_install "${HOME}/${PTS_UPDATER_TMP_DIR}" "${PDH_REPOSITORY}" "${PDH_PACKAGE}" "${_LATEST_VERSION}"
    else
        console_info "You are using latest version: ${SCRIPT_VERSION}"
    fi
    unset __REQUIRED_VERSION _LATEST_VERSION 
}

__updater_install () {
    __dir="${1}"
    __repository="${2}"
    __package="${3}"
    __version="${4}"
    if updater_download "${__dir}" "${__repository}" "${__package}" "${__version}"
    then
        console_comment "Installing package"
        console_debug "Deleting dev module '${PTS_AUX_DEV_MODULE}'\n$(rm -v "${__dir}/${__package}-${__version}/${PTS_AUX_DEV_MODULE}" 2>&1)"
        console_debug "Copying new files to '${SCRIPT_DIR}'\n$(cp -rv "${__dir}/${__package}-${__version}"/. "${SCRIPT_DIR}"/. 2>&1)"
        console_debug "Renaming\n$(mv -v "${SCRIPT_DIR}/php-tests-dev" "${SCRIPT_DIR}/php-tests" 2>&1)"
        console_debug "Renaming\n$(mv -v "${SCRIPT_DIR}/moomba-dev" "${SCRIPT_DIR}/moomba" 2>&1)"
        console_debug "Renaming\n$(mv -v "${SCRIPT_DIR}/build-image-dev" "${SCRIPT_DIR}/build-image" 2>&1)"
        
        console_debug "Writing new version ${__version} > ${VERSION_FILE}"
        # shellcheck disable=SC2116
        console_debug "Writing new version\n$(echo "${__version}" > "${VERSION_FILE}" 2>&1)"
        console_debug "Cleanup '${__dir}'\n$(rm -rfv "${__dir}" 2>&1)"
        console_print "${SCRIPT_VERSION}$(colored_dark "@${SCRIPT_BUILD}") -> ${EMOJI_NEW}${__version}$(colored_dark "@$(cat "${BUILD_FILE}")")"
        console_info "Update complete"
        unset __dir __version __result __package __repository
        return "${CR_TRUE}"
    else
        console_fatal "Unable to update package"
    fi
}

func_print_header () {
    console_header "${EMOJI_RABBIT}${1}"
    console_debug "Version $(version_string "${CR_TRUE}")"
    console_comment "Version $(version_string)"
}

func_print_footer () {
    if [ "${CR_DEBUG}" -eq "${CR_DISABLED}" ]; then
        __time="$(colored_dark "$(date '+%Y-%m-%d %H:%M:%S')")"
    else
        __time=""
    fi
    console_print ""
    if [ "${FLAG_DONE:-${CR_FALSE}}" -eq "${CR_TRUE}" ]; then
        console_print "${EMOJI_FIN_FLAG}$(colored_yellow "Done!")\n${__time}"
    fi
    if [ "${FLAG_CANCELED:-${CR_FALSE}}" -eq "${CR_TRUE}" ]; then
        console_print "${EMOJI_CANCELED}$(colored_yellow "Canceled!")\n${__time}"
    fi
    console_dark "Executed in $(($(date +%s)-${1}))s"
    console_dark "Bye!"

    core_set_terminal_title "${__TITLE}"
    unset __time
}

_pts_show_project_type_and_name () {
    if [ "${PTS_WITH_COMPOSER}" -eq "${CR_TRUE}" ]; then
        console_print ""
        __project_type="$(core_get_project_type "${_COMPOSER_JSON_FILE}")"
        # __project_type="$(core_capitalize_every_word "${__project_type}")"
        __project_name="$(core_get_project_name "${_COMPOSER_JSON_FILE}")"

        __project_type="$(colored_blue "(${__project_type})")"
        __project_name="$(colored_bold_purple "${__project_name}")"

        console_print "${__project_name} ${__project_type}"
        unset __project_type __project_name
    fi
}