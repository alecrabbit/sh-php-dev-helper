#!/usr/bin/env sh
_OWNER="alecrabbit"
_PACKAGE="sh-php-dev-helper"
_REPOSITORY="${_OWNER}/${_PACKAGE}"
_LATEST_VERSION=""

_pts_updater_run () {
    if core_check_if_dir_exists "${SCRIPT_DIR}/.git"
    then
        __remote="$(cd "${SCRIPT_DIR}" && git remote -v)"
        console_debug "Remote:\n${__remote}"
        __result="$(echo "${__remote}" | grep -e "${_REPOSITORY}")"
        if [ "${__result}" != "" ]; then
            console_fatal "It seems you are trying to update lib sources"
        fi
        unset __remote __result
    fi
    __REQUIRED_VERSION="${1:-}"
    if [ "${__REQUIRED_VERSION}" != "" ]; then
        if [ "${__REQUIRED_VERSION}" != "${_VERSION}" ] || [ "${__REQUIRED_VERSION}" = "master" ] || [ "${__REQUIRED_VERSION}" = "develop" ]; then
            console_comment "User required version: ${__REQUIRED_VERSION}"
            __updater_install "${__REQUIRED_VERSION}"
        else
            console_comment "You are already using this version: ${_VERSION}"
        fi
        unset __REQUIRED_VERSION _LATEST_VERSION _OWNER _REPOSITORY _PACKAGE 
        return "${CR_TRUE}"
    fi
    console_debug "Updater: checking install"
    _LATEST_VERSION="$(github_get_latest_version "${_REPOSITORY}" 2>&1)"
    if [ $? -ne "${CR_TRUE}" ];then
        console_fatal "${_LATEST_VERSION}"
    fi
    console_debug "Github last version: ${_LATEST_VERSION}"
    if version_update_needed "${_LATEST_VERSION}"; then
        console_comment "Current version: ${_VERSION}"
        console_info "New version found: ${_LATEST_VERSION}"
        console_info "Updating..."
        __updater_install "${_LATEST_VERSION}"
        unset _LATEST_VERSION _OWNER _REPOSITORY _PACKAGE
    else
        console_info "You are using latest version: ${_VERSION}"
    fi
    unset __REQUIRED_VERSION  
}

__updater_install () {
    __dir="${WORK_DIR}/${PTS_TMP_DIR}"
    __version="${1}"
    console_debug "Removing '${__dir}'\n$(rm -rfv "${__dir}" 2>&1)"
    console_debug "Recreating '${__dir}'\n$(mkdir -pv "${__dir}" 2>&1)"
    console_debug "Downloading to '${__dir}/${_PACKAGE}-${__version}'"
    __result="$(cd "${__dir}" && wget -qO- "https://github.com/${_REPOSITORY}/archive/${__version}.tar.gz" | tar -xzv 2>&1)"
    # shellcheck disable=SC2181
     if [ $? -eq 0 ]
    then
        console_debug "Package downloaded"
        console_debug "Deleting dev module '${AUX_DEV_MODULE}'\n$(rm -v "${__dir}/${_PACKAGE}-${__version}"/${AUX_DEV_MODULE} 2>&1)"
        console_debug "Copying new files to '${SCRIPT_DIR}'\n$(cp -rv "${__dir}/${_PACKAGE}-${__version}"/. "${SCRIPT_DIR}"/. 2>&1)"
        console_debug "Renaming\n$(mv -v "${SCRIPT_DIR}/php-tests-dev" "${SCRIPT_DIR}/${SCRIPT_NAME}" 2>&1)"
        
        console_debug "Writing new version ${__version} > ${VERSION_FILE}"
        # shellcheck disable=SC2116
        console_debug "Writing new version\n$(echo "${__version}" > "${VERSION_FILE}" 2>&1)"
        console_debug "Cleanup '${__dir}'\n$(rm -rfv "${__dir}" 2>&1)"
        console_info "Update complete ${_VERSION}, build ${_BUILD} -> ${__version}, build $(cat "${BUILD_FILE}")"
    else
        console_debug "${__result}"
        console_fatal "Error occurred during download"
    fi
    unset __dir __version __result
}