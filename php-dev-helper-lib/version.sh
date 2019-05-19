#!/usr/bin/env sh
VERSION_FILE="${LIB_DIR:-.}/VERSION"
BUILD_FILE="${LIB_DIR:-.}/BUILD"
__file="${VERSION_FILE}"

if [ -e "${__file}" ]
then
    _VERSION="$(cat "${__file}")"
else
    _VERSION="develop"
fi
export _VERSION

__file="${BUILD_FILE}"

if [ -e "${__file}" ]
then
    _BUILD="$(cat "${__file}")"
else 
    _BUILD="$(git_get_head_hash "${SCRIPT_DIR}")"
fi
export _BUILD

version_string () {
    _BUILD=${_BUILD:-}
    _VERSION="${_VERSION:-0.0.0}"
    __show_build="${1:-${CR_FALSE}}"
    if [ "${_VERSION}" = "develop" ] || [ "${_VERSION}" = "master" ] || [ "${__show_build}" = "${CR_TRUE}" ]; then
        if [ "${_BUILD}" != "" ]
        then
            _BUILD=", build ${_BUILD}"
            if [ "${__show_build}" = "${CR_FALSE}" ]; then
                _BUILD="$(colored_dark "${_BUILD}")"
            fi
        fi
    fi
    echo "${_VERSION}${_BUILD}"
    unset __show_build
}

version_update_needed () {
    test "$(echo "${_VERSION} ${1}" | tr " " "\n" | sort -V | head -n 1)" != "${1}";
}
 
version_save_build_hash () {
    _BUILD="$(git_get_head_hash "${SCRIPT_DIR}")"
    if [ $? -ne "${CR_TRUE}" ] 
    then
        return "${CR_FALSE}"
    fi
    console_debug "Got build hash: '${_BUILD}'"
    if [ "${_BUILD}" != "" ]
    then
        echo "${_BUILD}" > "${LIB_DIR:-.}/BUILD"
        console_debug "Saved build hash '${_BUILD}' to '${LIB_DIR:-.}/BUILD'"
        echo "${_BUILD}"
    fi
}

version_print () {
    __current_version="$(version_string "${CR_TRUE}")"
    console_print "$(colored_default "${SCRIPT_NAME:-unknown}") version ${__current_version}"
    unset __current_version
}
unset __file