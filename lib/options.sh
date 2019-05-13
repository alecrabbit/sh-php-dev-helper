#!/usr/bin/env sh
__usage () {
    echo "Usage:"
    echo "    ${SCRIPT_NAME} [options]"
    echo "Options:"
    echo "    --all                 - launch all tests"
}
_version () {
    _BUILD=${_BUILD:-}
    if [ "${_BUILD}" != "" ]
    then
        _BUILD=", build ${_BUILD}"
    fi
    echo "${_VERSION:-unknown}${_BUILD}"
}

_read_options () {
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
                _log_print "${SCRIPT_NAME:-unknown} version $(_version)"
                exit
                ;;
            --all)
                _log_debug "Option '${PARAM}' Value '${VALUE}'"
                ;;
            -y)
                _log_debug "Option '${PARAM}' Value '${VALUE}'"
                ;;
            --db-path)
                _log_debug "Option '${PARAM}' Value '${VALUE}'"
                ;;
            *)
                _log_debug "Option '${PARAM}' Value '${VALUE}'"
                _log_error "Unknown option '${PARAM}'"                
                __usage
                exit 1
                ;;
        esac
        shift
    done
}