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
}

mmb_working_dir () {
    console_debug "Prepare tmp dir"

    if core_check_if_dir_exists "${MMB_TMP_DIR}"; then
        console_error "Dir '${MMB_TMP_DIR}' exists. Maybe it wasn't cleaned up earlier."
        console_fatal "Unable to proceed"
    else
        console_debug "Creating dir: ${MMB_TMP_DIR}"
        console_debug "$(mkdir -pv "${MMB_TMP_DIR}")"
    fi
}

mmb_cleanup () {
    console_debug "Cleaning up"

    if core_check_if_dir_exists "${MMB_TMP_DIR}"; then
        console_debug "Deleting dir: ${MMB_TMP_DIR}"
        console_debug "$(rm -rv "${MMB_TMP_DIR}")"
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

mmb_usage () {
    echo "Usage:"
    echo "    $(colored_bold "${SCRIPT_NAME}") [options]"
    echo "Options:"
    echo "    $(colored_yellow "-h")                    - show help message and exit"
    echo "    $(colored_yellow "-p")                    - update script"
    echo "    $(colored_yellow "-o")                    - update script"
    echo "    $(colored_yellow "-s")                    - update script"
    echo "    $(colored_yellow "-n")                    - update script"
    echo "    $(colored_yellow "-x")                    - update script"
    echo "    $(colored_yellow "--update")              - update script"
    echo "    $(colored_yellow "-V, --version")         - show version"
    echo
    # shellcheck disable=SC2005
    echo "$(colored_dark "Note: options order is important")"
}

mmb_set_default_options () {
    TMPL_USE_OWNER_NAMESPACE="${CR_TRUE}"
}

mmb_process_options () {
    :
}

mmb_export_options () {
    export TMPL_USE_OWNER_NAMESPACE
}


mmb_read_options () {
    mmb_set_default_options
    console_debug "Reading options"
    while [ "${1:-}" != "" ]; do
        PARAM=$(echo "$1" | awk -F= '{print $1}')
        VALUE=$(echo "$1" | awk -F= '{print $2}')
        case ${PARAM} in
            -h | --help)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                mmb_usage
                exit
                ;;
            --update)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                _pts_updater_run "${VALUE}"
                exit
                ;;
            -V | --version)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                version_print
                exit "${CR_TRUE}"
                ;;
            # Undocumented
            --save-build-hash)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                version_save_build_hash "${SCRIPT_DIR}" "${LIB_DIR}"
                exit "${CR_TRUE}"
                ;;
            # Undocumented
            --no-exec)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_EXECUTE=${CR_FALSE}
                ;;
            -p)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                TMPL_PACKAGE_NAME="${VALUE}"
                ;;
            -o)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                TMPL_PACKAGE_OWNER="${VALUE}"
                ;;
            -n)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                TMPL_PACKAGE_OWNER_NAME="${VALUE}"
                ;;
            -s)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                TMPL_PACKAGE_OWNER_NAMESPACE="${VALUE}"
                ;;
            -x)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                TMPL_USE_OWNER_NAMESPACE="${CR_FALSE}"
                ;;
            --debug)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                CR_DEBUG=1
                console_debug "Script '${SCRIPT_NAME}' launched in debug mode."
                ;;
            *)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                console_error "Unknown option '${PARAM}'"
                mmb_usage
                exit 1
                ;;
        esac
        shift
    done
    mmb_process_options
    mmb_export_options
    unset PARAM VALUE
}