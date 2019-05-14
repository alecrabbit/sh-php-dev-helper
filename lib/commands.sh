#!/usr/bin/env sh
if [ -z "${LIB_DIR:-}" ]; then
    echo "This script can not be runned standalone."
    exit 1
fi

_phpunit_exec () {
    _log_debug "Running PHPUnit launch"
    if [ "${PTS_PHPUNIT}" -eq "${PTS_TRUE}" ]
    then
        _log_print "$(_color_green "PHP Version:")\n$(__php_version)"
        if [ "${PTS_PHPUNIT_COVERAGE}" -eq "${PTS_TRUE}" ] && [ "${_DEBUG_IMAGE_USED}" -eq "${PTS_TRUE}" ];
        then
            if [ -e "${PTS_XDEBUG_FILTER_FILE}" ]
            then
                _log_info "Found XDEBUG Filter file..."
            else
                _log_comment "Generating XDEBUG Filter..."
                docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpunit --dump-xdebug-filter "${PTS_XDEBUG_FILTER_FILE}"
            fi
            _log_notice "run phpunit with coverage"
            docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpunit --prepend "${PTS_XDEBUG_FILTER_FILE}" \
            --coverage-html "${PTS_PHPUNIT_COVERAGE_HTML_REPORT}" \
            --coverage-clover "${PTS_PHPUNIT_COVERAGE_CLOVER_REPORT}" \
            --coverage-text
        else 
            _log_warn "run phpunit WITHOUT coverage"
            docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app phpunit
        fi
    fi
}

__php_version () {
    docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app php -v
}
