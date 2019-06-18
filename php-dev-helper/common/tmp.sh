#!/usr/bin/env sh

gitattributes_keep() {
    if echo "${__GITATTRIBUTES_KEEP}" | grep -q "${1}"; then
        return 0
    fi
    return 1
}

gitattributes_export_ignore () {
    __GITATTRIBUTES_KEEP="${2}"
    for __entry in "${1}"/* "${1}"/.*
    do
        __entry="$(basename "${__entry}")"
        if [ "${__entry}" = "." ] || [ "${__entry}" = ".." ]; then 
            continue
        fi
        if ! gitattributes_keep "${__entry}"; then
            if [ -d "${__entry}" ]; then
                __entry="/${__entry}";
            fi
            __entry="${__entry} export-ignore"
            echo "${__entry}"
        fi
    done
    unset __entry __GITATTRIBUTES_KEEP
}

gitattributes_generate () {
    if core_dir_contains "${1}" ".gitattributes.keep" "${CR_TRUE}"
    then
        if core_dir_contains "${1}" ".gitattributes.template"
        then
            __gtr_tpl="$(cat "${1}/.gitattributes.template")"
        else
            __gtr_tpl=""
        fi
        echo "${__gtr_tpl}$(gitattributes_export_ignore "${1}" "$(cat "${1}/.gitattributes.keep")")" > "${1}"/.gitattributes
        unset __gtr_tpl
    else
        console_error "Couldn't generate"
    fi
}