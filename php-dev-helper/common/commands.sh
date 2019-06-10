#!/usr/bin/env sh

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
        console_info "Proving checks in: ${PTS_SOURCE_DIR}"
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
            docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpstan analyze "${PTS_SOURCE_DIR}" --level="${PHPSTAN_LEVEL}" "${__colors}"
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
        console_section "Update changelog..."
        if [ "${CR_COLOR}" -eq "${CR_ENABLED}" ]; then
            __colors=""
        else    
            __colors="--no-colors"
        fi
        __git_chglog_command="git-chglog"
        if check_command "${__git_chglog_command}"; then
            console_debug "'${__git_chglog_command}' command exists"
            __result="$(${__git_chglog_command} -o "${_CHANGELOG_MD_FILE}" 2>&1)"
            if [ $? -eq "${CR_TRUE}" ]; then
                console_debug "\n${__result}"
                console_comment "'${_CHANGELOG_MD_FILE}' generated"
            else
                console_error "${__result}"
                console_comment "To create config dir '.chglog' run '${__git_chglog_command} --init'"
            fi
        else
            console_error "'${__git_chglog_command}' is not installed"
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