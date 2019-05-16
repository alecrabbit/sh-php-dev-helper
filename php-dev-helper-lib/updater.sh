#!/usr/bin/env sh
__TMP_DIR=".tmp"
_OWNER="alecrabbit"
_PACKAGE="sh-php-dev-helper"
_REPOSITORY="${_OWNER}/${_PACKAGE}"
_LATEST_VERSION=""

updater_run () {
    if core_check_if_dir_exists "${SCRIPT_DIR}/.git"
    then
        __remote="$(cd "${SCRIPT_DIR}" && git remote -v)"
        console_debug "Remote:\n${__remote}"
        __result="$(echo "${__remote}" | grep -e "${_REPOSITORY}")"
        if [ "${__result}" != "" ]; then
            console_fatal "It seems you are trying to update lib sources"
        fi
    fi
    console_debug "Updater: checking install"
    _LATEST_VERSION="$(github_get_latest_version "${_REPOSITORY}" 2>&1)"
    if [ $? -ne "${PTS_TRUE}" ];then
        console_fatal "${_LATEST_VERSION}"
    fi
    console_debug "Github last version: ${_LATEST_VERSION}"
    if version_update_needed "${_LATEST_VERSION}"; then
        console_log_comment "Current version: ${_VERSION}"
        console_info "New version found: ${_LATEST_VERSION}"
        console_info "Updating..."
        __updater_install
    else
        console_info "You are using latest version: ${_VERSION}"
    fi    
}

__updater_install () {
    __dir="${WORK_DIR}/${__TMP_DIR}"
    console_debug "Removing '${__dir}'\n$(rm -rfv "${__dir}" 2>&1)"
    console_debug "Recreating '${__dir}'\n$(mkdir -p "${__dir}" 2>&1)"
    console_debug "Downloading to '${__dir}/${_PACKAGE}-${_LATEST_VERSION}'"
    console_debug "$(cd "${__dir}" && wget -qO- "https://github.com/${_REPOSITORY}/archive/${_LATEST_VERSION}.tar.gz" | tar -xzv 2>&1)"
    # shellcheck disable=SC2181
     if [ $? -eq 0 ]
    then
        console_debug "Package downloaded"
        console_debug "Copying new files to '${SCRIPT_DIR}'\n$(cp -rv "${__dir}/${_PACKAGE}-${_LATEST_VERSION}"/. "${SCRIPT_DIR}"/. 2>&1)"
        console_debug "Renaming\n$(mv "${SCRIPT_DIR}/php-tests-dev" "${SCRIPT_DIR}/${SCRIPT_NAME}" 2>&1)"
        
        console_debug "Writing new version ${_LATEST_VERSION} > ${VERSION_FILE}"
        # shellcheck disable=SC2116
        console_debug "Writing new version\n$(echo "${_LATEST_VERSION}" > "${VERSION_FILE}" 2>&1)"
        console_debug "Cleanup '${__dir}'\n$(rm -rfv "${__dir}" 2>&1)"
        console_info "Update complete ${_VERSION} -> ${_LATEST_VERSION}"
    else
        console_fatal "Error occurred during download"
    fi
    unset __dir
}