#!/usr/bin/env sh
__usage () {
    echo "Usage:"
    echo "    $(colored_bold "${SCRIPT_NAME}") [options]"
    echo "Options:"
    echo "    $(colored_yellow "-h")                    - show help message and exit"
    echo "    $(colored_yellow "-a, --all")             - run all (not includes --metrics and --multi)"
    # echo "    $(colored_yellow "--no-restart")          - do not restart container(s)"
    echo "    $(colored_yellow "-b, --beauty")          - enable php code sniffer beautifier"
    echo "    $(colored_yellow "-c, --coverage")        - enable phpunit code coverage (includes -u)"
    echo "    $(colored_yellow "--cs")                  - enable php code sniffer"
    echo "    $(colored_yellow "--metrics")             - enable phpmetrics"
    echo "    $(colored_yellow "--multi")               - enable multi-tester"
    echo "    $(colored_yellow "--phpstan")             - enable phpstan"
    echo "    $(colored_yellow "--psalm")               - enable psalm"
    echo "    $(colored_yellow "-s, --analyze")         - enable static analysis tools"
    echo "    $(colored_yellow "-u, --unit")            - enable phpunit"
    echo "    $(colored_yellow "--update")              - update script"
    echo
    # shellcheck disable=SC2005
    echo "$(colored_dark "Note: options order is important")"
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
    console_dark "\nSelected options:"
    if [ "${PTS_DEBUG}" -eq 1 ]
    then
        _show_option "${PTS_EXECUTE}" "Execute"
        _show_option "${PTS_ANALYSIS}" "Analysis"
        _show_option "${PTS_RESTART}" "Container restart"
    fi
    _show_option "${PTS_PHPUNIT}" "PHPUnit"
    _show_option "${PTS_PHPUNIT_COVERAGE}" "PHPUnit code coverage"
    _show_option "${PTS_MULTI}" "Multi-tester"
    _show_option "${PTS_METRICS}" "PHPMetrics"
    _show_option "${PTS_PHPSTAN}" "PHPStan"
    _show_option "${PTS_PSALM}" "Psalm"
    _show_option "${PTS_CS}" "Code sniffer"
    _show_option "${PTS_CS_BF}" "Code sniffer Beautifier"
    console_dark ""
}

_read_options () {
    __set_default_options
    console_debug "Reading options"
    while [ "${1:-}" != "" ]; do
        PARAM=$(echo "$1" | awk -F= '{print $1}')
        VALUE=$(echo "$1" | awk -F= '{print $2}')
        case $PARAM in
            -h | --help)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                __usage
                exit
                ;;
            --update)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                updater_run
                exit
                ;;
            -V | --version)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                console_print "${SCRIPT_NAME:-unknown} version $(_version "${PTS_TRUE}")"
                exit "${PTS_TRUE}"
                ;;
            # Undocumented
            --save-build-hash)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                version_save_build_hash
                exit "${PTS_TRUE}"
                ;;
            # Undocumented
            --no-exec)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_EXECUTE=${PTS_FALSE}
                ;;
            -a | --all)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                __ALL_OPTION=${PTS_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${PTS_TRUE}
                ;;
            -s | --analyze)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_ANALYSIS=${PTS_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${PTS_TRUE}
                ;;
            -u | --unit)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_PHPUNIT=${PTS_TRUE}
                ;;
            -c | --coverage)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_PHPUNIT_COVERAGE=${PTS_TRUE}
                PTS_PHPUNIT=${PTS_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${PTS_TRUE}
                ;;
            --metrics)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_METRICS=${PTS_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${PTS_TRUE}
                ;;
            --phpstan)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_PHPSTAN=${PTS_TRUE}
                PTS_PHPUNIT=${PTS_FALSE}
                PTS_REQUIRE_DEBUG_IMAGE=${PTS_TRUE}
                ;;
            --psalm)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_PSALM=${PTS_TRUE}
                PTS_PHPUNIT=${PTS_FALSE}
                PTS_REQUIRE_DEBUG_IMAGE=${PTS_TRUE}
                ;;
            --cs)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_CS=${PTS_TRUE}
                PTS_PHPUNIT=${PTS_FALSE}
                PTS_REQUIRE_DEBUG_IMAGE=${PTS_TRUE}
                ;;
            --multi)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_MULTI=${PTS_TRUE}
                ;;
            -b | --beauty | --beautify)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_CS_BF=${PTS_TRUE}
                PTS_PHPUNIT=${PTS_FALSE}
                PTS_REQUIRE_DEBUG_IMAGE=${PTS_TRUE}
                ;;
            --no-restart)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_RESTART=${PTS_FALSE}
                ;;
            --debug)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_DEBUG=1
                ;;
            # -y)
            #     console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
            #     ;;
            *)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                console_error "Unknown option '${PARAM}'"
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