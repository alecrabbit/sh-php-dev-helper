#!/usr/bin/env sh

install_load_settings () {
    console_debug "Dummy: loading settings"
}

install_set_default_options () {
    :
}

install_process_options () {
    :
}

install_usage () {
    echo "    $(colored_yellow "-d")                    - <dummy>"
}

install_export_options () {
    :
}
install_get_destination () {
    SUITE_DIR="${HOME}/.local/bin"
    SUITE_DIR="$(core_get_user_input "Enter destination dir" "${SUITE_DIR}")"
    SUITE_DIR="$(core_str_replace "${SUITE_DIR}" "~" "${HOME}")"
    SUITE_DIR="$(core_get_realpath "${SUITE_DIR}")"
    console_info "Installing to '${SUITE_DIR}'" 
}

install_cleanup () {
    console_print ""
    console_comment "Cleaning Up"
    console_debug "Deleting files"
    console_debug "$(core_get_realpath "apps/install.sh")"
    console_debug "$(core_get_realpath "includers/include_install.sh")"
    console_debug "$(core_get_realpath "install")"
}
install_read_options  () {
    common_set_default_options
    install_set_default_options
    console_debug "install: Reading options"
    while [ "${1:-}" != "" ]; do
        __OPTION=$(echo "$1" | awk -F= '{print $1}')
        __VALUE=$(echo "$1" | awk -F= '{print $2}')
        case ${__OPTION} in
            *)
                common_read_option "install_usage" "${__OPTION}$([ "${__VALUE}" != "" ] && echo "=${__VALUE}")"
                ;;
        esac
        shift
    done
    common_process_options
    common_export_options
    install_process_options
    install_export_options
    unset __OPTION __VALUE
}

install_show_settings () {
    console_debug "Dummy: showing settings"
}

install_check_working_env  () {
    console_debug "Dummy: check working env"
}
