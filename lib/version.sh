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
    export _BUILD
fi

unset __file