#!/usr/bin/env sh

# Disable source following.
#   shellcheck disable=SC1090,SC1091

. "${APPS_MODULES_DIR}/pts.sh"               # Image builder module

### Run checks
pts_load_settings

pts_read_options "$@"

pts_check_working_env

pts_show_settings


console_debug "Output use color: $(core_int_to_string "${CR_COLOR}")"

