#!/usr/bin/env sh
if [ -z "${LIB_DIR:-}" ]; then
    echo "This script can not run standalone."
    exit 1
fi

_multi_tester_exec () {
    if [ "${PTS_MULTI}" -eq "${PTS_TRUE}" ]; then
        console_log_info "Multi tester..."
        if ! docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app multi-tester
        then
            console_log_debug "Error occurred"
        fi
    fi
}

_phpstan_exec () {
    if [ "${PTS_PHPSTAN}" -eq "${PTS_TRUE}" ]; then
        console_log_info "PHPStan..."
        if docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpstan -V
        then
            docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpstan analyze "${PTS_SOURCE_DIR}" --level="${PHPSTAN_LEVEL}"
        fi
    fi
}

_psalm_exec () {
    if [ "${PTS_PHPSTAN}" -eq "${PTS_TRUE}" ]; then
        console_log_info "Psalm..."
        if [ -e "${WORK_DIR}/${PSALM_CONFIG}" ]
        then
            console_log_debug "Config file '${PSALM_CONFIG}' found"
        else
            console_log_comment "Config file '${PSALM_CONFIG}' not found"
            docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app psalm --init "${PTS_SOURCE_DIR}" "${PSALM_LEVEL}"
        fi
        if docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app psalm --version
        then
            docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app psalm
        fi
    fi
}

# PSALM_CONFIG="./../psalm.xml"
# PSALM_LEVEL=3

# if [[ -e ${PSALM_CONFIG} ]]
# then
#   comment "Psalm config found..."
# else
#   comment "Creating psalm config..."
#   if [[ ${EXEC} == 1  ]]
#     then
#       docker-compose -f ${DOCKER_COMPOSE_FILE} exec app psalm --init ${SOURCE_DIR} ${PSALM_LEVEL}
#     else
#       no-exec
#   fi
# fi

# info "Psalm..."
# docker-compose -f ${DOCKER_COMPOSE_FILE} exec app psalm --version
# if [[ ${EXEC} == 1 ]]
# then
#     if [[ -z "$@" ]]
#     then
#         docker-compose -f ${DOCKER_COMPOSE_FILE} exec app psalm
#     else
#         docker-compose -f ${DOCKER_COMPOSE_FILE} exec app psalm "$@"
#     fi
# else
#   no-exec
# fi

_php_cs_exec () {
    if [ "${PTS_CS}" -eq "${PTS_TRUE}" ]; then
        console_log_info "PHP Code Sniffer..."
        if docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpcs --version
        then
            docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpcs
        fi
    fi
}

_php_cs_bf_exec () {
    if [ "${PTS_CS_BF}" -eq "${PTS_TRUE}" ]; then
        console_log_info "PHP Code Sniffer Beautifier..."
        if docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpcbf --version
        then
            docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpcbf
        fi
    fi
}

_php_metrics_exec () {
    if [ "${PTS_METRICS}" -eq "${PTS_TRUE}" ]; then
        console_log_info "PHP Metrics..."
        if docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpmetrics --version
        then
            docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpmetrics --report-html="${PTS_PHPMETRICS_OUTPUT_DIR}" .
        fi
    fi
}

_phpunit_exec () {
    console_log_debug "Running PHPUnit"
    if [ "${PTS_PHPUNIT}" -eq "${PTS_TRUE}" ]; then
        console_log_print "$(colored_green "PHP Version:")\n$(__php_version)"
        console_log_info "PHPUnit..."
        console_log_debug "Run with coverage: $(core_int_to_string "${PTS_PHPUNIT_COVERAGE}")"
        console_log_debug "Debug image used: $(core_int_to_string "${PTS_DEBUG_IMAGE_USED}")"
        if [ "${PTS_PHPUNIT_COVERAGE}" -eq "${PTS_TRUE}" ] && [ "${PTS_DEBUG_IMAGE_USED}" -eq "${PTS_TRUE}" ]; then
            if [ -e "${PTS_XDEBUG_FILTER_FILE}" ]
            then
                console_log_info "Found XDEBUG Filter file..."
            else
                console_log_comment "Generating XDEBUG Filter..."
                docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpunit --dump-xdebug-filter "${PTS_XDEBUG_FILTER_FILE}"
            fi
            console_log_debug "Run phpunit with coverage"
            docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpunit --prepend "${PTS_XDEBUG_FILTER_FILE}" \
            --coverage-html "${PTS_PHPUNIT_COVERAGE_HTML_REPORT}" \
            --coverage-clover "${PTS_PHPUNIT_COVERAGE_CLOVER_REPORT}" \
            --coverage-text
        else 
            console_log_debug "Run phpunit WITHOUT coverage"
            docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpunit
        fi
    fi
}

__php_version () {
    docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app php -v
}
