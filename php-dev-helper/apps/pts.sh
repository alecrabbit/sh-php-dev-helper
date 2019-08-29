#!/usr/bin/env sh

# Disable source following.
#   shellcheck disable=SC1090,SC1091

export CHGLOG_CONFIG_FILE=".chglog/config.yml"

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
    console_debug "${WORK_DIR}/${PTS_TEST_REPORT_INDEX}"
    cat <<EOF > "${WORK_DIR}/${PTS_TEST_REPORT_INDEX}"
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
  <title>${__PACKAGE_NAME}</title>
</head>
<body>

<h1><a href='#'>${__VENDOR_NAME}/${__PACKAGE_NAME}</a> report</h1>

<p>Some links could be empty</p>
<a href='${PTS_COVERAGE_DIR}/html/index.html'>Coverage report</a><br>
<a href='${PTS_PHPMETRICS_DIR}/index.html'>Phpmetrics report</a><br>
<a href='${PTS_GRAPHS_DIR}'>Graphs dir</a><br>
PHP Mess Detector <a href='../${PTS_BUILD_DIR}/phpmd.html'>report</a><br>

</body>
</html> 
EOF
    unset __project_name __VENDOR_NAME __PACKAGE_NAME
}

pts_check_vendor_dir () {
    if [ "${PTS_CONTAINER_STARTED:-${CR_FALSE}}" -eq "${CR_TRUE}" ] && [ "${PTS_WITH_COMPOSER}" -eq "${CR_TRUE}" ]; then
        if core_dir_exists "${WORK_DIR}/vendor"; then
            console_debug "Dir 'vendor' found"
        else 
            console_error "No 'vendor' dir"
            console_comment "Installing..."
            func_execute_dc_command "${PTS_DOCKER_COMPOSE_FILE}" "composer install"
        fi
    fi
}

pts_load_settings () {
    PTS_RUN_PRIORITY="docker"
    ### LOAD SETTINGS FROM FILE
    if [ -e "${PTS_SETTINGS_FILE}" ]
    then
        . "${PTS_SETTINGS_FILE}"
    fi
}

pts_show_settings () {
    console_debug "PTS_RUN_PRIORITY: ${PTS_RUN_PRIORITY}"
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
    if ! core_dir_contains "${WORK_DIR}" "${_DOCKER_COMPOSE_FILE} ${_DOCKER_COMPOSE_FILE_DEBUG}${__composer_file}" "${CR_TRUE}"
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
    if [ "${PTS_REQUIRE_CONTAINER}" -eq "${CR_TRUE}" ]; then
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
                console_debug "No container restart needed: debug image used"
            else
                console_info "Debug image required - restarting container..."
                console_debug "Restarting container to debug image"
                func_restart_container "${PTS_DOCKER_COMPOSE_FILE}"
                __check_container "${WORK_DIR}"
            fi
        else
            PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE}"
        fi
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
# ✔️   PHPUnit
#  ✔️   PHPUnit code coverage
#      Var dump checks
#      Multi-tester
#      PHPMetrics
#  ✔️   PHPStan
#  ✔️   Psalm
#      Security checks
#  ✔️   Code sniffer
#  ✔️   Code sniffer Beautifier
#      Dependencies graph
#      Update changelog file


