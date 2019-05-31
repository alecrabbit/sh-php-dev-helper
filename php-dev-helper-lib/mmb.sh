#!/usr/bin/env sh
export MMB_SETTINGS_FILE="${SETTINGS_DIR}/.templates_settings"
export MMB_TEMPLATES_DIR="${LIB_DIR}/templates"
export MMB_LICENSE_DIR="${MMB_TEMPLATES_DIR}/licenses"
export MMB_TMP_DIR="${WORK_DIR}/mmb-tmp"


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
        TMPL_PACKAGE_LICENSE="MIT"
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
    export TMPL_PACKAGE_LICENSE
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
    console_debug "TMPL_PACKAGE_LICENSE: ${TMPL_PACKAGE_LICENSE}"
    
    # mmb_license_create "${TMPL_PACKAGE_LICENSE}" "${TMPL_PACKAGE_OWNER_NAME}"
}

mmb_check_working_env () {
    func_check_user
    mmb_working_dir
}

mmb_working_dir () {
    console_debug "Prepare tmp dir"

    if core_check_if_dir_exists "${MMB_TMP_DIR}"; then
        console_error "Dir '${MMB_TMP_DIR}' exists. Maybe it wasn't cleaned up earlier."
        console_fatal "Unable to proceed"
    else
        console_debug "Creating dir: ${MMB_TMP_DIR}\n$(mkdir -pv "${MMB_TMP_DIR}")"
    fi
}

mmb_cleanup () {
    console_debug "Cleaning up"

    if core_check_if_dir_exists "${MMB_TMP_DIR}"; then
        console_debug "Deleting dir: ${MMB_TMP_DIR}\n$(rm -rv "${MMB_TMP_DIR}")"
    else
        console_debug "Dir ${MMB_TMP_DIR} NOT exists"
        console_error "Noting to clean up"
    fi
}

mmb_license_create () {
    __type="${1}"
    __owner="${2}"
    __year="${3:-$(date +%Y)}"
    __year="© ${__year}"
    __file="${MMB_LICENSE_DIR}/${__type}"

    console_debug "__type: ${__type}"
    console_debug "__owner: ${__owner}"
    console_debug "__year: ${__year}"

    if [ -e "${__file}" ]; then
        console_debug "License type: ${__type} found in ${MMB_LICENSE_DIR}"
        __result="$(sed "s/<YEAR>/${__year}/g; s/<COPYRIGHT HOLDER>/${__owner}/g;" "${__file}")"
        echo "${__result}"
        unset __result
    else
        console_error "License type: ${__type} not found in ${MMB_LICENSE_DIR}"
    fi

    unset __type __owner __year __file
}