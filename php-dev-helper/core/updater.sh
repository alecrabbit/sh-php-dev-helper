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

    __result="$(cd "${__to_dir}" && wget -nv -O download.tar.gz "https://github.com/${__repository}/archive/${__version}.tar.gz" 2>&1 )"
    if [ $? -ne "${CR_TRUE}" ]
    then
        console_error "${__result}"
    else 
        console_debug "Package '${__package}-${__version}' downloaded"
        __result="$(cd "${__to_dir}" && tar -xzvf download.tar.gz 2>&1)"
        if [ $? -ne "${CR_TRUE}" ]; then
            console_error "${__result}"
        else
            console_debug "Package '${__package}-${__version}' extracted"
            return "${CR_TRUE}"
        fi
    fi
    
    console_debug "${__result}"

    unset __to_dir __version __result __package __repository
    return "${CR_FALSE}"
}

github_download () {
    __to_dir="${1}"
    __package_owner="${2}"
    __package="${3}"
    __version="${4:-develop}"
    __repository="${__package_owner}/${__package}"
    console_debug "Downloading to '${__to_dir}/${__package}-${__version}'"

    __result="$(cd "${__to_dir}" && wget -nv -O download.tar.gz "https://github.com/${__repository}/archive/${__version}.tar.gz" 2>&1 )"
    if [ $? -ne "${CR_TRUE}" ]
    then
        console_error "${__result}"
    else 
        console_debug "Package '${__package}-${__version}' downloaded"
        __result="$(cd "${__to_dir}" && tar -xzvf download.tar.gz 2>&1)"
        if [ $? -ne "${CR_TRUE}" ]; then
            console_error "${__result}"
        else
            console_debug "${__result}"
            console_debug "Package '${__package}-${__version}' extracted"
            # console_debug "$(rm -v "${__to_dir}/download.tar.gz")"
            unset __to_dir __version __result __package __repository __package_owner
            return "${CR_TRUE}"
        fi
    fi
    
    console_debug "${__result}"

    unset __to_dir __version __result __package __repository __package_owner
    return "${CR_FALSE}"
}