pts_usage () {
    echo "    $(colored_yellow "-a, --all")             - run all (substitutes -c, -s, --cs, -b)"
    echo "    $(colored_yellow "-b ")                   - enable php code sniffer beautifier"
    echo "    $(colored_yellow "--cl")                  - update CHANGELOG.md"
    echo "    $(colored_yellow "-c, --coverage")        - enable phpunit code coverage (includes -u)"
    echo "    $(colored_yellow "--cs")                  - enable php code sniffer"
    echo "    $(colored_yellow "--ga")                  - generate .gitattributes file"
    echo "    $(colored_yellow "-g, --graphs")          - create dependencies graphs"
    echo "    $(colored_yellow "--md")                  - enable phpmd"
    echo "    $(colored_yellow "--metrics")             - enable phpmetrics"
    echo "    $(colored_yellow "--multi")               - enable multi-tester"
    echo "    $(colored_yellow "--phpstan")             - enable phpstan"
    echo "    $(colored_yellow "--psalm")               - enable psalm"
    echo "    $(colored_yellow "-s, --analyze")         - enable static analysis tools (--phpstan and --psalm)"
    echo "    $(colored_yellow "--security")            - enable security checks"
    echo "    $(colored_yellow "-t, --total")           - all options enabled"
    echo "    $(colored_yellow "-u, --unit")            - enable phpunit"
    echo "    $(colored_yellow "-v")                    - enable check for forgotten var dumps"
    echo "    $(colored_yellow "--without-composer")    - do not check for 'composer.json' file and 'vendor' dir"
}

pts_set_default_options () {
    PTS_REQUIRE_CONTAINER=${CR_FALSE}
    PTS_REQUIRE_ENVIRONMENT=${CR_FALSE}
    PTS_GITATTRIBUTES_GENERATE=${CR_FALSE}
    PTS_REQUIRE_DEBUG_IMAGE=${CR_FALSE}
    PTS_RESTART=${CR_FALSE}
    PTS_VAR_DUMP_CHECK=${CR_FALSE}
    PTS_METRICS=${CR_FALSE}
    PTS_PHPMD=${CR_FALSE}
    PTS_MULTI=${CR_FALSE}
    PTS_CS=${CR_FALSE}
    PTS_CS_BF=${CR_FALSE}
    PTS_PHPSTAN=${CR_FALSE}
    PTS_PSALM=${CR_FALSE}
    PTS_PHPUNIT=${CR_TRUE}
    PTS_PHP_SECURITY=${CR_FALSE}
    PTS_WITH_COMPOSER=${CR_TRUE}
    PTS_PHPUNIT_COVERAGE=${CR_FALSE}
    PTS_UPDATE_CHANGELOG=${CR_FALSE}
    __ALL_OPTION=${CR_FALSE}
    __TOTAL_OPTION=${CR_FALSE}
    PTS_DEPS_GRAPH=${CR_FALSE}
    PTS_CHANGELOG_TAGS=""
}

pts_process_options () {
    if [ "${PTS_PHPUNIT}" -eq "${CR_TRUE}" ]; then
        PTS_REQUIRE_CONTAINER=${CR_TRUE}
    fi
    if [ "${PTS_PHPUNIT_COVERAGE}" -eq "${CR_TRUE}" ]; then
        PTS_PHPUNIT=${CR_TRUE}
    fi
    if [ "${__TOTAL_OPTION}" -eq "${CR_TRUE}" ]; then
        PTS_VAR_DUMP_CHECK=${CR_TRUE}
        PTS_METRICS=${CR_TRUE}
        PTS_PHPMD=${CR_TRUE}
        PTS_MULTI=${CR_TRUE}
        PTS_PHP_SECURITY=${CR_TRUE}
        PTS_UPDATE_CHANGELOG=${CR_TRUE}
        PTS_DEPS_GRAPH=${CR_TRUE}
        PTS_GITATTRIBUTES_GENERATE=${CR_TRUE}
        __ALL_OPTION=${CR_TRUE}
    fi
    if [ "${PTS_REQUIRE_DEBUG_IMAGE}" -eq "${CR_TRUE}" ]; then
        PTS_REQUIRE_CONTAINER=${CR_TRUE}
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
    export PTS_GITATTRIBUTES_GENERATE
    export PTS_REQUIRE_DEBUG_IMAGE
    export PTS_RESTART
    export PTS_VAR_DUMP_CHECK
    export PTS_PHPMD
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
    export PTS_UPDATE_CHANGELOG
    export PTS_CHANGELOG_TAGS
    export PTS_REQUIRE_CONTAINER
    export PTS_REQUIRE_ENVIRONMENT
}

