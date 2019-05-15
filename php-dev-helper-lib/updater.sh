#!/usr/bin/env sh
_REPOSITORY="alecrabbit/sh-php-dev-helper"
# _REPOSITORY="alecrabbit/php-package-template" # FOR DEBUG 

updater_run () {
    _log_debug "Updater: checking install"
    _latest_version="$(github_get_latest_release "${_REPOSITORY}")"
    if [ "${_latest_version}" = "" ]; then
        _log_debug "Updater: release not found"
        _log_debug "Updater: searching for tag"
        _latest_version="$(github_get_tags "${_REPOSITORY}")"
        if [ "${_latest_version}" = "" ]; then
            _log_fatal "No releases or tags found for repository '${_REPOSITORY}'"
        fi
    fi
    _log_debug "Github last version: ${_latest_version}"
    if version_update_needed "${_latest_version}"; then
        _log_info "New version found: ${_latest_version}"
    else
        _log_comment "No update needed"
    fi    
    if core_check_if_dir_exists "${SCRIPT_DIR}/.git"
    then
        _log_fatal "It seems you are trying to update lib source dir"
    fi
    _log_info "Updater: processing"
}