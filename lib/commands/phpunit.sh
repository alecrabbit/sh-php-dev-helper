#!/usr/bin/env sh
if [ -z "${LIB_DIR:-}" ]; then
    echo "This script can not be runned standalone."
    exit 1
fi

_phpunit_exec () {
    if [ "${PTS_EXECUTE}" -eq "${PTS_TRUE}" ] 
    then
        if [ "${PTS_PHPUNIT}" -eq "${PTS_TRUE}" ]
        then
            _log_debug "PHPUnit launch script"
            _log_print "$(_color_dark "PHP Version:")\n$(__php_version)"
        fi
    fi
    unset __version
}

__php_version () {
    docker-compose -f "${PTS_DOCKER_COMPOSE_FILE}" exec app php -v
}
# info "PhpUnit..."
# if [[ ${EXEC} == 1 ]]
# then
#   if [[ ${COVERAGE} == 1 ]]
#   then
#     if [[ -e "./../${XDEBUG_FILTER_FILE}" ]]
#     then
#         info "Found XDEBUG Filter file..."
#     else
#         comment "Generating XDEBUG Filter..."
#         docker-compose -f ${DOCKER_COMPOSE_FILE} exec app phpunit --dump-xdebug-filter ${XDEBUG_FILTER_FILE}
#     fi
#     comment "Running tests with coverage..."
#     docker-compose -f ${DOCKER_COMPOSE_FILE} exec app phpunit --prepend ${XDEBUG_FILTER_FILE} \
#         --coverage-html ${PHPUNIT_COVERAGE_HTML_REPORT} \
#         --coverage-clover ${PHPUNIT_COVERAGE_CLOVER_REPORT} \
#         --coverage-text
#   else
#     if [[ -z "$@" ]]
#     then
#         comment "Running tests..."
#     fi
#     docker-compose -f ${DOCKER_COMPOSE_FILE} exec app phpunit "$@"
#   fi
# else
#   no-exec
# fi