pts_show_selected_options () {
    console_dark "\n     Selected options:"
    if [ "${CR_DEBUG}" -eq 1 ]
    then
        console_show_option "${COMMON_EXECUTE}" "Execute"
        console_show_option "${PTS_RESTART}" "Container restart"
        console_show_option "${PTS_REQUIRE_CONTAINER}" "Container required"
    fi
    console_show_option "${PTS_PHPUNIT}" "PHPUnit"
    console_show_option "${PTS_PHPUNIT_COVERAGE}" "PHPUnit code coverage"
    console_show_option "${PTS_VAR_DUMP_CHECK}" "Check for var dumps"
    console_show_option "${PTS_MULTI}" "Multi-tester"
    console_show_option "${PTS_METRICS}" "PHPMetrics"
    console_show_option "${PTS_PHPMD}" "PHP mess detector"
    console_show_option "${PTS_PHPSTAN}" "PHPStan"
    console_show_option "${PTS_PSALM}" "Psalm"
    console_show_option "${PTS_PHP_SECURITY}" "Security checks"
    console_show_option "${PTS_CS}" "Code sniffer"
    console_show_option "${PTS_CS_BF}" "Code sniffer Beautifier"
    console_show_option "${PTS_DEPS_GRAPH}" "Dependencies graph"
    console_show_option "${PTS_UPDATE_CHANGELOG}" "Update changelog file"
    console_show_option "${PTS_GITATTRIBUTES_GENERATE}" "Generate .gitattributes file"
    console_dark ""
}

pts_read_options () {
    common_set_default_options
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
                __ALL_OPTION=${CR_TRUE} # __TOTAL_OPTION
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            -t | --total)
                debug_option "${__OPTION}" "${__VALUE}"
                __TOTAL_OPTION=${CR_TRUE}
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
                PTS_REQUIRE_CONTAINER=${CR_TRUE}
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
            --cl)
                debug_option "${__OPTION}" "${__VALUE}"
                PTS_CHANGELOG_TAGS="${__VALUE}"
                PTS_PHPUNIT=${CR_FALSE}
                PTS_UPDATE_CHANGELOG=${CR_TRUE}
                ;;
            --metrics)
                debug_option "${__OPTION}" "${__VALUE}"
                PTS_METRICS=${CR_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            --md)
                debug_option "${__OPTION}" "${__VALUE}"
                PTS_PHPMD=${CR_TRUE}
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
            --ga)
                debug_option "${__OPTION}" "${__VALUE}"
                PTS_GITATTRIBUTES_GENERATE=${CR_TRUE}
                PTS_PHPUNIT=${CR_FALSE}
                PTS_REQUIRE_CONTAINER=${CR_FALSE}
                # PTS_REQUIRE_ENVIRONMENT=${CR_FALSE}
                ;;
            -b | --beauty | --beautify)
                debug_option "${__OPTION}" "${__VALUE}"
                PTS_CS_BF=${CR_TRUE}
                PTS_PHPUNIT=${CR_FALSE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            --local)
                debug_option "${__OPTION}" "${__VALUE}"
                PTS_RUN_PRIORITY="local"
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
            # Undocumented
            --source-dir)
                debug_option "${__OPTION}" "${__VALUE}"
                export PTS_SOURCE_DIR="${__VALUE}"
                ;;
            *)
                common_read_option "pts_usage" "${__OPTION}$([ "${__VALUE}" != "" ] && echo "=${__VALUE}")"
                ;;
        esac
        shift
    done
    common_process_options
    common_export_options
    pts_process_options
    pts_export_options
    unset __OPTION __VALUE
}

