#!/usr/bin/env sh

# DEPENDS ON:     
# core.sh
# └── console.sh
#     └── colored.sh
# git.sh

__DEVELOP="develop"
__MASTER="master"

version_load_version () {
    __file="${1}"
    if [ -e "${__file}" ]
    then
        __version="$(cat "${__file}")"
    else
        __version="${__DEVELOP}"
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
    SCRIPT_VERSION="${SCRIPT_VERSION:-${__DEVELOP}}"
    __show_build="${1:-${CR_FALSE}}"
    if [ "${SCRIPT_VERSION}" = "${__DEVELOP}" ] || [ "${SCRIPT_VERSION}" = "${__MASTER}" ] || [ "${__show_build}" = "${CR_TRUE}" ]; then
        if [ "${SCRIPT_BUILD}" != "" ]
        then
            SCRIPT_BUILD=", build ${SCRIPT_BUILD}"
            if [ "${__show_build}" = "${CR_FALSE}" ]; then
                SCRIPT_BUILD="$(colored_dark "${SCRIPT_BUILD}")"
            fi
        fi
    fi
    echo "${SCRIPT_VERSION}${SCRIPT_BUILD}"
    unset __show_build
}

version_update_needed () {
    test "$(echo "${SCRIPT_VERSION} ${1}" | tr " " "\n" | sort -V | head -n 1)" != "${1}";
}
 
version_save_build_hash () {
    SCRIPT_BUILD="$(git_get_head_hash "${SCRIPT_DIR:-.}")"
    if [ $? -ne "${CR_TRUE}" ] 
    then
        return "${CR_FALSE}"
    fi
    console_debug "Got build hash: '${SCRIPT_BUILD}'"
    if [ "${SCRIPT_BUILD}" != "" ]
    then
        echo "${SCRIPT_BUILD}" > "${LIB_DIR:-.}/BUILD"
        console_debug "Saved build hash '${SCRIPT_BUILD}' to '${LIB_DIR:-.}/BUILD'"
        echo "${SCRIPT_BUILD}"
    fi
}

version_print () {
    __current_version="$(version_string "${CR_TRUE}")"
    console_print "$(colored_default "${SCRIPT_NAME:-${DEFAULT_SCRIPT_NAME:-unknown}}") version ${__current_version}"
    unset __current_version
}

