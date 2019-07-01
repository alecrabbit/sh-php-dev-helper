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
    echo "    $(colored_yellow "--force")               - force build"
    echo "    $(colored_yellow "--push")                - push image"
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

bdi_show_image_name () {
    BDI_DOCKER_IMAGE_NAME="dralec/${PWD##*/}"
    console_debug "Work dir: ${WORK_DIR}"
    console_print "Image name: ${BDI_DOCKER_IMAGE_NAME}"
}

bdi_build_image () {
    if [ "${BDI_FORCE_BUILD}" = "${CR_TRUE}" ]
    then
        docker build --no-cache -t "${BDI_DOCKER_IMAGE_NAME}" .
    else
        docker build -t "${BDI_DOCKER_IMAGE_NAME}" .
    fi
    BDI_BUILD_RESULT=$?
}

bdi_push_image () {
    if [ "${BDI_BUILD_RESULT}" = "${CR_TRUE}" ]
    then
        console_info "Built '${BDI_DOCKER_IMAGE_NAME}' successfully."
        notifier_notify "🐳 Docker" "Built '${BDI_DOCKER_IMAGE_NAME}' successfully."
        if [ "${BDI_DOCKER_PUSH}" = "${CR_TRUE}" ]
        then
            if docker push "${BDI_DOCKER_IMAGE_NAME}"; then
                console_info "Pushed '${BDI_DOCKER_IMAGE_NAME}' successfully."
                notifier_notify "🐳 Docker" "Pushed '${BDI_DOCKER_IMAGE_NAME}' successfully."
            else
                console_error "Failed to push image"
            fi
        fi
    else
        console_error "Failed to build image"
    fi
}