pts_initialize_chglog_config () {
    console_debug "Changing line '${STB_REMOTE_REPO_URL}' to ${__remote}"
    __result="$(sed "s@${STB_REMOTE_REPO_URL}@${1}@g;" "${CHGLOG_CONFIG_FILE}")"
    echo "${__result}" > "${CHGLOG_CONFIG_FILE}"
    __result="$(sed 's/\\/\\\\/g;' "${CHGLOG_CONFIG_FILE}" > "${CHGLOG_CONFIG_FILE}.tmp" 2>&1)"
    if [ $? -ne "${CR_TRUE}" ]; then
        unset __result
        return "${CR_FALSE}"
    fi
    console_debug "$(mv -v "${CHGLOG_CONFIG_FILE}.tmp" "${CHGLOG_CONFIG_FILE}")"

    unset __result
    console_info "'${CHGLOG_CONFIG_FILE}' initialized"
    return "${CR_TRUE}"
}

pts_check_chglog_config () {
    __remote="$(git_get_remote_url)"
    if [ $? -ne "${CR_TRUE}" ]; then
        unset __remote
        return "${CR_FALSE}"
    fi
    console_debug "Remote: ${__remote}"
    if [ -e "${CHGLOG_CONFIG_FILE}" ]; then
        if [ "$(grep "${STB_REMOTE_REPO_URL}" "${CHGLOG_CONFIG_FILE}")" != "" ]; then
            console_error "${CHGLOG_CONFIG_FILE} is not initialized"
            console_debug "Change line ${STB_REMOTE_REPO_URL} to ${__remote}"
            if ! pts_initialize_chglog_config "${__remote}"; then
                unset __remote
                return "${CR_FALSE}"
            fi
        fi
    else
        console_error "git-chglog config not found"
        console_comment "To create config dir '.chglog' run 'git-chglog --init'"
        unset __remote
        return "${CR_FALSE}"
    fi
    unset __remote
    return "${CR_TRUE}"
}

_multi_tester_exec () {
    if [ "${PTS_MULTI}" -eq "${CR_TRUE}" ]; then
        console_section "Multi tester..."
        if ! docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app multi-tester
        then
            console_debug "Error occurred"
        fi
    fi
}

_var_dump_check_exec () {
    if [ "${PTS_VAR_DUMP_CHECK}" -eq "${CR_TRUE}" ]; then
        console_section "Checking for var dumps..."
        if [ "${CR_COLOR}" -eq "${CR_ENABLED}" ]; then
            __colors=""
        else    
            __colors=" --no-colors"
        fi
        __run_options="var-dump-check ${PTS_SOURCE_DIR}${__colors}"
        console_info "Providing checks in: ${PTS_SOURCE_DIR}"
        # shellcheck disable=SC2086
        if ! docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app ${__run_options}
        then
            console_debug "Error occurred"
        fi
        unset __run_options
    fi
}

_php_security_exec () {
    if [ "${PTS_PHP_SECURITY}" -eq "${CR_TRUE}" ]; then
        console_section "Sensiolabs security-checker..."
        if [ "${CR_COLOR}" -eq "${CR_ENABLED}" ]; then
            __colors="--ansi"
        else    
            __colors="--no-ansi"
        fi

        if ! docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app security-checker "${__colors}" security:check composer.lock
        then
            console_debug "Error occurred"
        fi
    fi
}

_phpstan_exec () {
    if [ "${PTS_PHPSTAN}" -eq "${CR_TRUE}" ]; then
        console_section "PHPStan..."
        if [ "${CR_COLOR}" -eq "${CR_ENABLED}" ]; then
            __colors="--ansi"
        else    
            __colors="--no-ansi"
        fi

        if docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpstan -V "${__colors}"
        then
            if [ -e "${PHPSTAN_PATHS_FILE}" ];then
                docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpstan analyze --paths-file="${PHPSTAN_PATHS_FILE}" --level="${PHPSTAN_LEVEL}" "${__colors}"
            else
                docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpstan analyze "${PTS_SOURCE_DIR}" --level="${PHPSTAN_LEVEL}" "${__colors}"
            fi
        fi
        unset __colors
    fi
}

