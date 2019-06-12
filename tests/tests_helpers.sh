#!/usr/bin/env sh

# Disable source following.
#    shellcheck disable=SC1090,SC1091

SCRIPT_DIR=${SCRIPT_DIR:-"../$(dirname "$0")"}

. ./../php-dev-helper_loader

runTest() {
    # Load shUnit2
    . ./modified_shunit2
}