#!/usr/bin/env sh
VERSION_FILE="${LIB_DIR:-.}/VERSION"
BUILD_FILE="${LIB_DIR:-.}/BUILD"
__file="${VERSION_FILE}"

if [ -e "${__file}" ]
then
    _VERSION="$(cat "${__file}")"
else
    _VERSION="0.0.0"
fi
export _VERSION

__file="${BUILD_FILE}"

if [ -e "${__file}" ]
then
    _BUILD="$(cat "${__file}")"
else 
    _BUILD="$(_get_git_hash)"
fi
export _BUILD

_get_git_hash () {
    if ! core_check_if_dir_exists "${SCRIPT_DIR}/.git"
    then
        _log_debug "BUILD Hash: No repository found"
        return "${PTS_FALSE}"
    fi
    _BUILD="$(cd "${SCRIPT_DIR}" && git log --pretty=format:'%h' -n 1 2>&1)"
    # shellcheck disable=SC2181
    if [ $? -ne 0 ]
    then
        _BUILD=""
    fi
    echo "${_BUILD}"
}

_version () {
    _BUILD=${_BUILD:-}
    if [ "${_BUILD}" != "" ]
    then
        _BUILD=", build ${_BUILD}"
    fi
   
    if [ "${1:-${PTS_FALSE}}" -ne "${PTS_TRUE}" ]; then
        _BUILD=""
    fi

    echo "${_VERSION:-unknown}${_BUILD}"
}

version_update_needed () {
    test "$(echo "${_VERSION} ${1}" | tr " " "\n" | sort -V | head -n 1)" != "${1}";
}
 
version_save_build_hash () {
    _BUILD="$(_get_git_hash)"
    if [ $? -ne 0 ] 
    then
        return "${PTS_FALSE}"
    fi
    _log_debug "Build hash: '${_BUILD}'"
    if [ "${_BUILD}" != "" ]
    then
        echo "${_BUILD}" > "${LIB_DIR:-.}/BUILD"
        _log_debug "Saved build hash '${_BUILD}' to '${LIB_DIR:-.}/BUILD'"
        echo "${_BUILD}"
    fi
    exit "${PTS_TRUE}"
}

unset __file