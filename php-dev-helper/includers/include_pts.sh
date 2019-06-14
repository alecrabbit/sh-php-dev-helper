#!/usr/bin/env sh

# Disable source following.
#   shellcheck disable=SC1090,SC1091

. "${APPS_MODULES_DIR}/pts.sh"               # Image builder module

### Read options
pts_read_options "$@"