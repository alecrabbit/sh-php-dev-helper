#!/usr/bin/env sh

# Disable source following.
#   shellcheck disable=SC1090,SC1091

. "${APPS_MODULES_DIR}/bdi.sh"               # Image builder module

bdi_load_settings

bdi_read_options "$@"

bdi_check_working_env

bdi_show_settings
