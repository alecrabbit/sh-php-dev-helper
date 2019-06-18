#!/usr/bin/env sh

gitattributes_keep() {
    if echo "${GITATTRIBUTES_KEEP}" | grep -q "${1}"; then
        return 0
    fi
    return 1
}

gitattributes_export_ignore () {
    for __entry in "${1}"/* "${1}"/.*
    do
        __entry="$(basename "${__entry}")"
        # __entry="$(echo "${__entry}" | sed -e "s/\.\///g")"
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
    unset __entry
}
