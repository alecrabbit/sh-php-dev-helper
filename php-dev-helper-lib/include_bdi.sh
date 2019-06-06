#!/usr/bin/env sh

# shellcheck disable=SC1090
. "${APPS_MODULES_DIR}/bdi.sh"               # Image builder module

bdi_load_settings
bdi_read_options "$@"
