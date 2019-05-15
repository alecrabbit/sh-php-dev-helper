#!/usr/bin/env sh
### Define constants
true; PTS_TRUE=$?
false; PTS_FALSE=$?
PTS_ERROR=2

# 0: Disabled 1: Enabled
PTS_DEBUG=${DEBUG:-0}  
PTS_ALLOW_ROOT=${ALLOW_ROOT:-0}
PTS_TITLE=${TITLE:-1}

export PTS_TRUE
export PTS_FALSE
export PTS_ERROR
export PTS_DEBUG

core_int_to_string () {
    case ${1} in
        ${PTS_TRUE})
            echo "True"
            return
        ;;
        ${PTS_FALSE})
            echo "False"
            return
        ;;
        ${PTS_ERROR})
            echo "Error"
            return
        ;;
        *)
            echo "${1}"
            return
        ;;
   esac
}

_pts_check_user () {
    if [ "$(whoami)" = "root" ]; then
        if [ "${PTS_ALLOW_ROOT}" -eq 0 ]; then
                _log_fatal "DO NOT run this script under root!"
            fi
    fi
}
_pts_set_terminal_title () {
    if [ "${PTS_TITLE}" -eq 1 ]; then
        # shellcheck disable=SC2059
        printf "\033]0;${1}\007"
    fi
}

_pts_get_title_from_file () {
    if [ -e "${1}" ]; then
        title="$(cat "${1}")"
    else
        title="${2:-Terminal}"
    fi
    echo "${title}"
}

_pts_check_command () {
    if [ -x "$(command -v "${1}")" ]; then
        return "${PTS_TRUE}"
    fi
    return "${PTS_FALSE}"
}
