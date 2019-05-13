#!/usr/bin/env sh
if [ -z "${LIB_DIR:-}" ]; then
    echo "This script can not be runned standalone."
    exit 1
fi

_log_debug "PHPUnit launch script"
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


