#!/usr/bin/env sh

test_Equality() {
  assertEquals 1 1
}

# Load shUnit2
# shellcheck disable=SC1091
. ./shunit2