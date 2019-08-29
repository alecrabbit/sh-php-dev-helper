#!/usr/bin/env sh
export INSTALL_SCRIPT_NAME="install"
export STB_REMOTE_REPO_URL="<PACKAGE_REMOTE_REPOSITORY>"

export PTS_UPDATER_TMP_DIR=".pts_updater_tmp"
export PTS_DEBUG_IMAGE="debug"
export PTS_SOURCE_DIR="src"
export PTS_TESTS_DIR="tests"
export PTS_BUILD_DIR="build"

export PTS_PHPMETRICS_DIR="phpmetrics"
export PTS_COVERAGE_DIR="coverage"
export PTS_GRAPHS_DIR="graphs"

export PTS_AUX_DEV_MODULE="dev.sh"

export SETTINGS_DIR="${LIB_DIR}/.settings"
__SETTINGS_FILE="${SETTINGS_DIR}/.sh-pdh-settings"
export PTS_SETTINGS_FILE="${SETTINGS_DIR}/.pts_settings"
export PTS_ALLOWED_DIRS_FILE="${SETTINGS_DIR}/.sh-pdh-allowed-dirs"
export PTS_DISALLOWED_DIRS_FILE="${SETTINGS_DIR}/.sh-pdh-disallowed-dirs"

export WORKING_PREFIX="php"

export _COMPOSER_JSON_FILE="composer.json"
export _CHANGELOG_MD_FILE="CHANGELOG.md"
export _DOCKER_COMPOSE_FILE="docker-compose.yml"
export _DOCKER_COMPOSE_FILE_DEBUG="docker-compose-debug.yml"

export PTS_DOCKER_COMPOSE_FILE="${_DOCKER_COMPOSE_FILE_DEBUG}"

export PHPSTAN_LEVEL=7
export PHPSTAN_PATHS_FILE="phpstan.paths"
export PSALM_LEVEL=3
export PSALM_CONFIG="psalm.xml"

export PTS_TMP_DIR_PARTIAL="tmp"
export PTS_TMP_DIR="${PTS_TESTS_DIR}/${PTS_TMP_DIR_PARTIAL}"
export PTS_PHPMETRICS_OUTPUT_DIR="${PTS_BUILD_DIR}/${PTS_PHPMETRICS_DIR}"
export PTS_DEP_GRAPHS_DIR="${PTS_BUILD_DIR}/${PTS_GRAPHS_DIR}"
export PTS_PHPUNIT_COVERAGE_HTML_REPORT="${PTS_BUILD_DIR}/${PTS_COVERAGE_DIR}/html"
export PTS_PHPUNIT_COVERAGE_CLOVER_REPORT="${PTS_BUILD_DIR}/${PTS_COVERAGE_DIR}/clover.xml"
export PTS_XDEBUG_FILTER_FILE="${PTS_BUILD_DIR}/xdebug-filter.php"
export PTS_TEST_REPORT_INDEX="${PTS_BUILD_DIR}/report.html"

export VERSION_FILE="${LIB_DIR:-.}/VERSION"
export BUILD_FILE="${LIB_DIR:-.}/BUILD"
export DEFAULT_SCRIPT_NAME="php-dev-helper"

export PDH_PACKAGE="sh-php-dev-helper"
export PDH_REPOSITORY="alecrabbit/${PDH_PACKAGE}"

_SETTING_ENABLED='enabled'
_SETTING_DISABLED='disabled'

__show_error () {
    console_error "Unrecognized value '${1}=${2}', using default '${1}=${3}'"
}

