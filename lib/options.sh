#!/usr/bin/env sh
__usage () {
    echo "Usage:"
    echo "    $(_color_bold "${SCRIPT_NAME}") [options]"
    echo "Options:"
    echo "    $(_color_yellow "--all")                 - launch all tests"
    echo "    $(_color_yellow "--no-restart")          - do not restart container(s)"
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
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                _log_print "${SCRIPT_NAME:-unknown} version $(_version)"
                exit
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
                ;;
            --all)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                ;;
            --analyze)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                ;;
            --unit)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                ;;
            --metrics)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                ;;
            --beauty | --beautify)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                ;;
            --no-restart)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                ;;
            -y)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                ;;
            *)
                _log_debug "Option '${PARAM}' $([ "${VALUE}" != "" ] && echo "Value '${VALUE}'")"
                _log_error "Unknown option '${PARAM}'"                
                __usage
                exit 1
                ;;
        esac
        shift
    done
}