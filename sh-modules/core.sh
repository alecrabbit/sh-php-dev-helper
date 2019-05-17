#!/usr/bin/env sh

# DEPENDS ON:     
# console.sh
# └── colored.sh

### Define constants
true; CR_TRUE=$?
false; CR_FALSE=$?
CR_ERROR=2

# 0: Disabled 1: Enabled
CR_DEBUG=${DEBUG:-0}  
CR_ALLOW_ROOT=${ALLOW_ROOT:-0}
CR_TITLE=${TITLE:-1}

# shellcheck disable=SC1090
. "${MODULES_DIR}/console.sh"

export CR_TRUE
export CR_FALSE
export CR_ERROR
export CR_DEBUG

core_int_to_string () {
    case ${1} in
        ${CR_TRUE})
            echo "True"
            return
        ;;
        ${CR_FALSE})
            echo "False"
            return
        ;;
        ${CR_ERROR})
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
        if [ "${CR_ALLOW_ROOT}" -eq 0 ]; then
                return "${CR_TRUE}"
            fi
    fi
    return "${CR_FALSE}"
}

core_set_terminal_title () {
    if [ "${CR_TITLE}" -eq 1 ]; then
        console_debug "Setting title '${1}'"
        # shellcheck disable=SC2059
        printf "\033]0;${1}\007"
    fi
}

core_get_title_from_file () {
    if [ -e "${1}" ]; then
        title="$(cat "${1}")"
    else
        title="${2:-Terminal}"
    fi
    echo "${title}"
}

check_command () {
    if [ -x "$(command -v "${1}")" ]; then
        return "${CR_TRUE}"
    fi
    return "${CR_FALSE}"
}

# See shunit2's realToAbsPath
core_backup_realpath () {
    __path=${1}

    # prepend current directory to relative paths
    echo "${__path}" | grep '^/' >/dev/null 2>&1 || __path="${PWD}/${__path}"

    # clean up the path. if all sed rules are supported true regular expressions, then
    # this is what it would be:
    __old=${__path}
    while true; do
        __new=$(echo "${__old}" | sed 's/[^/]*\/\.\.\/*//;s/\/\.\//\//')
        [ "${__old}" = "${__new}" ] && break
        __old=${__new}
    done
    echo "${__new}"

    unset __path __old __new
}

core_get_realpath ()
{
    if check_command "realpath"
    then
        __realpath="$(realpath "${1}" 2>&1)"
        if [ $? -ne "${CR_TRUE}" ]
        then
            console_debug "Error: ${__realpath}"
            console_debug "Using _ppt_backup_realpath function"
            unset __realpath
            core_backup_realpath "${1}"
            return $?
        fi
        echo "${__realpath}"
    else
        core_backup_realpath "${1}"
    fi
    unset __realpath
}

core_check_if_dir_exists () {
    console_debug "Checking if directory exists '${1}'"
    __DIRECTORY=$(core_get_realpath "${1}")
    if [ $? -eq ${CR_TRUE} ]
    then
        if [ -d "${__DIRECTORY}" ]; then
            if [ ! -L "${__DIRECTORY}" ]; then
                console_debug "Directory exists '${__DIRECTORY}'"
                unset __DIRECTORY
                return ${CR_TRUE}
            fi
        fi
    fi
    console_debug "Directory NOT exists '${__DIRECTORY}'"
    unset __DIRECTORY
    return ${CR_FALSE}
}

core_is_dir_contains () {
    __FILES="${2}"
    __DIR="${1}"
    for __file in ${__FILES}; do
        if [ ! -e "${__DIR}/${__file}" ]
        then
            console_debug "Not found: '${__DIR}/${__file}'"
            unset __FILES __file
            return ${CR_FALSE}
        fi
    done
    unset __DIR __FILES __file
    return ${CR_TRUE}
}

