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

user_is_root () {
    if [ "$(whoami)" = "root" ]; then
        if [ "${PTS_ALLOW_ROOT}" -eq 0 ]; then
                return "${PTS_TRUE}"
            fi
    fi
    return "${PTS_FALSE}"
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

check_command () {
    if [ -x "$(command -v "${1}")" ]; then
        return "${PTS_TRUE}"
    fi
    return "${PTS_FALSE}"
}

core_backup_realpath () {
    ppt_path_=${1}

    # prepend current directory to relative paths
    echo "${ppt_path_}" |grep '^/' >/dev/null 2>&1 \
        || ppt_path_="${PWD}/${ppt_path_}"

    # clean up the path. if all sed rules are supported true regular expressions, then
    # this is what it would be:
    ppt_old_=${ppt_path_}
    while true; do
        ppt_new_=$(echo "${ppt_old_}" | sed 's/[^/]*\/\.\.\/*//;s/\/\.\//\//')
        [ "${ppt_old_}" = "${ppt_new_}" ] && break
        ppt_old_=${ppt_new_}
    done
    echo "${ppt_new_}"

    unset ppt_path_ ppt_old_ ppt_new_
}

core_get_realpath ()
{
    if check_command "realpath"
    then
        ppt_new_="$(realpath "${1}" 2>&1)"
        if [ $? -ne "${PTS_TRUE}" ]
        then
            _ppt_debug "Error: ${ppt_new_}"
            _ppt_debug "Using _ppt_backup_realpath function"
            core_backup_realpath "${1}"
            return ${PTS_TRUE}
        fi
        echo "${ppt_new_}"
    else
        core_backup_realpath "${1}"
    fi
}