_psalm_exec () {
    if [ "${PTS_PSALM}" -eq "${CR_TRUE}" ]; then
        console_section "Psalm..."
        if [ "${CR_COLOR}" -eq "${CR_ENABLED}" ]; then
            __colors=""
        else    
            __colors="-m"
        fi
        if [ -e "${WORK_DIR}/${PSALM_CONFIG}" ]
        then
            console_debug "Config file '${PSALM_CONFIG}' found"
        else
            console_comment "Config file '${PSALM_CONFIG}' not found"
            docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app psalm --init "${PTS_SOURCE_DIR}" "${PSALM_LEVEL}"
        fi
        if docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app psalm --version
        then
            docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app psalm "${__colors}"
        fi
        unset __colors
    fi
}

pts_update_changelog() {
    if [ "${PTS_UPDATE_CHANGELOG}" -eq "${CR_TRUE}" ]; then
        __git_chglog_command="git-chglog"
        if ! check_command "${__git_chglog_command}"; then
            console_error "'${__git_chglog_command}' is not installed"
            console_info "See https://github.com/git-chglog/git-chglog"
            return "${CR_FALSE}"
        fi
        console_debug "'${__git_chglog_command}' command exists"
        console_section "Update changelog..."
        if [ "${CR_COLOR}" -eq "${CR_ENABLED}" ]; then
            __colors=""
        else    
            __colors="--no-colors"
        fi
        if ! pts_check_chglog_config; then
            return "${CR_FALSE}"
        fi
        __result="$(${__git_chglog_command} -o "${_CHANGELOG_MD_FILE}" "${PTS_CHANGELOG_TAGS}" 2>&1)"
        if [ $? -eq "${CR_TRUE}" ]; then
            console_print "${__result}"
        else
            console_error "${__result}"
        fi
        unset __colors __git_chglog_command __result
    fi
}

_php_cs_exec () {
    if [ "${PTS_CS}" -eq "${CR_TRUE}" ]; then
        console_section "PHP Code Sniffer..."
        if [ "${CR_COLOR}" -eq "${CR_ENABLED}" ]; then
            __colors="--colors"
        else    
            __colors="--no-colors"
        fi
        if docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpcs --version "${__colors}"
        then
            docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpcs "${__colors}"
        fi
        unset __colors
    fi
}

_php_cs_bf_exec () {
    if [ "${PTS_CS_BF}" -eq "${CR_TRUE}" ]; then
        console_section "PHP Code Sniffer Beautifier..."
        if [ "${CR_COLOR}" -eq "${CR_ENABLED}" ]; then
            __colors="--colors"
        else    
            __colors="--no-colors"
        fi
        if docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpcbf --version "${__colors}"
        then
            docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpcbf "${__colors}"
        fi
        unset __colors
    fi
}

_php_metrics_exec () {
    if [ "${PTS_METRICS}" -eq "${CR_TRUE}" ]; then
        console_section "PHP Metrics..."
        if docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpmetrics --version
        then
            docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpmetrics --report-html="${PTS_PHPMETRICS_OUTPUT_DIR}" .
        fi
    fi
}

_php_md_exec () {
    if [ "${PTS_PHPMD}" -eq "${CR_TRUE}" ]; then
        console_section "PHP Mess Detector..."
        if docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpmd --version
        then
            docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpmd "${PTS_SOURCE_DIR}" html phpmd.xml --reportfile "${PTS_BUILD_DIR}/phpmd.html"
        fi
    fi
}

