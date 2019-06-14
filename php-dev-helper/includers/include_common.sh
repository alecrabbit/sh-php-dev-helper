#!/usr/bin/env sh

# Disable source following.
#   shellcheck disable=SC1090,SC1091

. "${COMMON_MODULES_DIR}/options.sh"
. "${COMMON_MODULES_DIR}/functions.sh"
. "${COMMON_MODULES_DIR}/commands.sh"
. "${COMMON_MODULES_DIR}/settings.sh"
. "${COMMON_MODULES_DIR}/tmp.sh"

# Load PTS_AUX_DEV_MODULE module if present
if [ -e "${COMMON_MODULES_DIR}/${PTS_AUX_DEV_MODULE}" ]; then
    console_debug "Processing module '${PTS_AUX_DEV_MODULE}'"
    . "${COMMON_MODULES_DIR}/${PTS_AUX_DEV_MODULE}" && console_debug "Module '${PTS_AUX_DEV_MODULE}' processed"
else
    console_debug "Module '${PTS_AUX_DEV_MODULE}' not found"
fi
