#!/usr/bin/env sh

pts_show_project_type_and_name () {
    if [ "${PTS_WITH_COMPOSER}" -eq "${CR_TRUE}" ]; then
        console_print ""
        __project_type="$(core_get_project_type "${_COMPOSER_JSON_FILE}")"
        __project_name="$(core_get_project_name "${_COMPOSER_JSON_FILE}")"

        __project_type="$(colored_blue "(${__project_type})")"
        __project_name="$(colored_bold_purple "${__project_name}")"

        console_print "${__project_name} ${__project_type}"
        unset __project_type __project_name
    fi
}

pts_generate_report_file () {
    __project_name="$(core_get_project_name "${_COMPOSER_JSON_FILE}")"
    __VENDOR_NAME=$(echo "$__project_name" | awk -F/ '{print $1}')
    __PACKAGE_NAME=$(echo "$__project_name" | awk -F/ '{print $2}')

    cat <<EOF > "${PTS_TEST_REPORT_INDEX}"
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
  <title>${__PACKAGE_NAME}</title>
</head>
<body>

<h1><a href='#'>${__VENDOR_NAME}/${__PACKAGE_NAME}</a> report</h1>

<p>Some links could be empty</p>
<a href='${PTS_TMP_DIR_PARTIAL}/${PTS_COVERAGE_DIR}/html/index.html'>Coverage report</a><br>
<a href='${PTS_TMP_DIR_PARTIAL}/${PTS_PHPMETRICS_DIR}/index.html'>Phpmetrics report</a><br>
<a href='${PTS_TMP_DIR_PARTIAL}/${PTS_GRAPHS_DIR}'>Graphs dir</a><br>

</body>
</html> 
EOF
    unset __project_name __VENDOR_NAME __PACKAGE_NAME
}

pts_check_vendor_dir () {
    if [ "${PTS_WITH_COMPOSER}" -eq "${CR_TRUE}" ]; then
        if core_dir_exists "${WORK_DIR}/vendor"; then
            console_debug "Dir 'vendor' found"
        else 
            console_error "No 'vendor' dir"
            console_comment "Installing..."
            func_execute_dc_command "${PTS_DOCKER_COMPOSE_FILE}" "composer install"
        fi
    fi
}

pts_check_working_env () {
    func_check_user

    if ! check_command "docker-compose"
    then 
        console_unable "docker-compose is NOT installed!"
    fi
    console_debug "Checking docker-compose: installed"
    if [ "${PTS_WITH_COMPOSER}" -eq "${CR_TRUE}" ]; then
        __composer_file=" ${_COMPOSER_JSON_FILE}"
    else
        __composer_file=""
    fi
    if ! core_is_dir_contains "${WORK_DIR}" "${_DOCKER_COMPOSE_FILE} ${_DOCKER_COMPOSE_FILE_DEBUG}${__composer_file}" "${CR_TRUE}"
    then
        console_notice "\nAre you in the right directory?"
        console_unable "Required file(s) not found in current directory"
    fi
    if [ "${DIR_CONTROL}" -eq "${CR_ENABLED}" ]; then
        console_warning "DIR_CONTROL$(colored_dark "(experimental)") is enabled"
        __dir_control
    fi
    unset __composer_file
}

pts_check_container () {        
    console_debug "Checking container"
    __check_container "${WORK_DIR}"
    if [ "${PTS_CONTAINER_STARTED}" -eq "${CR_FALSE}" ]; then
        console_comment "Container is not running"
        console_info "Trying to start container"
        if [ "${PTS_REQUIRE_DEBUG_IMAGE}" -eq "${CR_TRUE}" ]; then
            PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE_DEBUG}"
        else
            PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE}"
        fi
        func_start_container "${PTS_DOCKER_COMPOSE_FILE}"
        __check_container "${WORK_DIR}"
    fi

    if [ "${PTS_REQUIRE_DEBUG_IMAGE}" -eq "${CR_TRUE}" ]; then
        console_debug "Debug image required, need to restart container?"
        PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE_DEBUG}"
        if [ "${PTS_DEBUG_IMAGE_USED}" -eq "${CR_TRUE}" ]; then
            console_debug "No restart needed: debug image used"
        else
            console_info "Debug image required - restarting..."
            console_debug "Restarting to debug image"
            func_restart_container "${PTS_DOCKER_COMPOSE_FILE}"
            __check_container "${WORK_DIR}"
        fi
    else
        PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE}"
    fi

    export PTS_DOCKER_COMPOSE_FILE
}

