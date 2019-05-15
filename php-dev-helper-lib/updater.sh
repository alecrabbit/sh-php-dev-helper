#!/usr/bin/env sh
__TMP_DIR=".tmp"
_OWNER="alecrabbit"
_PACKAGE="sh-php-dev-helper"
_REPOSITORY="${_OWNER}/${_PACKAGE}"
_LATEST_VERSION=""

updater_run () {
    _log_debug "Updater: checking install"
    _LATEST_VERSION="$(github_get_latest_release "${_REPOSITORY}")"
    if [ "${_LATEST_VERSION}" = "" ]; then
        _log_debug "Updater: release not found"
        _log_debug "Updater: searching for tag"
        _LATEST_VERSION="$(github_get_tags "${_REPOSITORY}")"
        if [ "${_LATEST_VERSION}" = "" ]; then
            _log_fatal "No releases or tags found for repository '${_REPOSITORY}'"
        fi
    fi
    _log_debug "Github last version: ${_LATEST_VERSION}"
    if version_update_needed "${_LATEST_VERSION}"; then
        _log_comment "Current version: ${_VERSION}"
        _log_info "New version found: ${_LATEST_VERSION}"
        if core_check_if_dir_exists "${SCRIPT_DIR}/.git"
        then
            _log_fatal "It seems you are trying to update lib source dir"
        fi
        _log_info "Updater: processing"
        __updater_download
    else
        _log_info "You are using latest version: ${_VERSION}"
        _log_comment "No update needed"
    fi    
}

__updater_download () {
    __dir="${WORK_DIR}/${__TMP_DIR}"
    _log_debug "Removing '${__dir}'\n$(rm -rfv "${__dir}" 2>&1)"
    _log_debug "Recreating '${__dir}'\n$(mkdir -p "${__dir}" 2>&1)"
    _log_debug "Downloading to '${__dir}/${_PACKAGE}-${_LATEST_VERSION}'"
    if cd "${__dir}" && wget -qO- "https://github.com/${_REPOSITORY}/archive/${_LATEST_VERSION}.tar.gz" | tar -xzv
    then
        _log_debug "Package downloaded"
        _log_debug "Copying new files to '${SCRIPT_DIR}'\n$(cp -rv "${__dir}/${_PACKAGE}-${_LATEST_VERSION}"/. "${SCRIPT_DIR}"/. 2>&1)"
        # shellcheck disable=SC2116
        _log_debug "Writing new version\n$(echo "${_LATEST_VERSION}" > "${_VERSION_FILE}" 2>&1)"
        echo "${_LATEST_VERSION}" > "${_VERSION_FILE}"
    else
        _log_fatal "Error occurred during download"
    fi
    unset __dir
}