#!/usr/bin/env sh
__hash="$(version_save_build_hash)"
if [ $? -eq "${CR_TRUE}" ]
then
    console_debug "Saved hash: '${__hash}'"
else
    console_debug "Hash not saved"
fi