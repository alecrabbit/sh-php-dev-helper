#!/usr/bin/env sh

# DEPENDS ON:     
# core.sh
# └── console.sh
#     └── colored.sh

updater_download () {
    __to_dir="${1}"
    __repository="${2}"
    __package="${3}"
    __version="${4}"
    console_debug "Removing '${__to_dir}'\n$(rm -rfv "${__to_dir}" 2>&1)"
    console_debug "Recreating '${__to_dir}'\n$(mkdir -pv "${__to_dir}" 2>&1)"
    console_debug "Downloading to '${__to_dir}/${__package}-${__version}'"
    __result="$(cd "${__to_dir}" && wget -qO- "https://github.com/${__repository}/archive/${__version}.tar.gz" | tar -xzv 2>&1)"
    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        console_info "Package '${__package}-${__version}' downloaded"
        return "${CR_TRUE}"
    fi
    
    console_debug "${__result}"
    console_error "Possible cause: incorrect version $(colored_bold_cyan "'${__version}'")"

    unset __to_dir __version __result __package __repository
    return "${CR_FALSE}"
}