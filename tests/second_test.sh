#!/usr/bin/env sh

# Disable source following.
#   shellcheck disable=SC1090,SC1091
#   shellcheck disable=SC2006

oneTimeSetUp () {
    echo "Setting Up"
    . ./tests_helpers.sh
    console_dark "Setup Done"
}

testEquality() {
  assertEquals 1 1
}

# Load shUnit2
# shellcheck disable=SC1091
. ./shunit2