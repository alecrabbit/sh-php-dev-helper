#!/usr/bin/env sh

# Disable source following.
#   shellcheck disable=SC1090,SC1091
#   shellcheck disable=SC2006

. ./tests_helpers.sh

oneTimeSetUp () {
    console_debug "Setting up"
    console_dark "Setup Done"
}

testEquality() {
  assertEquals 1 1
}

runTest
