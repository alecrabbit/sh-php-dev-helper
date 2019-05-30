#!/usr/bin/env sh
export MMB_SETTINGS_FILE="${LIB_DIR}/.template_settings"

mmb_load_settings () {
    console_debug "Settings file: ${MMB_SETTINGS_FILE}"
}

mmb_check_working_env () {
    func_check_user
}

