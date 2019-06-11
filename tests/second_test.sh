#!/usr/bin/env sh

# Disable source following.
#   shellcheck disable=SC1090,SC1091
#   shellcheck disable=SC2006

. ./tests_helpers.sh

testEquality() {
  assertEquals 1 1
}

# Load shUnit2
# shellcheck disable=SC1091
. ./shunit2