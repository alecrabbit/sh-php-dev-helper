#!/usr/bin/env sh
__usage () {
    echo "Usage:"
    echo "    $(_color_bold "${SCRIPT_NAME}") [options]"
    echo "Options:"
    echo "    $(_color_yellow "-a, --all")             - launch all tests"
    # echo "    $(_color_yellow "--no-restart")          - do not restart container(s)"
    echo "    $(_color_yellow "-s, --analyze")         - enable static analysis tools"
    echo "    $(_color_yellow "-b, --beauty")          - enable php_cs sniffer and beautifier"
    echo "    $(_color_yellow "-c, --coverage")        - enable code coverage"
    echo "    $(_color_yellow "--metrics")             - enable phpmetrics"
    echo "    $(_color_yellow "--multi")               - enable multi-tester"
    echo "    $(_color_yellow "-u, --unit")            - enable phpunit"
}

__set_default_options () {
    PTS_EXECUTE=${PTS_TRUE}
    PTS_REQUIRE_DEBUG_IMAGE=${PTS_FALSE}
    PTS_RESTART=${PTS_FALSE}
    PTS_ANALYSIS=${PTS_FALSE}
    PTS_METRICS=${PTS_FALSE}
    PTS_MULTI=${PTS_FALSE}
    PTS_CS=${PTS_FALSE}
    PTS_BEAUTY=${PTS_FALSE}
    PTS_PHPUNIT=${PTS_TRUE}
    PTS_PHPUNIT_COVERAGE=${PTS_FALSE}
    __ALL_OPTION=${PTS_FALSE}
}

__process_options () {
    if [ "${PTS_ANALYSIS}" -eq "${PTS_TRUE}" ]; then
        PTS_CS=${PTS_TRUE}
        PTS_BEAUTY=${PTS_TRUE}
    fi
    if [ "${__ALL_OPTION}" -eq "${PTS_TRUE}" ]; then
        PTS_CS=${PTS_TRUE}
        PTS_BEAUTY=${PTS_TRUE}
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
    export PTS_BEAUTY
    export PTS_PHPUNIT
    export PTS_PHPUNIT_COVERAGE
}

_show_options () {
    if [ "${PTS_DEBUG}" -eq 1 ]
    then
        _show_option "${PTS_EXECUTE}" "Execute"
        _show_option "${PTS_REQUIRE_DEBUG_IMAGE}" "Debug image required"
        _show_option "${PTS_ANALYSIS}" "Analysis"
        _show_option "${PTS_RESTART}" "Container restart"
   fi
    _show_option "${PTS_METRICS}" "PHPMetrics"
    _show_option "${PTS_MULTI}" "Multi-tester"
    _show_option "${PTS_CS}" "Code sniffer"
    _show_option "${PTS_BEAUTY}" "Beautifier"
    _show_option "${PTS_PHPUNIT}" "PHPUnit"
    _show_option "${PTS_PHPUNIT_COVERAGE}" "Code coverage"
}

_read_options () {
    __set_default_options
    _log_debug "Reading options"
    while [ "${1:-}" != "" ]; do
        PARAM=$(echo "$1" | awk -F= '{print $1}')
        VALUE=$(echo "$1" | awk -F= '{print $2}')
        case $PARAM in
            -h | --help)
                __usage
                exit
                ;;
            -V | --version)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                _log_print "${SCRIPT_NAME:-unknown} version $(_version)"
                exit "${PTS_TRUE}"
                ;;
            # Undocumented
            --save-build-hash)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                _BUILD="$(_get_git_hash)"
                if [ "${_BUILD}" != "" ]
                then
                    echo "${_BUILD}" > "${LIB_DIR:-.}/BUILD"
                    _log_debug "Saved build hash '${_BUILD}' to '${LIB_DIR:-.}/BUILD'"
                fi
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
                PTS_REQUIRE_DEBUG_IMAGE=${PTS_TRUE}
                ;;
            --metrics)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_METRICS=${PTS_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${PTS_TRUE}
                ;;
            --multi)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_MULTI=${PTS_TRUE}
                ;;
            -b | --beauty | --beautify)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_BEAUTY=${PTS_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${PTS_TRUE}
                ;;
            --no-restart)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_RESTART=${PTS_FALSE}
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