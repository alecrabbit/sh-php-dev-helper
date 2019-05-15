#!/usr/bin/env sh
__usage () {
    echo "Usage:"
    echo "    $(_color_bold "${SCRIPT_NAME}") [options]"
    echo "Options:"
    echo "    $(_color_yellow "-a, --all")             - launch all tests"
    # echo "    $(_color_yellow "--no-restart")          - do not restart container(s)"
    echo "    $(_color_yellow "-b, --beauty")          - enable php code sniffer beautifier"
    echo "    $(_color_yellow "-c, --coverage")        - enable phpunit code coverage"
    echo "    $(_color_yellow "--cs")                  - enable php code sniffer"
    echo "    $(_color_yellow "--metrics")             - enable phpmetrics"
    echo "    $(_color_yellow "--multi")               - enable multi-tester"
    echo "    $(_color_yellow "--phpstan")             - enable phpstan"
    echo "    $(_color_yellow "--psalm")               - enable psalm"
    echo "    $(_color_yellow "-s, --analyze")         - enable static analysis tools"
    echo "    $(_color_yellow "-u, --unit")            - enable phpunit"
    echo
    # shellcheck disable=SC2005
    echo "$(_color_dark "Note: options order is important")"
}

__set_default_options () {
    PTS_EXECUTE=${PTS_TRUE}
    PTS_REQUIRE_DEBUG_IMAGE=${PTS_FALSE}
    PTS_RESTART=${PTS_FALSE}
    PTS_ANALYSIS=${PTS_FALSE}
    PTS_METRICS=${PTS_FALSE}
    PTS_MULTI=${PTS_FALSE}
    PTS_CS=${PTS_FALSE}
    PTS_CS_BF=${PTS_FALSE}
    PTS_PHPSTAN=${PTS_FALSE}
    PTS_PSALM=${PTS_FALSE}
    PTS_PHPUNIT=${PTS_TRUE}
    PTS_PHPUNIT_COVERAGE=${PTS_FALSE}
    __ALL_OPTION=${PTS_FALSE}
}

__process_options () {
    if [ "${PTS_ANALYSIS}" -eq "${PTS_TRUE}" ]; then
        PTS_PHPUNIT=${PTS_FALSE}
        PTS_PHPSTAN=${PTS_TRUE}
        PTS_PSALM=${PTS_TRUE}
    fi
    if [ "${__ALL_OPTION}" -eq "${PTS_TRUE}" ]; then
        PTS_CS=${PTS_TRUE}
        PTS_CS_BF=${PTS_TRUE}
        PTS_PHPSTAN=${PTS_TRUE}
        PTS_PSALM=${PTS_TRUE}
        PTS_PHPUNIT=${PTS_TRUE}
        PTS_PHPUNIT_COVERAGE=${PTS_TRUE}
    fi
}

__export_options () {
    export PTS_EXECUTE
    export PTS_REQUIRE_DEBUG_IMAGE
    export PTS_RESTART
    export PTS_ANALYSIS
    export PTS_METRICS
    export PTS_MULTI
    export PTS_CS
    export PTS_CS_BF
    export PTS_PHPSTAN
    export PTS_PSALM
    export PTS_PHPUNIT
    export PTS_PHPUNIT_COVERAGE
}

_show_options () {
    _log_debug "Show selected options:"
    if [ "${PTS_DEBUG}" -eq 1 ]
    then
        _show_option "${PTS_EXECUTE}" "Execute"
        _show_option "${PTS_ANALYSIS}" "Analysis"
        _show_option "${PTS_RESTART}" "Container restart"
    fi
    _show_option "${PTS_PHPSTAN}" "PHPStan"
    _show_option "${PTS_PSALM}" "Psalm"
    _show_option "${PTS_CS}" "Code sniffer"
    _show_option "${PTS_CS_BF}" "Code sniffer Beautifier"
    _show_option "${PTS_PHPUNIT}" "PHPUnit"
    _show_option "${PTS_PHPUNIT_COVERAGE}" "PHPUnit code coverage"
    _show_option "${PTS_METRICS}" "PHPMetrics"
    _show_option "${PTS_MULTI}" "Multi-tester"
}

_read_options () {
    __set_default_options
    _log_debug "Reading options"
    while [ "${1:-}" != "" ]; do
        PARAM=$(echo "$1" | awk -F= '{print $1}')
        VALUE=$(echo "$1" | awk -F= '{print $2}')
        case $PARAM in
            -h | --help)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                __usage
                exit
                ;;
            --update)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                updater_run
                exit
                ;;
            -V | --version)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                _log_print "${SCRIPT_NAME:-unknown} version $(_version "${PTS_TRUE}")"
                exit "${PTS_TRUE}"
                ;;
            # Undocumented
            --save-build-hash)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                version_save_build_hash
                exit "${PTS_TRUE}"
                ;;
            # Undocumented
            --no-exec)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_EXECUTE=${PTS_FALSE}
                ;;
            -a | --all)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                __ALL_OPTION=${PTS_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${PTS_TRUE}
                ;;
            -s | --analyze)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_ANALYSIS=${PTS_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${PTS_TRUE}
                ;;
            -u | --unit)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_PHPUNIT=${PTS_TRUE}
                ;;
            -c | --coverage)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_PHPUNIT_COVERAGE=${PTS_TRUE}
                PTS_PHPUNIT=${PTS_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${PTS_TRUE}
                ;;
            --metrics)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_METRICS=${PTS_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${PTS_TRUE}
                ;;
            --phpstan)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_PHPSTAN=${PTS_TRUE}
                PTS_PHPUNIT=${PTS_FALSE}
                PTS_REQUIRE_DEBUG_IMAGE=${PTS_TRUE}
                ;;
            --psalm)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_PSALM=${PTS_TRUE}
                PTS_PHPUNIT=${PTS_FALSE}
                PTS_REQUIRE_DEBUG_IMAGE=${PTS_TRUE}
                ;;
            --cs)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_CS=${PTS_TRUE}
                PTS_PHPUNIT=${PTS_FALSE}
                PTS_REQUIRE_DEBUG_IMAGE=${PTS_TRUE}
                ;;
            --multi)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_MULTI=${PTS_TRUE}
                ;;
            -b | --beauty | --beautify)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_CS_BF=${PTS_TRUE}
                PTS_PHPUNIT=${PTS_FALSE}
                PTS_REQUIRE_DEBUG_IMAGE=${PTS_TRUE}
                ;;
            --no-restart)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_RESTART=${PTS_FALSE}
                ;;
            --debug)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_DEBUG=1
                ;;
            # -y)
            #     _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
            #     ;;
            *)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                _log_error "Unknown option '${PARAM}'"
                __usage
                exit 1
                ;;
        esac
        shift
    done
    __process_options
    __export_options
    unset PARAM VALUE
}