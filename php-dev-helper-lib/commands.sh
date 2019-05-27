#!/usr/bin/env sh
if [ -z "${LIB_DIR:-}" ]; then
    echo "This script can not run standalone."
    exit 1
fi

_multi_tester_exec () {
    if [ "${PTS_MULTI}" -eq "${CR_TRUE}" ]; then
        console_section "Multi tester..."
        if ! docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app multi-tester
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
    console_debug "Running PHPUnit"
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
