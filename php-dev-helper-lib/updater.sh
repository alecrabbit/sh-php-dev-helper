#!/usr/bin/env sh

# DEPENDS ON:     
# core.sh
# └── console.sh
#     └── colored.sh
# git.sh
# version.sh

_do_not_update_dev () {
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
    _do_not_update_dev "${SCRIPT_DIR}" "${PDH_REPOSITORY}"

    if [ "${__REQUIRED_VERSION}" != "" ]; then
        if [ "${__REQUIRED_VERSION}" != "${SCRIPT_VERSION}" ] \
        || [ "${__REQUIRED_VERSION}" = "${VERSION_MASTER}"  ] \
        || [ "${__REQUIRED_VERSION}" = "${VERSION_DEVELOP}"  ]; then
            console_comment "User required version: ${__REQUIRED_VERSION}"
            __updater_install "${WORK_DIR}/${PTS_UPDATER_TMP_DIR}" "${PDH_REPOSITORY}" "${PDH_PACKAGE}" "${__REQUIRED_VERSION}"
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
        if __updater_install "${WORK_DIR}/${PTS_UPDATER_TMP_DIR}" "${PDH_REPOSITORY}" "${PDH_PACKAGE}" "${_LATEST_VERSION}"
        then
            console_debug "Successfully installed new version"
        fi
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
        console_debug "Renaming\n$(mv -v "${SCRIPT_DIR}/php-tests-dev" "${SCRIPT_DIR}/${SCRIPT_NAME}" 2>&1)"
        
        console_debug "Writing new version ${__version} > ${VERSION_FILE}"
        # shellcheck disable=SC2116
        console_debug "Writing new version\n$(echo "${__version}" > "${VERSION_FILE}" 2>&1)"
        console_debug "Cleanup '${__dir}'\n$(rm -rfv "${__dir}" 2>&1)"
        console_info "Update complete: ${SCRIPT_VERSION}, build ${SCRIPT_BUILD} -> ${__version}, build $(cat "${BUILD_FILE}")"
        unset __dir __version __result __package __repository
        return "${CR_TRUE}"
    else
        console_fatal "Error occurred during download"
    fi
}

updater_download () {
    __to_dir="${1}"
    __repository="${2}"
    __package="${3}"
    __version="${4}"
    console_debug "Removing '${__to_dir}'\n$(rm -rfv "${__to_dir}" 2>&1)"
    console_debug "Recreating '${__to_dir}'\n$(mkdir -pv "${__to_dir}" 2>&1)"
    console_debug "Downloading to '${__to_dir}/${__package}-${__version}'"
    __result="$(cd "${__to_dir}" && wget -qO- "https://github.com/${__repository}/archive/${__version}.tar.gz" | tar -xzv 2>&1)"
    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        console_info "Package '${__package}-${__version}' downloaded"
        return "${CR_TRUE}"
    fi
    
    console_debug "${__result}"
    console_error "Possible cause: incorrect version $(colored_bold_cyan "'${__version}'")"

    unset __to_dir __version __result __package __repository
    return "${CR_FALSE}"
}

# __updater_install () {
#     console_debug "$@"

#     __dir="${1}"
#     __repository="${2}"
#     __package="${3}"
#     __version="${4}"
#     console_debug "Removing '${__dir}'\n$(rm -rfv "${__dir}" 2>&1)"
#     console_debug "Recreating '${__dir}'\n$(mkdir -pv "${__dir}" 2>&1)"
#     console_debug "Downloading to '${__dir}/${__package}-${__version}'"
#     __result="$(cd "${__dir}" && wget -qO- "https://github.com/${__repository}/archive/${__version}.tar.gz" | tar -xzv 2>&1)"
#     # shellcheck disable=SC2181
#     if [ $? -eq 0 ]
#     then
#         console_debug "Package downloaded"
#         console_debug "Deleting dev module '${PTS_AUX_DEV_MODULE}'\n$(rm -v "${__dir}/${__package}-${__version}/${PTS_AUX_DEV_MODULE}" 2>&1)"
#         console_debug "Copying new files to '${SCRIPT_DIR}'\n$(cp -rv "${__dir}/${__package}-${__version}"/. "${SCRIPT_DIR}"/. 2>&1)"
#         console_debug "Renaming\n$(mv -v "${SCRIPT_DIR}/php-tests-dev" "${SCRIPT_DIR}/${SCRIPT_NAME}" 2>&1)"
        
#         console_debug "Writing new version ${__version} > ${VERSION_FILE}"
#         # shellcheck disable=SC2116
#         console_debug "Writing new version\n$(echo "${__version}" > "${VERSION_FILE}" 2>&1)"
#         console_debug "Cleanup '${__dir}'\n$(rm -rfv "${__dir}" 2>&1)"
#         console_info "Update complete: ${SCRIPT_VERSION}, build ${SCRIPT_BUILD} -> ${__version}, build $(cat "${BUILD_FILE}")"
#     else
#         console_debug "${__result}"
#         console_error "Possible cause: incorrect version $(colored_bold_cyan "'${__version}'")"
#         console_fatal "Error occurred during download"
#     fi
#     unset __dir __version __result __package __repository
# }

