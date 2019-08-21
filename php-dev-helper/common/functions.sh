#!/usr/bin/env sh

SCRIPT_START_TIME=$(date +%s)
export SCRIPT_START_TIME

func_check_user () {
    console_debug "Checking user: $(whoami)"
    if user_is_root
    then
        console_fatal "DO NOT run this script under root!"
    fi
}

func_create_file_if_not_found () {
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

func_restart_container () {
    console_debug "Container: Restarting"
    console_debug "Container: Stopping"
    if docker-compose down 
    then
        console_debug "Container successfully stopped"
    else
        console_fatal "Unable to stop container"
    fi
    func_start_container "${1}"
}

func_start_container () {
    console_debug "Starting container using '${1}'"
    if docker-compose -f "${1}" up -d
    then
        console_debug "Container successfully started"
    else
        console_fatal "Unable to start container"
    fi
}

func_execute_dc_command () {
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


__do_not_update_dev () {
    __dir=${1:-.}
    __repository=${2}
    if core_dir_exists "${__dir}/.git"
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

_pts_upgrade_run () {
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
        console_print "${EMOJI_CHECKED_FLAG}$(colored_yellow "Done!")\n${__time}"
    fi
    if [ "${FLAG_CANCELED:-${CR_FALSE}}" -eq "${CR_TRUE}" ]; then
        console_print "${EMOJI_CANCELED}$(colored_yellow "Canceled!")\n${__time}"
    fi
    if [ ! "${SCRIPT_START_TIME:-${CR_FALSE}}" = "${CR_FALSE}" ]; then
        console_dark "Executed in $(($(date +%s)-SCRIPT_START_TIME))s"
    fi
    console_dark "Bye!"

    core_set_terminal_title "${TERM_TITLE}"
    # notifier_notify "${EMOJI_RABBIT}${SCRIPT_NAME}: '$(basename "${WORK_DIR}")' Operation completed" "${WORK_DIR}"
    notifier_notify "${EMOJI_RABBIT}${SCRIPT_NAME}: Operation completed" "${WORK_DIR}"
    unset __time
}


gitattributes_keep() {
    if echo "${__GITATTRIBUTES_KEEP}" | grep -q "${1}"; then
        return 0
    fi
    return 1
}

gitattributes_export_ignore () {
    __GITATTRIBUTES_KEEP="${2}"
    for __entry in "${1}"/* "${1}"/.*
    do
        __entry="$(basename "${__entry}")"
        if [ "${__entry}" = "." ] || [ "${__entry}" = ".." ]; then 
            continue
        fi
        if ! gitattributes_keep "${__entry}"; then
            if [ -d "${__entry}" ]; then
                console_debug "${__entry} is a directory"
                __entry="/${__entry}";
            fi
            __entry="${__entry} export-ignore"
            console_debug "${__entry}"
            echo "${__entry}"
        fi
    done
    unset __entry __GITATTRIBUTES_KEEP
}

gitattributes_generate () {
    console_debug "Generating .gitattributes"
    __gtr_keep="src
LICENSE
composer.json"
    __gtr_tpl=""
    if core_dir_contains "${1}" ".gitattributes.keep" "${CR_TRUE}"
    then
        __gtr_keep="$(cat "${1}/.gitattributes.keep")"
    else
        console_comment "Using defaults:"
        console_dark "${__gtr_keep}"
    fi
    if core_dir_contains "${1}" ".gitattributes.template"
    then
        __gtr_tpl="$(cat "${1}/.gitattributes.template")"
    fi

    echo "${__gtr_tpl}$(gitattributes_export_ignore "${1}" "${__gtr_keep}")" > "${1}"/.gitattributes
    unset __gtr_tpl __gtr_keep
}
