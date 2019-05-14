#!/usr/bin/env sh
export PTS_DEBUG_IMAGE="debug"
export PTS_DOCKER_COMPOSE_FILE="docker-compose.yml"
export PTS_DOCKER_COMPOSE_DEBUG_FILE="docker-compose-debug.yml"

export PTS_TESTS_DIR="tests"
export PTS_TMP_DIR_PARTIAL="tmp"
export PTS_TMP_DIR="${PTS_TESTS_DIR}/${PTS_TMP_DIR_PARTIAL}"
export PTS_PHPMETRICS_DIR="phpmetrics"
export PTS_COVERAGE_DIR="coverage"
export PTS_PHPMETRICS_OUTPUT_DIR="${PTS_TMP_DIR}/${PTS_PHPMETRICS_DIR}"
export PTS_PHPUNIT_COVERAGE_HTML_REPORT="${PTS_TMP_DIR}/${PTS_COVERAGE_DIR}/html"
export PTS_PHPUNIT_COVERAGE_CLOVER_REPORT="${PTS_TMP_DIR}/${PTS_COVERAGE_DIR}/clover.xml"
export PTS_XDEBUG_FILTER_FILE="${PTS_TMP_DIR}/xdebug-filter.php"
