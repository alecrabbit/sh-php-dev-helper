#!/usr/bin/env sh

common_set_default_options () {
    CR_DEBUG="${CR_DEBUG:-${CR_DISABLED}}"
    COMMON_EXECUTE=${CR_TRUE}
}

common_process_options () {
    :
}
common_export_options () {
    export CR_DEBUG
    export COMMON_EXECUTE
}

common_help_message () {
    echo "Usage:"
    echo "    $(colored_bold "${SCRIPT_NAME}") [options]"
    echo "Options:"
    "${1}"
    echo "    $(colored_yellow "-h, --help")            - show help message and exit"
    echo "    $(colored_yellow "--update")              - update script"
    echo "    $(colored_yellow "-V, --version")         - show version"
    echo
    # shellcheck disable=SC2005
    echo "$(colored_dark "Note: options order is important")"
} 

common_read_option () {
    common_set_default_options
    console_debug "common: Reading options"
    while [ "${1:-}" != "" ]; do
        __OPTION=$(echo "$1" | awk -F= '{print $1}')
        __VALUE=$(echo "$1" | awk -F= '{print $2}')
        case ${__OPTION} in
            --update)
                debug_option "${__OPTION}" "${__VALUE}"
                _pts_updater_run "${__VALUE}"
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
                common_help_message "${2}"
                exit
                ;;
            *)
                debug_option "${__OPTION}" "${__VALUE}"
                console_error "Unknown option '${__OPTION}'"
                common_help_message "${2}"
                exit 1
                ;;
        esac
        shift
    done
    common_process_options
    common_export_options
    unset __OPTION __VALUE
}

debug_option () {
    console_debug "Selected option '${1}'$([ "${2}" != "" ] && echo " with value '${2}'")"
}