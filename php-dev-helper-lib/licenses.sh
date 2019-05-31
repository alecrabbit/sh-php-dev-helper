#!/usr/bin/env sh
export LICENSE_DIR="${MMB_TEMPLATES_DIR}/licenses"

license_create () {
    __type="${1}"
    __owner="${2}"
    __year="${3:-$(date +%Y)}"
    __year="© ${__year}"
    __file="${LICENSE_DIR}/${__type}"

    console_debug "__type: ${__type}"
    console_debug "__owner: ${__owner}"
    console_debug "__year: ${__year}"

    if [ -e "${__file}" ]; then
        console_debug "License type: ${__type} found in ${LICENSE_DIR}"
        __result="$(sed "s/<YEAR>/${__year}/g; s/<COPYRIGHT HOLDER>/${__owner}/g;" "${__file}")"
        console_debug "${__result}"
        unset __result
    else
        console_error "License type: ${__type} not found in ${LICENSE_DIR}"
    fi

    unset __type __owner __year __file
}