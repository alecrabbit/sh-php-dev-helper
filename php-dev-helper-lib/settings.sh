#!/usr/bin/env sh
export PTS_UPDATER_TMP_DIR=".tmp"
export PTS_DEBUG_IMAGE="debug"
export PTS_SOURCE_DIR="src"
export PTS_TESTS_DIR="tests"

export PTS_PHPMETRICS_DIR="phpmetrics"
export PTS_COVERAGE_DIR="coverage"

export PTS_AUX_DEV_MODULE="dev.sh"

__SETTINGS_FILE="${SCRIPT_DIR}/.sh-php-tests-settings"
export PTS_ALLOWED_DIRS_FILE="${SCRIPT_DIR}/.sh-php-tests-allowed-dirs"
export PTS_DISALLOWED_DIRS_FILE="${SCRIPT_DIR}/.sh-php-tests-disallowed-dirs"

export WORKING_PREFIX="php"

export _DOCKER_COMPOSE_FILE="docker-compose.yml"
export _DOCKER_COMPOSE_FILE_DEBUG="docker-compose-debug.yml"

export PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE_DEBUG}"

export PHPSTAN_LEVEL=7
export PSALM_LEVEL=3
export PSALM_CONFIG="psalm.xml"

export PTS_TMP_DIR_PARTIAL="tmp"
export PTS_TMP_DIR="${PTS_TESTS_DIR}/${PTS_TMP_DIR_PARTIAL}"
export PTS_PHPMETRICS_OUTPUT_DIR="${PTS_TMP_DIR}/${PTS_PHPMETRICS_DIR}"
export PTS_PHPUNIT_COVERAGE_HTML_REPORT="${PTS_TMP_DIR}/${PTS_COVERAGE_DIR}/html"
export PTS_PHPUNIT_COVERAGE_CLOVER_REPORT="${PTS_TMP_DIR}/${PTS_COVERAGE_DIR}/clover.xml"
export PTS_XDEBUG_FILTER_FILE="${PTS_TMP_DIR}/xdebug-filter.php"
export PTS_TEST_REPORT_INDEX="${PTS_TESTS_DIR}/report.html"

export VERSION_FILE="${LIB_DIR:-.}/VERSION"
export BUILD_FILE="${LIB_DIR:-.}/BUILD"
export DEFAULT_SCRIPT_NAME="php-dev-helper"

export PDH_PACKAGE="sh-php-dev-helper"
export PDH_REPOSITORY="alecrabbit/${PDH_PACKAGE}"


_SETTINGS_ENABLED='enabled'
_SETTINGS_DISABLED='disabled'

__show_error () {
    console_error "Unrecognized value '${1}=${2}', using default '${1}=${3}'"
}

_settings_check_variables () {
    console_debug "Checking settings"
    # DIR_CONTROL Directory access control engine
    DIR_CONTROL=${DIR_CONTROL:-${CR_DISABLED}}
    case ${DIR_CONTROL} in
        ${CR_ENABLED} | ${CR_DISABLED}) ;; # do nothing
        ${_SETTINGS_ENABLED})
            DIR_CONTROL=${CR_ENABLED}
            ;;
        ${_SETTINGS_DISABLED})
            DIR_CONTROL=${CR_DISABLED}
            ;;
        *)
            __show_error "DIR_CONTROL" "${DIR_CONTROL}" ${_SETTINGS_DISABLED}
            DIR_CONTROL=${CR_DISABLED}
            ;;
    esac
    core_show_used_value "DIR_CONTROL" "${DIR_CONTROL}"
    # USE_DIR_PREFIX Directory access control assumes that 'php' in dir name is a go
    USE_DIR_PREFIX=${USE_DIR_PREFIX:-${CR_DISABLED}}
    case ${USE_DIR_PREFIX:-${CR_DISABLED}} in
        ${CR_ENABLED} | ${CR_DISABLED}) ;; # do nothing
        ${_SETTINGS_ENABLED})
            USE_DIR_PREFIX=${CR_ENABLED}
            ;;
        ${_SETTINGS_DISABLED})
            USE_DIR_PREFIX=${CR_DISABLED}
            ;;
        *)
            __show_error "USE_DIR_PREFIX" "${USE_DIR_PREFIX}" ${_SETTINGS_DISABLED}
            USE_DIR_PREFIX=${CR_DISABLED}
            ;;
   esac
   core_show_used_value "USE_DIR_PREFIX" "${USE_DIR_PREFIX}"

}

### LOAD SETTINGS FROM FILE
if [ -e "${__SETTINGS_FILE}" ]
then
    # shellcheck disable=SC1090
    . "${__SETTINGS_FILE}"
fi

### CHECK LOADED SETTINGS
_settings_check_variables