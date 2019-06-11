#!/usr/bin/env sh

# Disable source following.
#   shellcheck disable=SC1090,SC1091

SCRIPT_NAME="$(basename "$0")"
export SCRIPT_NAME

. "${CORE_MODULES_DIR}/core.sh"
. "${CORE_MODULES_DIR}/github.sh"
. "${CORE_MODULES_DIR}/docker.sh"
. "${CORE_MODULES_DIR}/git.sh"
. "${CORE_MODULES_DIR}/version.sh"
. "${CORE_MODULES_DIR}/updater.sh"
. "${CORE_MODULES_DIR}/notifier.sh"