_settings_check_variables () {
    console_debug "Checking settings"
    # CR_COLOR Color settings
    CR_COLOR=${COLOR:-${CR_ENABLED}}
    case ${CR_COLOR} in
        ${CR_ENABLED} | ${CR_DISABLED}) ;; # do nothing
        ${_SETTING_ENABLED})
            CR_COLOR=${CR_ENABLED}
            ;;
        ${_SETTING_DISABLED})
            CR_COLOR=${CR_DISABLED}
            ;;
        *)
            __show_error "CR_COLOR" "${CR_COLOR}" ${_SETTING_DISABLED}
            CR_COLOR=${CR_DISABLED}
            ;;
    esac
    core_show_used_value "CR_COLOR" "${CR_COLOR}"
    # DIR_CONTROL Directory access control engine
    DIR_CONTROL=${DIR_CONTROL:-${CR_DISABLED}}
    case ${DIR_CONTROL} in
        ${CR_ENABLED} | ${CR_DISABLED}) ;; # do nothing
        ${_SETTING_ENABLED})
            DIR_CONTROL=${CR_ENABLED}
            ;;
        ${_SETTING_DISABLED})
            DIR_CONTROL=${CR_DISABLED}
            ;;
        *)
            __show_error "DIR_CONTROL" "${DIR_CONTROL}" ${_SETTING_DISABLED}
            DIR_CONTROL=${CR_DISABLED}
            ;;
    esac
    core_show_used_value "DIR_CONTROL" "${DIR_CONTROL}"
    # USE_DIR_PREFIX Directory access control assumes that 'php' in dir name is a go
    USE_DIR_PREFIX=${USE_DIR_PREFIX:-${CR_DISABLED}}
    case ${USE_DIR_PREFIX:-${CR_DISABLED}} in
        ${CR_ENABLED} | ${CR_DISABLED}) ;; # do nothing
        ${_SETTING_ENABLED})
            USE_DIR_PREFIX=${CR_ENABLED}
            ;;
        ${_SETTING_DISABLED})
            USE_DIR_PREFIX=${CR_DISABLED}
            ;;
        *)
            __show_error "USE_DIR_PREFIX" "${USE_DIR_PREFIX}" ${_SETTING_DISABLED}
            USE_DIR_PREFIX=${CR_DISABLED}
            ;;
    esac
    core_show_used_value "USE_DIR_PREFIX" "${USE_DIR_PREFIX}"
    # EMOJIS
    CR_EMOJIS=${EMOJIS:-${CR_ENABLED}}
    case ${EMOJIS:-${CR_DISABLED}} in
        ${CR_ENABLED} | ${CR_DISABLED}) ;; # do nothing
        ${_SETTING_ENABLED})
            CR_EMOJIS=${CR_ENABLED}
            ;;
        ${_SETTING_DISABLED})
            CR_EMOJIS=${CR_DISABLED}
            ;;
        *)
            __show_error "EMOJIS" "${EMOJIS}" ${_SETTING_ENABLED}
            CR_EMOJIS=${CR_ENABLED}
            ;;
    esac
    core_show_used_value "EMOJIS" "${CR_EMOJIS}"
    # DEBUG
    CR_DEBUG=${CR_DEBUG:-${DEBUG:-${CR_DISABLED}}}
    case ${CR_DEBUG:-${CR_DISABLED}} in
        ${CR_ENABLED} | ${CR_DISABLED}) ;; # do nothing
        ${_SETTING_ENABLED})
            CR_DEBUG=${CR_ENABLED}
            ;;
        ${_SETTING_DISABLED})
            CR_DEBUG=${CR_DISABLED}
            ;;
        *)
            __show_error "DEBUG" "${DEBUG}" ${_SETTING_DISABLED}
            CR_DEBUG=${CR_DISABLED}
            ;;
    esac
    core_show_used_value "DEBUG" "${CR_DEBUG}"
    # TITLE Change terminal title while running
    CR_TITLE=${TITLE:-${CR_ENABLED}}
    case ${TITLE:-${CR_DISABLED}} in
        ${CR_ENABLED} | ${CR_DISABLED}) ;; # do nothing
        ${_SETTING_ENABLED})
            CR_TITLE=${CR_ENABLED}
            ;;
        ${_SETTING_DISABLED})
            CR_TITLE=${CR_DISABLED}
            ;;
        *)
            __show_error "TITLE" "${TITLE}" ${_SETTING_ENABLED}
            CR_TITLE=${CR_ENABLED}
            ;;
    esac
    core_show_used_value "TITLE" "${CR_TITLE}"
    # ALLOW_ROOT Allow run under root
    CR_ALLOW_ROOT=${ALLOW_ROOT:-${CR_DISABLED}}
    case ${ALLOW_ROOT:-${CR_DISABLED}} in
        ${CR_ENABLED} | ${CR_DISABLED}) ;; # do nothing
        ${_SETTING_ENABLED})
            CR_ALLOW_ROOT=${CR_ENABLED}
            ;;
        ${_SETTING_DISABLED})
            CR_ALLOW_ROOT=${CR_DISABLED}
            ;;
        *)
            __show_error "ALLOW_ROOT" "${ALLOW_ROOT}" ${_SETTING_DISABLED}
            CR_ALLOW_ROOT=${CR_DISABLED}
            ;;
    esac
    core_show_used_value "ALLOW_ROOT" "${CR_ALLOW_ROOT}"
}

### LOAD SETTINGS FROM FILE
if [ -e "${__SETTINGS_FILE}" ]
then
    # shellcheck disable=SC1090
    . "${__SETTINGS_FILE}"
fi

### CHECK LOADED SETTINGS
_settings_check_variables

### Emojis
if [ "${CR_EMOJIS}" -eq "${CR_ENABLED}" ];then
    export EMOJI_WARNING="⚠️  "
    export EMOJI_ERROR="🛑 "
    export EMOJI_FATAL="🔥 "
    export EMOJI_RABBIT="🐇 "
    export EMOJI_ROCKET="🚀 "
    export EMOJI_CHECKED_FLAG="🏁 "
    export EMOJI_CANCELED="❌ "
    export EMOJI_CHECK="✔️ "
    export EMOJI_NEW="🆕 " 
else
    export EMOJI_WARNING=""
    export EMOJI_ERROR=""
    export EMOJI_FATAL=""
    export EMOJI_RABBIT=""
    export EMOJI_ROCKET=""
    export EMOJI_CHECKED_FLAG=""
    export EMOJI_CANCELED=""
    export EMOJI_CHECK=""
    export EMOJI_NEW="" 
fi

### Color
# Options are 'never', 'always', or 'auto'
if [ "${CR_COLOR}" -eq "${CR_ENABLED}" ];then
    colored_configureColor "auto"
    console_debug "Using color: auto"
else
    colored_configureColor "never" 
fi
