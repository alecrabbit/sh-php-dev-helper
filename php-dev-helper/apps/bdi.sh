#!/usr/bin/env sh
bdi_load_settings () {
    console_debug "Dummy: loading settings"
}

bdi_set_default_options () {
    BDI_DOCKER_PUSH="${CR_FALSE}"
    BDI_FORCE_BUILD="${CR_FALSE}"
}

bdi_process_options () {
    :
}

bdi_usage () {
    echo "    $(colored_yellow "--push")                - push image"
    echo "    $(colored_yellow "--force")               - force build"
}

bdi_export_options () {
    export BDI_DOCKER_PUSH
    export BDI_FORCE_BUILD
}

bdi_read_options  () {
    common_set_default_options
    bdi_set_default_options
    console_debug "bdi: Reading options"
    while [ "${1:-}" != "" ]; do
        __OPTION=$(echo "$1" | awk -F= '{print $1}')
        __VALUE=$(echo "$1" | awk -F= '{print $2}')
        case ${__OPTION} in
            --push)
                debug_option "${__OPTION}" "${__VALUE}"
                BDI_DOCKER_PUSH="${CR_TRUE}"
                ;;
            --force)
                debug_option "${__OPTION}" "${__VALUE}"
                BDI_FORCE_BUILD="${CR_TRUE}"
                ;;
            *)
                common_read_option "bdi_usage" "${__OPTION}$([ "${__VALUE}" != "" ] && echo "=${__VALUE}")"
                ;;
        esac
        shift
    done
    common_process_options
    common_export_options
    bdi_process_options
    bdi_export_options
    unset __OPTION __VALUE
}

bdi_show_settings () {
    console_debug "Dummy: showing settings"
    console_debug "BDI_DOCKER_PUSH: $(core_bool_to_string "${BDI_DOCKER_PUSH}")"
    console_debug "BDI_FORCE_BUILD: $(core_bool_to_string "${BDI_FORCE_BUILD}")"
}

bdi_check_working_env  () {
    console_debug "Dummy: check working env"
}
