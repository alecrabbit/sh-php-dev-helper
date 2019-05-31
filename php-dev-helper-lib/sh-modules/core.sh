#!/usr/bin/env sh

# DEPENDS ON:     
# console.sh
# └── colored.sh

### Define constants
true; CR_TRUE=$?
false; CR_FALSE=$?
CR_ERROR=2

CR_ENABLED=1
CR_DISABLED=0
CR_DEBUG=${DEBUG:-${CR_DISABLED}}  

# shellcheck disable=SC1090
. "${MODULES_DIR}/console.sh"

export CR_TRUE
export CR_FALSE
export CR_ERROR
export CR_DEBUG
export CR_ENABLED
export CR_DISABLED

core_bool_to_string () {
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

core_int_to_string () {
    case ${1} in
        ${CR_ENABLED})
            echo "Enabled"
            return
        ;;
        ${CR_DISABLED})
            echo "Disabled"
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
            console_debug "Using core_backup_realpath function"
            unset __realpath
            core_backup_realpath "${1}"
            return $?
        fi
        echo "${__realpath}"
    else
        core_backup_realpath "${1}"
        return $?
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

# core_dir_is_empty () {
#     console_debug "Checking if directory is empty '${1}'"
#     __DIRECTORY=$(core_get_realpath "${1}")
#     if [ $? -eq ${CR_TRUE} ]
#     then
#         __result="$(ls -A "${__DIRECTORY}" 2>&1)"
#         if [ -z "$(ls -A "${__DIRECTORY}" 2>&1)" ]; then
#             console_debug "Directory is empty '${__DIRECTORY}'"
#             unset __DIRECTORY
#             return ${CR_TRUE}
#         else
#             console_debug "Directory is NOT empty '${__DIRECTORY}'"
#             unset __DIRECTORY
#             return ${CR_FALSE}
#         fi
#     fi
#     console_debug "Directory NOT exists '${__DIRECTORY}'"
#     unset __DIRECTORY
#     return ${CR_TRUE}
# }

core_is_dir_contains () {
    __SHOW="${3:-${CR_FALSE}}"
    __FILES="${2}"
    __DIR="${1}"
    for __file in ${__FILES}; do
        if [ ! -e "${__DIR}/${__file}" ]
        then
            if [ "${__SHOW}" -eq  "${CR_TRUE}" ]; then
                console_comment "File not found: '${__DIR}/${__file}'"
            else
                console_debug "File not found: '${__DIR}/${__file}'"
            fi
            unset __DIR __FILES __file __SHOW
            return ${CR_FALSE}
        else
            console_debug "Found file: '${__DIR}/${__file}'"
        fi
    done
    unset __DIR __FILES __file __SHOW
    return ${CR_TRUE}
}

core_show_used_value () {
    console_debug "Using value '${1}=${2}'"
}

core_check_int_bool_env_value () {
      case ${1} in
        1 | 0)
            core_show_used_value "${2}" "${1}"
            ;;
        *) 
            echo "ERROR: Unrecognized value ${2}=${1}" >&2
            echo "       Allowed: ${2}=1, ${2}=0"
            exit 1
            ;;
  esac

}

core_ask_question () {
    __allowed_answers="${3:-ny}"
    __accept_any="${2:-${CR_FALSE}}"
    if [ "${__accept_any}" -eq "${CR_TRUE}" ]; then
        __allowed_answers="y/n"
    fi
    # shellcheck disable=SC2059
    printf "${1} [${__allowed_answers}] "
    __old_stty_cfg=$(stty -g)
    stty raw -echo

    if [ "${_pts_silent_operation:-${CR_FALSE}}" -eq "${CR_TRUE}" ]
    then
        __answer="y"
    else
        if [ "${__accept_any}" -eq "${CR_TRUE}" ]; then
            __answer=$(head -c 1)  # anything accepted
        else
            __answer=$( while ! head -c 1 | grep -i "[${__allowed_answers}]"; do true;  done )  # only __allowed_answers accepted
        fi
    fi
    stty "${__old_stty_cfg}"
    unset __old_stty_cfg
    echo "${__answer}"
    console_debug "Got answer '${__answer}'"
    # first symbol of __allowed_answers considered as yes
    if echo "${__answer}" | grep -iq "^$(echo "${__allowed_answers}" | head -c 1)" ;then 
        console_debug "Confirmed"
        unset __answer
        return ${CR_TRUE}
    fi
    # anything else is false
    console_print ""
    unset __answer
    return ${CR_FALSE}
}

core_file_contains_string () {
    __file="${1}"
    __string="${2}"
    __result="$(grep "${__string}" "${__file}")"
    # console_debug "s'${__string}' f'${__file}' r'${__result}'"
    if [ "${__result}" != "" ]; then
        unset __file __string __result
        return "${CR_TRUE}"
    fi
    unset __file __string __result
    return "${CR_FALSE}"
}

core_get_project_name () {
    __composer_json_file="$(core_get_realpath "${1}")"
    grep -m1 '"name":' "${__composer_json_file}" |                            # Get name line
    sed -E 's/.*"([^"]+)".*/\1/'                                              # Pluck JSON value
}

core_get_project_type () {
    __composer_json_file="$(core_get_realpath "${1}")"
    grep -m1 '"type":' "${__composer_json_file}" |                            # Get name line
    sed -E 's/.*"([^"]+)".*/\1/'                                              # Pluck JSON value
}

core_capitalize_every_word () {
    echo "$@" | sed -f "${MODULES_DIR}/capitalize.sed"
}

core_check_int_bool_env_value "${CR_DEBUG}" "DEBUG" 
