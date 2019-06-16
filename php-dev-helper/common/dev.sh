#!/usr/bin/env sh

console_debug ""
console_debug "*** DEV MODULE BEGIN ***"

__hash="$(version_save_build_hash "${SCRIPT_DIR}" "${LIB_DIR}")"
if [ $? -eq "${CR_TRUE}" ]
then
    console_debug "Saved hash: '${__hash}'"
else
    console_debug "Hash not saved"
fi

console_debug "*** DEV MODULE END ***"
console_debug ""
