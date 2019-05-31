#!/usr/bin/env sh
export MMB_SETTINGS_FILE="${SETTINGS_DIR}/.templates_settings"
export MMB_TEMPLATES_DIR="${LIB_DIR}/templates"
export MMB_DEFAULT_TEMPLATE_DIR="${MMB_TEMPLATES_DIR}/default"
export MMB_LICENSE_DIR="${MMB_TEMPLATES_DIR}/licenses"
export MMB_WORK_DIR="${WORK_DIR}/mmb-tmp"


mmb_load_settings () {
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

    if [ -e "${MMB_SETTINGS_FILE}" ]
    then
        console_debug "Found settings file: ${MMB_SETTINGS_FILE}"
        console_debug "Loading settings"

        # shellcheck disable=SC1090
        . "${MMB_SETTINGS_FILE}"
    else
        console_debug "Settings file not found, using default settings"

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
    console_debug "TMPL_USE_TEMPLATE_NAME: ${TMPL_USE_TEMPLATE_NAME}"
    console_debug "TMPL_PACKAGE_LICENSE: ${TMPL_PACKAGE_LICENSE}"
    
    # mmb_license_create "${TMPL_PACKAGE_LICENSE}" "${TMPL_PACKAGE_OWNER_NAME}"
}

mmb_check_working_env () {
    func_check_user
    # if [ "${PTS_WITH_COMPOSER}" -eq "${CR_TRUE}" ]; then
    #     __composer_file=" ${_COMPOSER_JSON_FILE}"
    # else
    #     __composer_file=""
    # fi
    if core_is_dir_contains "${WORK_DIR}" "${_COMPOSER_JSON_FILE}" "${CR_TRUE}"
    then
        console_notice "Found file: '${_COMPOSER_JSON_FILE}'"
        console_notice "Are you in the right directory?"
        console_fatal "Unable to proceed"
    fi

}

mmb_check_package_dir() {
    __dir="${1}"
    if core_check_if_dir_exists "${__dir}"; then
        console_debug "Dir '${__dir}' exists"
        if [ -z "$(ls -A "${__dir}")" ];then
            console_debug "Dir '${__dir}' is empty"
        else
            console_error "Dir '${__dir}' is NOT empty"
            console_fatal "Unable to proceed"
        fi
    else
        console_debug "Creating dir: ${__dir}"
        console_debug "$(mkdir -pv "${__dir}")"
    fi
    unset __dir
}

mmb_working_dir () {
    console_debug "Prepare tmp dir"

    if core_check_if_dir_exists "${MMB_WORK_DIR}"; then
        console_error "Dir '${MMB_WORK_DIR}' exists. Maybe it wasn't cleaned up earlier."
        console_fatal "Unable to proceed"
    else
        console_debug "Creating dir: ${MMB_WORK_DIR}"
        console_debug "$(mkdir -pv "${MMB_WORK_DIR}")"
    fi
}

mmb_cleanup () {
    console_debug "Cleaning up"

    if core_check_if_dir_exists "${MMB_WORK_DIR}"; then
        console_debug "Deleting dir: ${MMB_WORK_DIR}"
        console_debug "$(rm -rv "${MMB_WORK_DIR}")"
    else
        console_debug "Dir ${MMB_WORK_DIR} NOT exists"
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

mmb_download_template () {
    github_download "${MMB_WORK_DIR}" "alecrabbit" "php-package-template" "develop"
    console_debug "Copying files"
    console_debug "\n$(cp -rv "${MMB_WORK_DIR}/php-package-template-develop/.template/." "${MMB_DEFAULT_TEMPLATE_DIR}/.")"
}

mmb_check_default_template () {
    __force_download="${1:-${CR_FALSE}}"
    if ! core_check_if_dir_exists "${MMB_DEFAULT_TEMPLATE_DIR}";then
        console_debug "No dir: ${MMB_DEFAULT_TEMPLATE_DIR}"
        console_debug "$(mkdir -pv "${MMB_DEFAULT_TEMPLATE_DIR}")"
    fi
    if [ -z "$(ls -A "${MMB_DEFAULT_TEMPLATE_DIR}")" ] || [ "${__force_download}" -eq "${CR_TRUE}" ];then
        mmb_download_template
    fi
    console_debug "Default template OK"
}
mmb_usage () {
    echo "Usage:"
    echo "    $(colored_bold "${SCRIPT_NAME}") [options]"
    echo "Options:"
    echo "    $(colored_yellow "-h, --help")            - show help message and exit"
    echo "    $(colored_yellow "-p")                    - set package name"
    echo "    $(colored_yellow "-o")                    - set owner"
    echo "    $(colored_yellow "-s")                    - set owner namespace"
    echo "    $(colored_yellow "-n")                    - set package namespace"
    echo "    $(colored_yellow "-x")                    - do not use package namespace"
    echo "    $(colored_yellow "--update")              - update script"
    echo "    $(colored_yellow "--update-default")      - update default template"
    echo "    $(colored_yellow "-V, --version")         - show version"
    echo "    $(colored_yellow "--no-interaction")      - do not ask any interactive question"
    echo
    echo "$(colored_green "Example"):"
    echo "    ${SCRIPT_NAME} -p=new-package -o=mike"
    echo
    echo "$(colored_dark "Note: options order is important") "
}

mmb_set_default_options () {
    TMPL_USE_OWNER_NAMESPACE="${CR_TRUE}"
    TMPL_USE_TEMPLATE_NAME="default"
}

mmb_process_options () {
    :
}

mmb_export_options () {
    export TMPL_USE_OWNER_NAMESPACE
    export TMPL_USE_TEMPLATE_NAME
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
            --no-interaction)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                mmb_usage
                exit
                ;;
            --update)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                _pts_updater_run "${VALUE}"
                exit
                ;;
            --update-default)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                mmb_working_dir
                mmb_check_default_template "${CR_TRUE}"
                mmb_cleanup
                console_info "Default template updated"
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
                export COMMON_EXECUTE=${CR_FALSE}
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
            -u)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                TMPL_USE_TEMPLATE_NAME="${VALUE}"
                if ! core_check_if_dir_exists "${MMB_TEMPLATES_DIR}/${TMPL_USE_TEMPLATE_NAME}";then
                    console_fatal "Template '${TMPL_USE_TEMPLATE_NAME}' not found"
                fi
                ;;
            --debug)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                export CR_DEBUG=1
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