__check_container () {
    __dir="${WORK_DIR}"
    PTS_DEBUG_IMAGE_USED="${CR_ERROR}"
    PTS_CONTAINER_STARTED="${CR_FALSE}"
    if docker_compose_is_container_started "${__dir}"
    then
        PTS_CONTAINER_STARTED="${CR_TRUE}"
        console_debug "Container is running"
        if docker_compose_is_debug_image_used "${__dir}"
        then
            __message="Debug"
            PTS_DEBUG_IMAGE_USED="${CR_TRUE}"
        else
            __message="Regular"
            PTS_DEBUG_IMAGE_USED=${CR_FALSE}
        fi
    else
        console_debug "Container is NOT running"
    fi
    console_debug "Image used: ${__message:-unable to define image(container is not running)}"
    export PTS_CONTAINER_STARTED
    export PTS_DEBUG_IMAGE_USED
    unset __dir
}

__dir_control () {
    func_create_file_if_not_found "${PTS_ALLOWED_DIRS_FILE}"
    func_create_file_if_not_found "${PTS_DISALLOWED_DIRS_FILE}"

    __project_allowed="$(core_file_contains_string "${PTS_ALLOWED_DIRS_FILE}" "${WORK_DIR}" && echo "${CR_TRUE}" || echo "${CR_FALSE}")"
    __project_disallowed="$(core_file_contains_string "${PTS_DISALLOWED_DIRS_FILE}" "${WORK_DIR}" && echo "${CR_TRUE}" || echo "${CR_FALSE}")"

    PROJECT_DIR="$(basename "${WORK_DIR}")"

    if [ "${USE_DIR_PREFIX}" -eq "${CR_ENABLED}" ]; then
        console_debug "USE_DIR_PREFIX enabled"
        __result="$(echo "${PROJECT_DIR}" | grep -i "${WORKING_PREFIX}")"
    fi

    if [ "${__result:-}" != "" ]; then
        console_debug "Your project allowed by name '${PROJECT_DIR}'"
        console_debug "Your project name contains '${WORKING_PREFIX}'"
    else
        if [ "${__project_allowed}" = "${CR_TRUE}" ] || [ "${__project_disallowed}" = "${CR_TRUE}" ]; then
            console_debug "Your project dir '${WORK_DIR}' is registered"
            console_debug "Allowed: $(core_bool_to_string "${__project_allowed}") Disallowed: $(core_bool_to_string "${__project_disallowed}")"
            if [ "${__project_disallowed}" = "${CR_TRUE}" ]; then
                console_unable "Disallowed project directory"
            fi
        else
            console_dark "Files:"
            console_dark "${PTS_ALLOWED_DIRS_FILE}"
            console_dark "${PTS_DISALLOWED_DIRS_FILE}"
            console_warning "Your project dir '${WORK_DIR}' is NOT registered"
            console_dark "This can not be canceled - you should select one of options"
            if core_ask_question "Allow(a) or disallow(d) to test project?" "${CR_FALSE}" "ad"; then
                console_debug "Register your project dir '${WORK_DIR}' as allowed"
                echo "${WORK_DIR}" >> "${PTS_ALLOWED_DIRS_FILE}"
                __project_allowed="${CR_TRUE}"
            else
                console_debug "Register your project dir '${WORK_DIR}' as disallowed"
                echo "${WORK_DIR}" >> "${PTS_DISALLOWED_DIRS_FILE}"
                __project_disallowed="${CR_TRUE}"
                console_fatal "Disallowed project"
            fi
        fi
    fi
    unset __result __project_allowed __project_disallowed
}

