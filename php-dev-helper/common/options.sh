#!/usr/bin/env sh

common_set_default_options () {
    CR_DEBUG="${CR_DEBUG:-${CR_DISABLED}}"
    COMMON_EXECUTE=${CR_TRUE}
    OPTION_NO_INTERACTION="${CR_FALSE}"
    OPTION_NOTIFY=${CR_FALSE}
}

common_process_options () {
    :
}

common_export_options () {
    export CR_DEBUG
    export COMMON_EXECUTE
    export OPTION_NO_INTERACTION
    export OPTION_NOTIFY
}

common_help_message () {
    echo "Usage:"
    echo "    $(colored_bold "${SCRIPT_NAME}") [options]"
    echo "Options:"
    echo "    $(colored_yellow "--debug")               - run in debug mode"
    echo "    $(colored_yellow "-h, --help")            - show help message and exit"
    if [ "${SCRIPT_NAME}" != "${INSTALL_SCRIPT_NAME}" ];then
        echo "    $(colored_yellow "--upgrade")              - update scripts"
    fi
    echo "    $(colored_yellow "-V, --version")         - show version"
    echo
    "${1}"
    echo
    # shellcheck disable=SC2005
    echo "$(colored_dark "Note: options order is important")"
} 

common_read_option () {
    console_debug "common: Reading options"
    __help_function="${1}"
    shift
    while [ "${1:-}" != "" ]; do
        __OPTION=$(echo "$1" | awk -F= '{print $1}')
        __VALUE=$(echo "$1" | awk -F= '{print $2}')
        case ${__OPTION} in
            -y | --no-interaction)
                debug_option "${__OPTION}" "${__VALUE}"
                OPTION_NO_INTERACTION="${CR_TRUE}"
                ;;
            --upgrade)
                if [ "${SCRIPT_NAME}" = "${INSTALL_SCRIPT_NAME}" ];then
                    console_fatal "Option is not applicable"
                fi
                debug_option "${__OPTION}" "${__VALUE}"
                _pts_upgrade_run "${__VALUE}"
                exit
                ;;
            -V | --version)
                debug_option "${__OPTION}" "${__VALUE}"
                version_print
                exit "${CR_TRUE}"
                ;;
            # Undocumented 
            --save-build-hash)
                debug_option "${__OPTION}" "${__VALUE}"
                version_save_build_hash "${SCRIPT_DIR}" "${LIB_DIR}"
                exit "${CR_TRUE}"
                ;;
            # Undocumented
            --no-exec)
                debug_option "${__OPTION}" "${__VALUE}"
                COMMON_EXECUTE=${CR_FALSE}
                ;;
            --debug)
                CR_DEBUG=${CR_ENABLED}
                debug_option "${__OPTION}" "${__VALUE}"
                ;;        
            --notify)
                debug_option "${__OPTION}" "${__VALUE}"
                OPTION_NOTIFY=${CR_TRUE}
                ;;        
            --no-ansi | --no-color | --monochrome )
                debug_option "${__OPTION}" "${__VALUE}"
                console_dark "Temp solution:"
                console_comment "Use env variable COLOR:"
                console_print "    COLOR=never ${SCRIPT_NAME}"
                exit
                ;;
            --show-message-samples)
                debug_option "${__OPTION}" "${__VALUE}"
                console_show_messages_samples
                ;;
            -h | --help)
                debug_option "${__OPTION}" "${__VALUE}"
                common_help_message "${__help_function}"
                exit
                ;;
            *)
                debug_option "${__OPTION}" "${__VALUE}"
                console_error "Unknown option '${__OPTION}'"
                common_help_message "${__help_function}"
                exit 1
                ;;
        esac
        shift
    done
    unset __OPTION __VALUE __help_function
}

debug_option () {
    console_debug "Used option '${1}'$([ "${2}" != "" ] && echo " with value '${2}'")"
}