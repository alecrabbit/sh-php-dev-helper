#!/usr/bin/env sh

# DEPENDS ON:     
# core.sh
# └── console.sh
#     └── colored.sh
# git.sh

export VERSION_DEVELOP="develop"
export VERSION_MASTER="master"

version_load_version () {
    __file="${1}"
    if [ -e "${__file}" ]
    then
        __version="$(cat "${__file}")"
    else
        __version="${VERSION_DEVELOP}"
    fi
    echo "${__version}"
    unset __file __version
}

version_load_build () {
    __file="${1}"
    if [ -e "${__file}" ]
    then
        __build="$(cat "${__file}")"
    else 
        __build=""
    fi
    echo "${__build}"
    unset __file __build
}

version_string () {
    SCRIPT_BUILD=${SCRIPT_BUILD:-}
    SCRIPT_VERSION="${SCRIPT_VERSION:-${VERSION_DEVELOP}}"
    __show_build="${1:-${CR_FALSE}}"
    if [ "${SCRIPT_VERSION}" = "${VERSION_DEVELOP}" ] || [ "${SCRIPT_VERSION}" = "${VERSION_MASTER}" ] || [ "${__show_build}" = "${CR_TRUE}" ]; then
        if [ "${SCRIPT_BUILD}" != "" ]
        then
            SCRIPT_BUILD="@${SCRIPT_BUILD}"
            if [ "${__show_build}" = "${CR_FALSE}" ]; then
                SCRIPT_BUILD="$(colored_dark "${SCRIPT_BUILD}")"
            fi
        fi
    else
        SCRIPT_BUILD=""
    fi
    echo "${SCRIPT_VERSION}${SCRIPT_BUILD}"
    unset __show_build
}

version_update_needed () {
    test "$(echo "${SCRIPT_VERSION} ${1}" | tr " " "\n" | sort -V | head -n 1)" != "${1}";
}

version_save_build_hash () {
    __script_dir="${1:-.}"
    __lib_dir="${2:-.}"
    __build="$(git_get_head_hash "${__script_dir}")"
    if [ $? -ne "${CR_TRUE}" ] 
    then
        return "${CR_FALSE}"
    fi
    console_debug "Got build hash: '${__build}'"
    if [ "${__build}" != "" ]
    then
        echo "${__build}" > "${__lib_dir}/BUILD"
        console_debug "Saved build hash '${__build}' to '${__lib_dir}/BUILD'"
        echo "${__build}"
    fi
    unset __build __script_dir __lib_dir
}

version_print () {
    __current_version="$(version_string "${CR_TRUE}")"
    console_print "$(colored_default "${SCRIPT_NAME:-${DEFAULT_SCRIPT_NAME:-unknown}}") version ${__current_version}"
    unset __current_version
}
