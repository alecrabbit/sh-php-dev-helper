#!/usr/bin/env sh
# shellcheck disable=SC1090
. "${LIB_DIR}/options.sh"
# shellcheck disable=SC1090
. "${LIB_DIR}/functions.sh"
# shellcheck disable=SC1090
. "${LIB_DIR}/commands.sh"
# shellcheck disable=SC1090
. "${LIB_DIR}/settings.sh"
# shellcheck disable=SC1090
. "${LIB_DIR}/tmp.sh"
# Load PTS_AUX_DEV_MODULE module if present
if [ -e "${LIB_DIR}/${PTS_AUX_DEV_MODULE}" ]; then
    console_debug "Processing module '${PTS_AUX_DEV_MODULE}'"
    # shellcheck disable=SC1090
    . "${LIB_DIR}/${PTS_AUX_DEV_MODULE}" && console_debug "Module '${PTS_AUX_DEV_MODULE}' processed"
else
    console_debug "Aux dev module '${PTS_AUX_DEV_MODULE}' not found"
fi
