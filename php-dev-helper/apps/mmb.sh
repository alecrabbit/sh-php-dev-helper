#!/usr/bin/env sh
export MMB_DEFAULT_TEMPLATE_NAME="default"
export MMB_SETTINGS_FILE="${SETTINGS_DIR}/.templates_settings"
export MMB_TEMPLATES_DIR="${LIB_DIR}/templates"
export MMB_DEFAULT_TEMPLATE_DIR="${MMB_TEMPLATES_DIR}/${MMB_DEFAULT_TEMPLATE_NAME}"
export MMB_LICENSE_DIR="${MMB_TEMPLATES_DIR}/.licenses"
export MMB_WORK_DIR="${WORK_DIR}/mmb-tmp"
export MMB_DEFAULT_PACKAGE_OWNER="bunny"
export MMB_DEFAULT_PACKAGE_OWNER_NAME="Bugs Bunny"


mmb_load_settings () {
    TMPL_PACKAGE_DIR_PREFIX="php-"
    TMPL_PACKAGE_DIR_SUFFIX=""

    TMPL_PACKAGE_OWNER="${MMB_DEFAULT_PACKAGE_OWNER}"
    TMPL_PACKAGE_OWNER_NAME="${MMB_DEFAULT_PACKAGE_OWNER_NAME}"
    TMPL_PACKAGE_OWNER_NAMESPACE="BugsBunny"
    TMPL_PACKAGE_NAME="looney-tunes"

    TMPL_DEFAULT_TEMPLATE="default"
    TMPL_TEMPLATE_VERSION="master"
    TMPL_PACKAGE_DESCRIPTION="Awesome package description"
    TMPL_PACKAGE_NAMESPACE="LooneyTunes"
    TMPL_PACKAGE_DIR="php-looney-tunes"
    TMPL_PACKAGE_LICENSE="MIT"
    TMPL_PACKAGE_TERMINAL_TITLE_EMOJI="📦"

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

mmb_replace_all_stubs () {
    __file="${1}"
    # Separator
    if [ ! "${TMPL_PACKAGE_OWNER_NAMESPACE}" = "" ]
    then
        # shellcheck disable=SC1003
        __separator='\\'
    else
        __separator=''
    fi
    __result="$(sed "s/<PACKAGE_EMOJI>/${TMPL_PACKAGE_TERMINAL_TITLE_EMOJI}/g; s/<PACKAGE_OWNER>/${TMPL_PACKAGE_OWNER}/g; s/<PACKAGE_DESCRIPTION>/${TMPL_PACKAGE_DESCRIPTION}/g; s/<PACKAGE_OWNR_NSPACE>/${TMPL_PACKAGE_OWNER_NAMESPACE}${__separator}/g; s/<PACKAGE_NSPACE>/${TMPL_PACKAGE_NAMESPACE}/g; s/<PACKAGE_NAME>/${TMPL_PACKAGE_NAME}/g;" "${__file}")"
    echo "${__result}" > "${__file}"
    if echo "${__file}" | grep -q "${_COMPOSER_JSON_FILE}"; then
        console_debug "Creating: '${__file}' -> ${__file}.tmp'"
        # shellcheck disable=SC1003
        __result="$(sed 's/\\/\\\\/g;' "${__file}" > "${__file}.tmp" 2>&1)"
        console_debug "$(mv -v "${__file}.tmp" "${__file}")"
    fi

    unset __file __result __separator
}

mmb_export_vars () {
    export TMPL_PACKAGE_DIR_PREFIX
    export TMPL_PACKAGE_DIR_SUFFIX

    export TMPL_PACKAGE_OWNER
    export TMPL_PACKAGE_OWNER_NAME
    export TMPL_PACKAGE_OWNER_NAMESPACE
    export TMPL_PACKAGE_NAME

    export TMPL_PACKAGE_DESCRIPTION
    export TMPL_PACKAGE_NAMESPACE
    export TMPL_PACKAGE_DIR
    export TMPL_PACKAGE_LICENSE
    export TMPL_TEMPLATE_VERSION
    export TMPL_DEFAULT_TEMPLATE
}

mmb_show_settings () {
    console_debug "TMPL_PACKAGE_DIR_PREFIX: ${TMPL_PACKAGE_DIR_PREFIX}"
    console_debug "TMPL_PACKAGE_DIR_SUFFIX: ${TMPL_PACKAGE_DIR_SUFFIX}"
    console_debug "TMPL_PACKAGE_OWNER: ${TMPL_PACKAGE_OWNER}"
    console_debug "TMPL_PACKAGE_OWNER_NAME: ${TMPL_PACKAGE_OWNER_NAME}"
    console_debug "TMPL_PACKAGE_OWNER_NAMESPACE: ${TMPL_PACKAGE_OWNER_NAMESPACE}"
    console_debug "TMPL_PACKAGE_NAME: ${TMPL_PACKAGE_NAME}"
    console_debug "TMPL_PACKAGE_DESCRIPTION: ${TMPL_PACKAGE_DESCRIPTION}"
    console_debug "TMPL_PACKAGE_NAMESPACE: ${TMPL_PACKAGE_NAMESPACE}"
    console_debug "TMPL_PACKAGE_DIR: ${TMPL_PACKAGE_DIR}"
    console_debug "TMPL_USE_OWNER_NAMESPACE: $(core_bool_to_string "${TMPL_USE_OWNER_NAMESPACE}")"
    console_debug "TMPL_WORKING_TEMPLATE_NAME: ${TMPL_WORKING_TEMPLATE_NAME}"
    console_debug "TMPL_PACKAGE_LICENSE: ${TMPL_PACKAGE_LICENSE}"
    console_debug "TMPL_TEMPLATE_VERSION: ${TMPL_TEMPLATE_VERSION}"
}

mmb_show_package_values () {
    __separator=""
    if [ ! "${TMPL_PACKAGE_OWNER_NAMESPACE}" = "" ]
    then
        __separator="\\"
    fi
    if [ "${TMPL_PACKAGE_OWNER}" = "${MMB_DEFAULT_PACKAGE_OWNER}" ] || \
    [ "${TMPL_PACKAGE_OWNER_NAME}" = "${MMB_DEFAULT_PACKAGE_OWNER_NAME}" ];then
        console_print ""
        console_notice "It seems like you forgot to create settings file"
        console_comment "'${MMB_SETTINGS_FILE}'"
        console_print ""
    fi
    console_print "Using template: $(colored_blue "${TMPL_WORKING_TEMPLATE_NAME}")"
    console_print ""
    console_print "Package: $(colored_bold_purple "${TMPL_PACKAGE_OWNER}/${TMPL_PACKAGE_NAME}")"
    console_print "Name: $(colored_bold_cyan "${TMPL_PACKAGE_OWNER_NAME}")"
    console_print "Namespace: $(colored_bold_cyan "${TMPL_PACKAGE_OWNER_NAMESPACE}${__separator}${TMPL_PACKAGE_NAMESPACE}")"
    console_print "Description: $(colored_bold_cyan "${TMPL_PACKAGE_DESCRIPTION}")"
    console_print "Directory: $(colored_bold_cyan "${TMPL_PACKAGE_DIR}")"
    console_print "License: $(colored_bold_cyan "${TMPL_PACKAGE_LICENSE}")"
    console_print ""
    unset __separator
}


mmb_check_working_env () {
    func_check_user
    if core_dir_contains "${WORK_DIR}" "${_COMPOSER_JSON_FILE}"
    then
        console_notice "Found file: '${_COMPOSER_JSON_FILE}'"
        console_notice "Are you in the right directory?"
        console_unable
    fi
}

mmb_check_package_dir() {
    __from="${1}"
    if core_dir_exists "${__from}"; then
        console_debug "Dir '${__from}' exists"
        if [ -z "$(find "${__from}" -type f)" ];then
            console_debug "Dir '${__from}' is empty"
        else
            mmb_cleanup
            console_unable "Dir '${__from}' is NOT empty"
        fi
    else
        console_comment "Creating dir: ${__from}"
        console_debug "$(mkdir -pv "${__from}")"
    fi
    unset __from
}

mmb_working_dir () {
    console_debug "Prepare tmp dir"

    if core_dir_exists "${MMB_WORK_DIR}"; then
        console_unable "Dir '${MMB_WORK_DIR}' exists. Maybe it wasn't cleaned up earlier."
    else
        console_debug "Creating dir: ${MMB_WORK_DIR}"
        console_debug "$(mkdir -pv "${MMB_WORK_DIR}")"
    fi
}

mmb_cleanup () {
    console_debug "Cleaning up"

    if core_dir_exists "${MMB_WORK_DIR}"; then
        console_debug "Deleting dir: ${MMB_WORK_DIR}"
        console_debug "$(rm -rv "${MMB_WORK_DIR}")"
    else
        console_debug "Dir ${MMB_WORK_DIR} NOT exists"
        console_error "Noting to clean up"
    fi
}

mmb_license_file_content () {
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

mmb_env_file_content () {
    __user="$(whoami)"
    __u_id="$(id -u "${__user}")"
    __g_id="$(id -u "${__user}")"
    console_debug "USER_ID: ${__u_id}"
    console_debug "GROUP_ID: ${__g_id}"
    echo "USER_ID=${__u_id}"
    echo "GROUP_ID=${__g_id}"
    unset __user __u_id __g_id
}

mmb_download_template () {
    console_debug "Defined version ${TMPL_TEMPLATE_VERSION}"
    __tmpl_version="${TMPL_TEMPLATE_VERSION}" # alecrabbit/php-package-template version
    console_info "Downloading..."
    github_download "${MMB_WORK_DIR}" "alecrabbit" "php-package-template" "${__tmpl_version}"
    console_info "Installing..."
    console_debug "Copying files ${__tmpl_version}"
    console_debug "\n$(cp -rv "${MMB_WORK_DIR}/php-package-template-${__tmpl_version}/.template/." "${MMB_DEFAULT_TEMPLATE_DIR}/.")"
    console_debug "\n$(cp -v "${MMB_DEFAULT_TEMPLATE_DIR}/.gitattributes.template" "${MMB_DEFAULT_TEMPLATE_DIR}/.gitattributes")"
    # gitattributes_generate "${WORK_DIR}"
    unset __tmpl_version
}

mmb_check_default_template () {
    __force_download="${1:-${CR_FALSE}}"
    if ! core_dir_exists "${MMB_DEFAULT_TEMPLATE_DIR}";then
        console_error "Default template not found"
        console_debug "No dir: ${MMB_DEFAULT_TEMPLATE_DIR}"
        console_debug "$(mkdir -pv "${MMB_DEFAULT_TEMPLATE_DIR}")"
    fi
    if [ -z "$(ls -A "${MMB_DEFAULT_TEMPLATE_DIR}")" ] || [ "${__force_download}" -eq "${CR_TRUE}" ];then
        console_comment "Downloading and installing default template"
        mmb_download_template
    fi
    console_debug "Default template OK"
}

mmb_usage () {
    echo "    $(colored_yellow "-p")                         - set package name"
    echo "    $(colored_yellow "-o")                         - set owner"
    echo "    $(colored_yellow "-s")                         - set package owner namespace"
    echo "    $(colored_yellow "-n")                         - set package owner name"
    echo "    $(colored_yellow "--namespace")                - override auto-picked package namespace"
    echo "    $(colored_yellow "-x")                         - do not use package owner namespace"
    echo "    $(colored_yellow "--update-default")           - update default template"
    echo "    $(colored_yellow "-t")                         - use template"
    echo "    $(colored_yellow "-y, --no-interaction")       - do not ask any interactive question"
    echo
    echo "$(colored_green "Example"):"
    echo "    ${SCRIPT_NAME} -p=new-package -o=mike"
}

mmb_set_default_options () {
    _TEMPLATE_OPTION_USED="${CR_FALSE}"

    TMPL_USE_OWNER_NAMESPACE="${CR_TRUE}"
    TMPL_WORKING_TEMPLATE_NAME="${TMPL_DEFAULT_TEMPLATE}"
}

mmb_process_options () {
    if ! core_dir_exists "${MMB_TEMPLATES_DIR}/${TMPL_WORKING_TEMPLATE_NAME}";then
        console_error "Template '${TMPL_WORKING_TEMPLATE_NAME}' not found"
        if [ "${_TEMPLATE_OPTION_USED}" = "${CR_FALSE}" ]; then
            if [ -e "${MMB_SETTINGS_FILE}" ]; then
                console_dark "Settings file"
                console_dark "${MMB_SETTINGS_FILE}:"
                console_comment "$(grep 2>&1 TMPL_DEFAULT_TEMPLATE < "${MMB_SETTINGS_FILE}")"
            fi
        fi
        if [ "${MMB_DEFAULT_TEMPLATE_NAME}" = "${TMPL_WORKING_TEMPLATE_NAME}" ]; then
            console_comment "Run with --update-default option"
        fi
        console_unable
    fi
    if [ -z "$(find "${MMB_TEMPLATES_DIR}/${TMPL_WORKING_TEMPLATE_NAME}" -type f)" ];then
        console_error "Template dir '${TMPL_WORKING_TEMPLATE_NAME}' is empty"
        console_dark "Path: ${MMB_TEMPLATES_DIR}/${TMPL_WORKING_TEMPLATE_NAME}"
        if [ "${MMB_DEFAULT_TEMPLATE_NAME}" = "${TMPL_WORKING_TEMPLATE_NAME}" ]; then
            console_comment "Run with --update-default option"
        fi
        console_unable
    fi

    if [ ! "${TMPL_PACKAGE_TERMINAL_TITLE_EMOJI}" = "" ]; then
        TMPL_PACKAGE_TERMINAL_TITLE_EMOJI="${TMPL_PACKAGE_TERMINAL_TITLE_EMOJI} "
    fi

    if [ "${TMPL_USE_NAMESPACE_OVERRIDE:-${CR_FALSE}}" = "${CR_TRUE}" ]; then
        TMPL_PACKAGE_NAMESPACE=$(mmb_prepare_package_namespace "${TMPL_PACKAGE_NAMESPACE}")
    else
        TMPL_PACKAGE_NAMESPACE=$(mmb_prepare_package_namespace "${TMPL_PACKAGE_NAME}")
    fi

    console_debug "Prepared package namespace: ${TMPL_PACKAGE_NAMESPACE}"
    mmb_prepare_package_dir
    if [ "${TMPL_USE_OWNER_NAMESPACE}" -eq "${CR_FALSE}" ]; then
        TMPL_PACKAGE_OWNER_NAMESPACE=""
    fi
}

mmb_export_options () {
    export TMPL_USE_OWNER_NAMESPACE
    export TMPL_WORKING_TEMPLATE_NAME
}

mmb_prepare_package_namespace () {
    __namespace=$(core_lowercase "${1}")
    __namespace=$(core_remove_prefix "${TMPL_PACKAGE_DIR_PREFIX}" "${__namespace}")
    __namespace=$(core_remove_symbols "-_ " "$(core_capitalize_every_word "${__namespace}")")
    console_debug "Package namespace '${__namespace}'"
    echo "${__namespace}"
    unset __namespace
}

mmb_prepare_package_dir () {
    TMPL_PACKAGE_DIR="$(core_remove_suffix "${TMPL_PACKAGE_DIR_SUFFIX}" "${TMPL_PACKAGE_NAME}")"
    TMPL_PACKAGE_DIR="${TMPL_PACKAGE_DIR_PREFIX}$(core_remove_prefix "${TMPL_PACKAGE_DIR_PREFIX}" "${TMPL_PACKAGE_DIR}")${TMPL_PACKAGE_DIR_SUFFIX}"
}

mmb_read_options () {
    common_set_default_options
    mmb_set_default_options
    console_debug "MMB: Reading options"
    while [ "${1:-}" != "" ]; do
        __OPTION=$(echo "$1" | awk -F= '{print $1}')
        __VALUE=$(echo "$1" | awk -F= '{print $2}')
        case ${__OPTION} in
            --update-default)
                debug_option "${__OPTION}" "${__VALUE}"
                mmb_update_default_template
                exit "${CR_TRUE}"
                ;;
            -p)
                debug_option "${__OPTION}" "${__VALUE}"
                core_check_option_value "${__VALUE}" "${__OPTION}"
                TMPL_PACKAGE_NAME="${__VALUE}"
                ;;
            -o)
                debug_option "${__OPTION}" "${__VALUE}"
                core_check_option_value "${__VALUE}" "${__OPTION}"
                TMPL_PACKAGE_OWNER="${__VALUE}"
                ;;
            -n)
                debug_option "${__OPTION}" "${__VALUE}"
                core_check_option_value "${__VALUE}" "${__OPTION}"
                TMPL_PACKAGE_OWNER_NAME="${__VALUE}"
                ;;
            --namespace)
                debug_option "${__OPTION}" "${__VALUE}"
                core_check_option_value "${__VALUE}" "${__OPTION}"
                TMPL_PACKAGE_NAMESPACE="${__VALUE}"
                TMPL_USE_NAMESPACE_OVERRIDE="${CR_TRUE}"
                ;;
            --no-git)
                debug_option "${__OPTION}" "${__VALUE}"
                TMPL_CREATE_GIT_REPO="${CR_FALSE}"
                ;;
            -s)
                debug_option "${__OPTION}" "${__VALUE}"
                core_check_option_value "${__VALUE}" "${__OPTION}"
                TMPL_PACKAGE_OWNER_NAMESPACE="${__VALUE}"
                ;;
            -x)
                debug_option "${__OPTION}" "${__VALUE}"
                TMPL_USE_OWNER_NAMESPACE="${CR_FALSE}"
                ;;
            -t)
                debug_option "${__OPTION}" "${__VALUE}"
                console_info "Template to use as default: '${TMPL_WORKING_TEMPLATE_NAME}'"
                core_check_option_value "${__VALUE}" "${__OPTION}"
                _TEMPLATE_OPTION_USED="${CR_TRUE}"
                TMPL_WORKING_TEMPLATE_NAME="${__VALUE}"
                ;;
            *)
                common_read_option "mmb_usage" "${__OPTION}$([ "${__VALUE}" != "" ] && echo "=${__VALUE}")"
                ;;
        esac
        shift
    done
    common_process_options
    common_export_options
    mmb_process_options
    mmb_export_options
    unset __OPTION __VALUE
}

