#!/usr/bin/env sh
__file="${LIB_DIR:-.}/VERSION"

if [ -e "${__file}" ]
then
    _VERSION="$(cat "${__file}")"
else
    _VERSION="0.0.0"
fi
export _VERSION

__file="${LIB_DIR:-.}/BUILD"

if [ -e "${__file}" ]
then
    _BUILD="$(cat "${__file}")"
else 
    _BUILD="$(cd "${SCRIPT_DIR}" && git log --pretty=format:'%h' -n 1 2>&1)"
    if [ $? -gt 1 ]
    then
        _BUILD=""
    fi
fi
export _BUILD

unset __file