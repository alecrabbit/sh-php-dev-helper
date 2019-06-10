#!/usr/bin/env sh
SCRIPT_NAME="$(basename "$0")"
export SCRIPT_NAME


# shellcheck disable=SC1090
. "${CORE_MODULES_DIR}/core.sh"
# shellcheck disable=SC1090
. "${CORE_MODULES_DIR}/github.sh"
# shellcheck disable=SC1090
. "${CORE_MODULES_DIR}/docker.sh"
# shellcheck disable=SC1090
. "${CORE_MODULES_DIR}/git.sh"
# shellcheck disable=SC1090
. "${CORE_MODULES_DIR}/version.sh"
# shellcheck disable=SC1090
. "${CORE_MODULES_DIR}/updater.sh"
# shellcheck disable=SC1090
. "${CORE_MODULES_DIR}/notifier.sh"
