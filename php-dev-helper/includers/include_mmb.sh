#!/usr/bin/env sh

# Disable source following.
#   shellcheck disable=SC1090,SC1091

. "${APPS_MODULES_DIR}/mmb.sh"               # Moomba module

mmb_load_settings

mmb_read_options "$@"

mmb_check_working_env

mmb_show_settings
