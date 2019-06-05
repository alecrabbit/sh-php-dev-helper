#!/usr/bin/env sh
SCRIPT_DIR="$(core_get_realpath "${SCRIPT_DIR}")"
LIB_DIR="$(core_get_realpath "${LIB_DIR}")"
WORK_DIR="$(core_get_realpath "${WORK_DIR}")"
VERSION_FILE="$(core_get_realpath "${VERSION_FILE}")"
BUILD_FILE="$(core_get_realpath "${BUILD_FILE}")"

console_debug "Script name: ${SCRIPT_NAME}"
console_debug "Script dir: ${SCRIPT_DIR}"
console_debug "Lib dir: ${LIB_DIR}"
console_debug "Work dir: ${WORK_DIR}"
console_debug "VERSION file: ${VERSION_FILE}"
console_debug "BUILD file: ${BUILD_FILE}"

__hash="$(version_save_build_hash "${SCRIPT_DIR}" "${LIB_DIR}")"
if [ $? -eq "${CR_TRUE}" ]
then
    console_debug "Saved hash: '${__hash}'"
else
    console_debug "Hash not saved"
fi
