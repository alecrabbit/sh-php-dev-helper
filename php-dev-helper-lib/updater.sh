#!/usr/bin/env sh
updater_run () {
    _log_debug "Updater: checking install"
    if core_check_if_dir_exists "${SCRIPT_DIR}/.git"
    then
        _log_fatal "It seems you are trying to update lib source dir"
    fi
    _log_info "Updater: processing"
}