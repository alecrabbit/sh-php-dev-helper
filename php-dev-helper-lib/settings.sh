#!/usr/bin/env sh
export PTS_UPDATER_TMP_DIR=".tmp"
export PTS_DEBUG_IMAGE="debug"
export PTS_SOURCE_DIR="src"
export PTS_TESTS_DIR="tests"

export AUX_DEV_MODULE="dev.sh"

export _DOCKER_COMPOSE_FILE="docker-compose.yml"
export _DOCKER_COMPOSE_FILE_DEBUG="docker-compose-debug.yml"

export PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE_DEBUG}"


export PHPSTAN_LEVEL=7
export PSALM_LEVEL=3
export PSALM_CONFIG="psalm.xml"
export PTS_TMP_DIR_PARTIAL="tmp"
export PTS_SOURCE_DIR="src"
export PTS_TMP_DIR="${PTS_TESTS_DIR}/${PTS_TMP_DIR_PARTIAL}"
export PTS_PHPMETRICS_DIR="phpmetrics"
export PTS_COVERAGE_DIR="coverage"
export PTS_PHPMETRICS_OUTPUT_DIR="${PTS_TMP_DIR}/${PTS_PHPMETRICS_DIR}"
export PTS_PHPUNIT_COVERAGE_HTML_REPORT="${PTS_TMP_DIR}/${PTS_COVERAGE_DIR}/html"
export PTS_PHPUNIT_COVERAGE_CLOVER_REPORT="${PTS_TMP_DIR}/${PTS_COVERAGE_DIR}/clover.xml"
export PTS_XDEBUG_FILTER_FILE="${PTS_TMP_DIR}/xdebug-filter.php"
export PTS_TEST_REPORT_INDEX="${PTS_TESTS_DIR}/report.html"