pts_usage () {
    echo "    $(colored_yellow "-a, --all")             - run all (not includes --metrics and --multi)"
    echo "    $(colored_yellow "-b ")                   - enable php code sniffer beautifier"
    echo "    $(colored_yellow "-c, --coverage")        - enable phpunit code coverage (includes -u)"
    echo "    $(colored_yellow "--cs")                  - enable php code sniffer"
    echo "    $(colored_yellow "-g, --graphs")         - create dependencies graphs"
    echo "    $(colored_yellow "--metrics")             - enable phpmetrics"
    echo "    $(colored_yellow "--multi")               - enable multi-tester"
    echo "    $(colored_yellow "--phpstan")             - enable phpstan"
    echo "    $(colored_yellow "--psalm")               - enable psalm"
    echo "    $(colored_yellow "-s, --analyze")         - enable static analysis tools (--phpstan and --psalm)"
    echo "    $(colored_yellow "--security")            - enable security checks"
    echo "    $(colored_yellow "-u, --unit")            - enable phpunit"
    echo "    $(colored_yellow "-v")                    - enable check for forgotten var dumps"
    echo "    $(colored_yellow "--without-composer")    - do not check for 'composer.json' file and 'vendor' dir"
}

pts_set_default_options () {
    COMMON_EXECUTE=${CR_TRUE}
    PTS_REQUIRE_DEBUG_IMAGE=${CR_FALSE}
    PTS_RESTART=${CR_FALSE}
    PTS_VAR_DUMP_CHECK=${CR_FALSE}
    PTS_METRICS=${CR_FALSE}
    PTS_MULTI=${CR_FALSE}
    PTS_CS=${CR_FALSE}
    PTS_CS_BF=${CR_FALSE}
    PTS_PHPSTAN=${CR_FALSE}
    PTS_PSALM=${CR_FALSE}
    PTS_PHPUNIT=${CR_TRUE}
    PTS_PHP_SECURITY=${CR_FALSE}
    PTS_WITH_COMPOSER=${CR_TRUE}
    PTS_PHPUNIT_COVERAGE=${CR_FALSE}
    __ALL_OPTION=${CR_FALSE}
    PTS_DEPS_GRAPH=${CR_FALSE}
}

pts_process_options () {
    if [ "${PTS_PHPUNIT_COVERAGE}" -eq "${CR_TRUE}" ]; then
        PTS_PHPUNIT=${CR_TRUE}
    fi
    if [ "${__ALL_OPTION}" -eq "${CR_TRUE}" ]; then
        PTS_CS=${CR_TRUE}
        PTS_CS_BF=${CR_TRUE}
        PTS_PHPSTAN=${CR_TRUE}
        PTS_PSALM=${CR_TRUE}
        PTS_PHPUNIT=${CR_TRUE}
        PTS_PHPUNIT_COVERAGE=${CR_TRUE}
    fi
}

pts_export_options () {
    export COMMON_EXECUTE
    export PTS_REQUIRE_DEBUG_IMAGE
    export PTS_RESTART
    export PTS_VAR_DUMP_CHECK
    export PTS_METRICS
    export PTS_MULTI
    export PTS_CS
    export PTS_CS_BF
    export PTS_PHPSTAN
    export PTS_PSALM
    export PTS_PHPUNIT
    export PTS_PHP_SECURITY
    export PTS_WITH_COMPOSER
    export PTS_PHPUNIT_COVERAGE
    export PTS_DEPS_GRAPH
}

