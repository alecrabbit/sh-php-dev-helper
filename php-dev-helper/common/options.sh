#!/usr/bin/env sh

debug_option () {
    console_debug "Selected option '${1}'$([ "${2}" != "" ] && echo " with value '${2}'")"
}