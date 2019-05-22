#!/usr/bin/env sh
__pts_usage () {
    echo "Usage:"
    echo "    $(colored_bold "${SCRIPT_NAME}") [options]"
    echo "Options:"
    echo "    $(colored_yellow "-h")                    - show help message and exit"
    echo "    $(colored_yellow "-a, --all")             - run all (not includes --metrics and --multi)"
    echo "    $(colored_yellow "-b ")                   - enable php code sniffer beautifier"
    echo "    $(colored_yellow "-c, --coverage")        - enable phpunit code coverage (includes -u)"
    echo "    $(colored_yellow "--cs")                  - enable php code sniffer"
    echo "    $(colored_yellow "--metrics")             - enable phpmetrics"
    echo "    $(colored_yellow "--multi")               - enable multi-tester"
    echo "    $(colored_yellow "--phpstan")             - enable phpstan"
    echo "    $(colored_yellow "--psalm")               - enable psalm"
    echo "    $(colored_yellow "-s, --analyze")         - enable static analysis tools (--phpstan and --psalm)"
    echo "    $(colored_yellow "-u, --unit")            - enable phpunit"
    echo "    $(colored_yellow "--update")              - update script"
    echo "    $(colored_yellow "-V, --version")         - show version"
    echo
    # shellcheck disable=SC2005
    echo "$(colored_dark "Note: options order is important")"
}

__pts_set_default_options () {
    PTS_EXECUTE=${CR_TRUE}
    PTS_REQUIRE_DEBUG_IMAGE=${CR_FALSE}
    PTS_RESTART=${CR_FALSE}
    PTS_ANALYSIS=${CR_FALSE}
    PTS_METRICS=${CR_FALSE}
    PTS_MULTI=${CR_FALSE}
    PTS_CS=${CR_FALSE}
    PTS_CS_BF=${CR_FALSE}
    PTS_PHPSTAN=${CR_FALSE}
    PTS_PSALM=${CR_FALSE}
    PTS_PHPUNIT=${CR_TRUE}
    PTS_PHPUNIT_COVERAGE=${CR_FALSE}
    __ALL_OPTION=${CR_FALSE}
}

__pts_process_options () {
    if [ "${PTS_ANALYSIS}" -eq "${CR_TRUE}" ]; then
        PTS_PHPUNIT=${CR_FALSE}
        PTS_PHPSTAN=${CR_TRUE}
        PTS_PSALM=${CR_TRUE}
    fi
    if [ "${__ALL_OPTION}" -eq "${CR_TRUE}" ]; then
        PTS_CS=${CR_TRUE}
        PTS_CS_BF=${CR_TRUE}
        PTS_PHPSTAN=${CR_TRUE}
        PTS_PSALM=${CR_TRUE}
        PTS_PHPUNIT=${CR_TRUE}
        PTS_PHPUNIT_COVERAGE=${CR_TRUE}
    fi
}