pts_show_selected_options () {
    console_dark "\n     Selected options:"
    if [ "${CR_DEBUG}" -eq 1 ]
    then
        console_show_option "${COMMON_EXECUTE}" "Execute"
        console_show_option "${PTS_RESTART}" "Container restart"
    fi
    console_show_option "${PTS_PHPUNIT}" "PHPUnit"
    console_show_option "${PTS_PHPUNIT_COVERAGE}" "PHPUnit code coverage"
    console_show_option "${PTS_VAR_DUMP_CHECK}" "Var dump checks"
    console_show_option "${PTS_MULTI}" "Multi-tester"
    console_show_option "${PTS_METRICS}" "PHPMetrics"
    console_show_option "${PTS_PHPSTAN}" "PHPStan"
    console_show_option "${PTS_PSALM}" "Psalm"
    console_show_option "${PTS_PHP_SECURITY}" "Security checks"
    console_show_option "${PTS_CS}" "Code sniffer"
    console_show_option "${PTS_CS_BF}" "Code sniffer Beautifier"
    console_show_option "${PTS_DEPS_GRAPH}" "Dependencies graph"
    console_dark ""
}

pts_read_options () {
    pts_set_default_options
    console_debug "pts: Reading options"
    while [ "${1:-}" != "" ]; do
        __OPTION=$(echo "$1" | awk -F= '{print $1}')
        __VALUE=$(echo "$1" | awk -F= '{print $2}')
        case ${__OPTION} in
            -v | --var-dump)
                debug_option "${__OPTION}" "${__VALUE}"
                PTS_VAR_DUMP_CHECK=${CR_TRUE}
                PTS_PHPUNIT=${CR_FALSE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            -a | --all)
                debug_option "${__OPTION}" "${__VALUE}"
                __ALL_OPTION=${CR_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            -s | --analyze)
                debug_option "${__OPTION}" "${__VALUE}"
                PTS_PHPUNIT=${CR_FALSE}
                PTS_PHPSTAN=${CR_TRUE}
                PTS_PSALM=${CR_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            -u | --unit)
                debug_option "${__OPTION}" "${__VALUE}"
                PTS_PHPUNIT=${CR_TRUE}
                ;;
            --security)
                debug_option "${__OPTION}" "${__VALUE}"
                PTS_PHP_SECURITY=${CR_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            -c | --coverage)
                debug_option "${__OPTION}" "${__VALUE}"
                PTS_PHPUNIT_COVERAGE=${CR_TRUE}
                PTS_PHPUNIT=${CR_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            --metrics)
                debug_option "${__OPTION}" "${__VALUE}"
                PTS_METRICS=${CR_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            --phpstan)
                debug_option "${__OPTION}" "${__VALUE}"
                PTS_PHPSTAN=${CR_TRUE}
                PTS_PHPUNIT=${CR_FALSE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            --psalm)
                debug_option "${__OPTION}" "${__VALUE}"
                PTS_PSALM=${CR_TRUE}
                PTS_PHPUNIT=${CR_FALSE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            --cs)
                debug_option "${__OPTION}" "${__VALUE}"
                PTS_CS=${CR_TRUE}
                PTS_PHPUNIT=${CR_FALSE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            --multi)
                debug_option "${__OPTION}" "${__VALUE}"
                PTS_MULTI=${CR_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            -b | --beauty | --beautify)
                debug_option "${__OPTION}" "${__VALUE}"
                PTS_CS_BF=${CR_TRUE}
                PTS_PHPUNIT=${CR_FALSE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            -g | --graphs)
                debug_option "${__OPTION}" "${__VALUE}"
                PTS_DEPS_GRAPH=${CR_TRUE}
                PTS_PHPUNIT=${CR_FALSE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            --no-restart)
                debug_option "${__OPTION}" "${__VALUE}"
                PTS_RESTART=${CR_FALSE}
                ;;
            --without-composer)
                PTS_WITH_COMPOSER=${CR_FALSE}
                debug_option "${__OPTION}" "${__VALUE}"
                ;;
            *)
                common_read_option "pts_usage" "${__OPTION}$([ "${__VALUE}" != "" ] && echo "=${__VALUE}")"
                ;;
        esac
        shift
    done
    pts_process_options
    pts_export_options
    unset __OPTION __VALUE
}