mmb_create_package () {
    console_debug "Copy all files to destination"
    __from="${MMB_TEMPLATES_DIR}/${1}/."
    __to="${WORK_DIR}/${2}"
    console_debug "$(cp -rv "${__from}" "${__to}" )"
    unset __from
    find "${__to}" -type f | while read -r file; do mmb_replace_all_stubs "${file}"; done
    console_debug "$(mkdir -pv "${__to}/src/${TMPL_PACKAGE_NAMESPACE}")"
    console_debug "$(mv -v "${__to}/BasicClass.php" "${__to}/src/${TMPL_PACKAGE_NAMESPACE}/BasicClass.php")"
    console_debug "$(mv -v "${__to}/BasicTest.php" "${__to}/tests/BasicTest.php")"
    mmb_license_file_content "${TMPL_PACKAGE_LICENSE}" "${TMPL_PACKAGE_OWNER_NAME}" > "${__to}/LICENSE"
    mmb_env_file_content > "${__to}/.env"
    unset __to
}

mmb_update_default_template () {
    mmb_working_dir
    mmb_check_default_template "${CR_TRUE}"
    mmb_cleanup
    console_info "Default template updated"
}

mmb_package_created () {
    __dir="${WORK_DIR}/${1}"

    if ! check_command "docker-compose"
    then 
        console_error "docker-compose is NOT installed!"
        console_comment "Deleting docker-compose files!"
        console_debug "\n$(rm "${__dir}"/docker-compose*.yml)"
    fi

    if check_command "tree"; then
        console_info "File structure:"
        console_print "$(tree -a "${__dir}")"
    fi

    if [ "${TMPL_CREATE_GIT_REPO:-${CR_TRUE}}" = "${CR_TRUE}" ]; then
        if check_command "git"; then
            console_debug "git installed"
            console_comment "Creating repository"
            console_print "$(cd "${__dir}" && git init && git add .)"
            if git_credentials_are_set; then
                console_comment "Making first commit"
                console_dark "$(cd "${__dir}" && git commit -m init)"
            fi
        fi
    fi

    unset __dir
}
