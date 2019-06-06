#!/usr/bin/env sh
SCRIPT_NAME="$(basename "$0")"
export SCRIPT_NAME


# shellcheck disable=SC1090
. "${MODULES_DIR}/core.sh"
# shellcheck disable=SC1090
. "${MODULES_DIR}/github.sh"
# shellcheck disable=SC1090
. "${MODULES_DIR}/docker.sh"
# shellcheck disable=SC1090
. "${MODULES_DIR}/git.sh"
# shellcheck disable=SC1090
. "${MODULES_DIR}/version.sh"
# shellcheck disable=SC1090
. "${MODULES_DIR}/updater.sh"