_phpunit_exec () {
    if [ "${PTS_PHPUNIT}" -eq "${CR_TRUE}" ]; then
        __php_version
        console_section "PHPUnit..."
        console_debug "Run with coverage: $(core_bool_to_string "${PTS_PHPUNIT_COVERAGE}")"
        console_debug "Debug image used: $(core_bool_to_string "${PTS_DEBUG_IMAGE_USED}")"
        if [ "${CR_COLOR}" -eq "${CR_ENABLED}" ]; then
            __colors="--colors=always"
        else    
            __colors="--colors=never"
        fi
        if [ "${PTS_PHPUNIT_COVERAGE}" -eq "${CR_TRUE}" ] && [ "${PTS_DEBUG_IMAGE_USED}" -eq "${CR_TRUE}" ]; then
            if [ -e "${PTS_XDEBUG_FILTER_FILE}" ]
            then
                console_info "Found XDEBUG Filter file..."
            else
                console_comment "Generating XDEBUG Filter..."
                docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpunit "${__colors}" --dump-xdebug-filter "${PTS_XDEBUG_FILTER_FILE}"
            fi
            console_debug "Run phpunit with coverage"
            docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpunit "${__colors}" --prepend "${PTS_XDEBUG_FILTER_FILE}" \
            --coverage-html "${PTS_PHPUNIT_COVERAGE_HTML_REPORT}" \
            --coverage-clover "${PTS_PHPUNIT_COVERAGE_CLOVER_REPORT}" \
            --coverage-text
        else 
            console_debug "Run phpunit WITHOUT coverage"
            docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpunit "${__colors}"
        fi
        unset __colors
    fi
}

__php_version () {
    console_section "PHP Version"
    docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app php -v
}

pts_generate_gitattributes () {
    if [ "${PTS_GITATTRIBUTES_GENERATE}" -eq "${CR_TRUE}" ]; then
        console_section "Generate .gitattributes file"
        if gitattributes_generate "${WORK_DIR}"
        then
            console_comment ".gitattributes file generated"
        fi
    fi
}

_php_dependency_graph () {
    if [ "${PTS_DEPS_GRAPH}" -eq "${CR_TRUE}" ]; then
        console_section "Dependency graph..."
        __project_name="$(core_get_project_name "${_COMPOSER_JSON_FILE}")"
        __VENDOR_NAME=$(echo "$__project_name" | awk -F/ '{print $1}')
        __PACKAGE_NAME=$(echo "$__project_name" | awk -F/ '{print $2}')

        console_debug "__VENDOR_NAME: ${__VENDOR_NAME}"
        console_debug "__PACKAGE_NAME: ${__PACKAGE_NAME}"

        if ! core_dir_exists "${PTS_DEP_GRAPHS_DIR}"; then
            console_debug "$(mkdir -pv "${PTS_DEP_GRAPHS_DIR}")"
        fi
        console_comment "Creating graph from 'composer.lock' file"
        __result="$(docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app dependency-graph from-lock)"
        if [ $? -eq "${CR_TRUE}" ];then
            console_debug "Command execution result was: ${__result}"
            console_debug "$(mv -v dependencies.svg "${PTS_DEP_GRAPHS_DIR}"/)"
        else 
            console_error "${__result}"
        fi
        console_comment "Creating current package graph: '${__project_name}' "
        __result="$(docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app dependency-graph of "${__project_name}")"
        if [ $? -eq "${CR_TRUE}" ];then
            console_debug "Command execution result was: ${__result}"
            console_debug "$(mv -v "${__VENDOR_NAME}"_"${__PACKAGE_NAME}"_dependencies.svg "${PTS_DEP_GRAPHS_DIR}"/)"
        else 
            console_error "${__result}"
        fi
        console_comment "Creating vendor graph: '${__VENDOR_NAME}' "
        __result="$(docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app dependency-graph vendor "${__VENDOR_NAME}")"
        if [ $? -eq "${CR_TRUE}" ];then
            console_debug "Command execution result was: ${__result}"
            console_debug "$(mv -v "${__VENDOR_NAME}".svg "${PTS_DEP_GRAPHS_DIR}"/)"
        else 
            console_error "${__result}"
        fi
        console_info ""
        console_info "Open '${PTS_TEST_REPORT_INDEX}' to see graphs"
        unset __result __project_name __VENDOR_NAME __PACKAGE_NAME
    fi
}