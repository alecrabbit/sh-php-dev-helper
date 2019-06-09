#!/usr/bin/env sh
bdi_load_settings () {
    console_debug "Dummy: loading settings"
}

bdi_set_default_options () {
    :
}

bdi_process_options () {
    :
}

bdi_usage () {
    console_debug "Dummy: help message"
}

bdi_export_options () {
    :
}

bdi_read_options  () {
    bdi_set_default_options
    console_debug "Reading options"
    while [ "${1:-}" != "" ]; do
        __OPTION=$(echo "$1" | awk -F= '{print $1}')
        __VALUE=$(echo "$1" | awk -F= '{print $2}')
        case ${__OPTION} in
            -h | --help)
                debug_option "${__OPTION}" "${__VALUE}"
                bdi_usage
                exit
                ;;
            *)
                common_read_option "${__OPTION}$([ "${__VALUE}" != "" ] && echo "=${__VALUE}")"
                ;;
        esac
        shift
    done
    bdi_process_options
    bdi_export_options
    unset __OPTION __VALUE
}

bdi_show_settings () {
    console_debug "Dummy: showing settings"
}

bdi_check_working_env  () {
    console_debug "Dummy: check working env"
}
