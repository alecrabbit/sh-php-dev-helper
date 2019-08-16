#!/usr/bin/env sh

# DEPENDS ON:     
# core.sh
# └── console.sh

git_get_head_hash () {
    __dir="${1:-.}"
    if ! core_dir_exists "${__dir}/.git"
    then
        console_debug "BUILD Hash: No repository found"
        console_error "Unable to get HEAD hash"
        echo ""
        return "${CR_FALSE}"
    fi
    __HASH="$(cd "${__dir}" && git log --pretty=format:'%h' -n 1 2>&1)"
    if [ $? -ne "${CR_TRUE}" ]
    then
        __HASH=""
    fi
    echo "${__HASH}"
}

git_has_repository () {
    __repo_dir="${1:-.}"
    if ! core_dir_exists "${__repo_dir}/.git"
    then
        console_debug "No repository found"
        console_error "Directory '$(core_get_realpath "${__repo_dir}")' does not have a repository"
        return "${CR_FALSE}"
    fi
    unset __repo_dir
    return "${CR_TRUE}"
}

git_get_remote_url () {
    __dir="${1:-.}"
    if git_has_repository "${__dir}"; then
        __remote="$(cd "${__dir}" && git remote)"
        console_debug "Operation result: ${__remote}"
        __url="$(cd "${__dir}" && git remote get-url "${__remote}")"
        console_debug "Operation result: ${__url}"
        __url="$(core_str_replace "${__url}" "\.git" "")"
        echo "${__url}"
        unset __url __remote __dir
        return "${CR_TRUE}"
    fi
    unset __url __remote __dir
    return "${CR_FALSE}"
}

git_credentials_are_set () {
    __user_name="$(git config --global user.name)"
    if [ -z "${__user_name}" ]; then
        return "${CR_FALSE}"
    else
        __user_email="$(git config --global user.email)"
        if [ -z "${__user_email}" ]; then
            return "${CR_FALSE}"
        fi
    fi
    console_debug "git credentials name: ${__user_name} email: ${__user_email}"
    unset __user_name __user_email
    return "${CR_TRUE}"

}