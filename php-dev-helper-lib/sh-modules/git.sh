#!/usr/bin/env sh

# DEPENDS ON:     
# core.sh
# └── console.sh

git_get_head_hash () {
    __dir="${1:-.}"
    if ! core_check_if_dir_exists "${__dir}/.git"
    then
        console_debug "BUILD Hash: No repository found"
        console_error "Unable to get HEAD hash"
        echo ""
        return "${CR_FALSE}"
    fi
    __HASH="$(cd "${__dir}" && git log --pretty=format:'%h' -n 1 2>&1)"
    # shellcheck disable=SC2181
    if [ $? -ne 0 ]
    then
        __HASH=""
    fi
    echo "${__HASH}"
}
