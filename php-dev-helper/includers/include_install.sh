#!/usr/bin/env sh

# Disable source following.
#   shellcheck disable=SC1090,SC1091

. "${APPS_MODULES_DIR}/install.sh"               # Install module

install_load_settings

install_read_options "$@"

install_check_working_env

install_show_settings