__pts_export_options () {
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

_pts_show_selected_options () {
    console_dark "\n     Selected options:"
    if [ "${CR_DEBUG}" -eq 1 ]
    then
        console_show_option "${PTS_EXECUTE}" "Execute"
        console_show_option "${PTS_ANALYSIS}" "Analysis"
        console_show_option "${PTS_RESTART}" "Container restart"
    fi
    console_show_option "${PTS_PHPUNIT}" "PHPUnit"
    console_show_option "${PTS_PHPUNIT_COVERAGE}" "PHPUnit code coverage"
    console_show_option "${PTS_MULTI}" "Multi-tester"
    console_show_option "${PTS_METRICS}" "PHPMetrics"
    console_show_option "${PTS_PHPSTAN}" "PHPStan"
    console_show_option "${PTS_PSALM}" "Psalm"
    console_show_option "${PTS_CS}" "Code sniffer"
    console_show_option "${PTS_CS_BF}" "Code sniffer Beautifier"
    console_dark ""
}

_pts_read_options () {
    __pts_set_default_options
    console_debug "Reading options"
    while [ "${1:-}" != "" ]; do
        PARAM=$(echo "$1" | awk -F= '{print $1}')
        VALUE=$(echo "$1" | awk -F= '{print $2}')
        case ${PARAM} in
            -h | --help)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                __pts_usage
                exit
                ;;
            --update)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                _pts_updater_run "${VALUE}"
                exit
                ;;
            -V | --version)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                version_print
                exit "${CR_TRUE}"
                ;;
            # Undocumented
            --save-build-hash)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                version_save_build_hash "${SCRIPT_DIR}" "${LIB_DIR}"
                exit "${CR_TRUE}"
                ;;
            # Undocumented
            --no-exec)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_EXECUTE=${CR_FALSE}
                ;;
            -a | --all)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                __ALL_OPTION=${CR_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            -s | --analyze)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_ANALYSIS=${CR_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            -u | --unit)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_PHPUNIT=${CR_TRUE}
                ;;
            -c | --coverage)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_PHPUNIT_COVERAGE=${CR_TRUE}
                PTS_PHPUNIT=${CR_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            --metrics)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_METRICS=${CR_TRUE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            --phpstan)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_PHPSTAN=${CR_TRUE}
                PTS_PHPUNIT=${CR_FALSE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            --psalm)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_PSALM=${CR_TRUE}
                PTS_PHPUNIT=${CR_FALSE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            --cs)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_CS=${CR_TRUE}
                PTS_PHPUNIT=${CR_FALSE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            --multi)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_MULTI=${CR_TRUE}
                ;;
            -b | --beauty | --beautify)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_CS_BF=${CR_TRUE}
                PTS_PHPUNIT=${CR_FALSE}
                PTS_REQUIRE_DEBUG_IMAGE=${CR_TRUE}
                ;;
            --no-restart)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_RESTART=${CR_FALSE}
                ;;
            --debug)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                CR_DEBUG=1
                ;;
            *)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                console_error "Unknown option '${PARAM}'"
                __pts_usage
                exit 1
                ;;
        esac
        shift
    done
    __pts_process_options
    __pts_export_options
    unset PARAM VALUE
}

__moomba_usage () {
    echo "Usage:"
    echo "    $(colored_bold "${SCRIPT_NAME}") [options]"
    echo "Options:"
    echo "    $(colored_yellow "-h")                    - show help message and exit"
    echo "    $(colored_yellow "--update")              - update script"
    echo "    $(colored_yellow "-V, --version")         - show version"
    echo
    # shellcheck disable=SC2005
    echo "$(colored_dark "Note: options order is important")"
}


__moomba_set_default_options () {
    :
}
__moomba_process_options () {
    :
}
__moomba_export_options () {
    :
}


_moomba_read_options () {
    __moomba_set_default_options
    console_debug "Reading options"
    while [ "${1:-}" != "" ]; do
        PARAM=$(echo "$1" | awk -F= '{print $1}')
        VALUE=$(echo "$1" | awk -F= '{print $2}')
        case ${PARAM} in
            -h | --help)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                __moomba_usage
                exit
                ;;
            --update)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                _pts_updater_run "${VALUE}"
                exit
                ;;
            -V | --version)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                version_print
                exit "${CR_TRUE}"
                ;;
            # Undocumented
            --save-build-hash)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                version_save_build_hash "${SCRIPT_DIR}" "${LIB_DIR}"
                exit "${CR_TRUE}"
                ;;
            # Undocumented
            --no-exec)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_EXECUTE=${CR_FALSE}
                ;;
            --no-restart)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                PTS_RESTART=${CR_FALSE}
                ;;
            --debug)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                CR_DEBUG=1
                ;;
            *)
                console_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                console_error "Unknown option '${PARAM}'"
                __moomba_usage
                exit 1
                ;;
        esac
        shift
    done
    __moomba_process_options
    __moomba_export_options
    unset PARAM VALUE
}