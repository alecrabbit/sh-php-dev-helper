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

install_show_settings () {
    :
}

install_get_destination () {
    SUITE_DIR="${HOME}/.local/bin"
    SUITE_DIR="$(core_get_user_input "Enter destination dir" "${SUITE_DIR}")"
    SUITE_DIR="$(core_str_replace "${SUITE_DIR}" "~" "${HOME}")"
    SUITE_DIR="$(core_get_realpath "${SUITE_DIR}")"
    console_info "Installing to '${SUITE_DIR}'"
    if ! core_dir_exists "${SUITE_DIR}"; then
        console_debug "$(mkdir -pv "${SUITE_DIR}" 2>&1)"
    fi
}

install_copy_files_to_destination () {
    console_comment "Copying files..."
    console_debug "$(cp -rv . "${SUITE_DIR}/.")"
}

install_rename_scripts () {
    console_debug "$(mv -v "${SUITE_DIR}/php-tests-dev" "${SUITE_DIR}/php-tests")"
    console_debug "$(mv -v "${SUITE_DIR}/moomba-dev" "${SUITE_DIR}/moomba")"
    console_debug "$(mv -v "${SUITE_DIR}/build-image-dev" "${SUITE_DIR}/build-image")"
}

install_cleanup () {
    console_print ""
    console_comment "Cleaning up..."
    console_debug "Deleting files"
    if core_dir_exists "${SUITE_DIR}/.git"; then
        console_debug "$(rm -rf "${SUITE_DIR}/.git" 2>&1)"
    fi
    if core_dir_exists "${SCRIPT_DIR}/.git"; then
        console_debug "Installation is the source or was cloned"
    else
        console_debug "Deleting installation dir '${SCRIPT_DIR}':\n $(rm -rv "${SCRIPT_DIR}" 2>&1)"
    fi

    console_debug "Deleting: $(rm -rv "$(core_get_realpath "${SUITE_DIR}/${__LIB_DIR_NAME}/apps/install.sh")")"
    console_debug "Deleting: $(rm -rv "$(core_get_realpath "${SUITE_DIR}/${__LIB_DIR_NAME}/includers/include_install.sh")")"
    console_debug "Deleting: $(rm -rv 2>&1 "$(core_get_realpath "${SUITE_DIR}/${__LIB_DIR_NAME}/common/dev.sh")")"
    console_debug "Deleting: $(rm -rv "$(core_get_realpath "${SUITE_DIR}/install")")"
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

install_check_installed_tools  () {
    console_debug "Checking installed tools"
    __TOOLS="docker docker-compose git git-chglog notify-send realpath tree"
    console_dark "\n     Installed:"

    for __tool in ${__TOOLS}; do
        if check_command "${__tool}"
        then
            console_show_option "${CR_TRUE}" "${__tool}"
            # console_info "${__tool} - installed"
        else
            console_show_option "${CR_FALSE}" "${__tool}"
            # console_comment "${__tool} - is NOT installed"
        fi
    done
    console_print ""
    unset __TOOLS __tool
}
