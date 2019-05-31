#!/usr/bin/env sh
export MMB_SETTINGS_FILE="${SETTINGS_DIR}/.templates_settings"

mmb_load_settings () {
    if [ -e "${MMB_SETTINGS_FILE}" ]
    then
        console_debug "Found settings file: ${MMB_SETTINGS_FILE}"
        console_debug "Loading settings"

        # shellcheck disable=SC1090
        . "${MMB_SETTINGS_FILE}"
    else
        console_debug "Settings file not found, loading default settings"

        TMPL_PACKAGE_DIR_PREFIX="php-"
        TMPL_PACKAGE_DIR_SUFFIX=""

        TMPL_PACKAGE_OWNER="bunny"
        TMPL_PACKAGE_OWNER_NAME="Bugs Bunny"
        TMPL_PACKAGE_OWNER_NAMESPACE="BugsBunny"
        TMPL_PACKAGE_NAME="looney-tunes"

        TMPL_PACKAGE_DEFAULT_DESCRIPTION="Awesome package description"
        TMPL_PACKAGE_DEFAULT_NAMESPACE="LooneyTunes"
        TMPL_PACKAGE_DEFAULT_DIR="php-looney-tunes"
    fi
    mmb_export_vars
}

mmb_export_vars () {
    export TMPL_PACKAGE_DIR_PREFIX
    export TMPL_PACKAGE_DIR_SUFFIX

    export TMPL_PACKAGE_OWNER
    export TMPL_PACKAGE_OWNER_NAME
    export TMPL_PACKAGE_OWNER_NAMESPACE
    export TMPL_PACKAGE_NAME

    export TMPL_PACKAGE_DEFAULT_DESCRIPTION
    export TMPL_PACKAGE_DEFAULT_NAMESPACE
    export TMPL_PACKAGE_DEFAULT_DIR
}

mmb_show_settings () {
    console_debug "TMPL_PACKAGE_DIR_PREFIX: ${TMPL_PACKAGE_DIR_PREFIX}"
    console_debug "TMPL_PACKAGE_DIR_SUFFIX: ${TMPL_PACKAGE_DIR_SUFFIX}"
    console_debug "TMPL_PACKAGE_OWNER: ${TMPL_PACKAGE_OWNER}"
    console_debug "TMPL_PACKAGE_OWNER_NAME: ${TMPL_PACKAGE_OWNER_NAME}"
    console_debug "TMPL_PACKAGE_OWNER_NAMESPACE: ${TMPL_PACKAGE_OWNER_NAMESPACE}"
    console_debug "TMPL_PACKAGE_NAME: ${TMPL_PACKAGE_NAME}"
    console_debug "TMPL_PACKAGE_DEFAULT_DESCRIPTION: ${TMPL_PACKAGE_DEFAULT_DESCRIPTION}"
    console_debug "TMPL_PACKAGE_DEFAULT_NAMESPACE: ${TMPL_PACKAGE_DEFAULT_NAMESPACE}"
    console_debug "TMPL_PACKAGE_DEFAULT_DIR: ${TMPL_PACKAGE_DEFAULT_DIR}"
    console_debug "TMPL_USE_OWNER_NAMESPACE: $(core_bool_to_string "${TMPL_USE_OWNER_NAMESPACE}")"
    
}

mmb_check_working_env () {
    func_check_user
}


