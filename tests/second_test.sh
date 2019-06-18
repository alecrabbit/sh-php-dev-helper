#!/usr/bin/env sh

# Disable source following.
#   shellcheck disable=SC1090,SC1091
#   shellcheck disable=SC2006

. ./tests_helpers.sh

oneTimeSetUp () {
    console_debug "Setting up"
    console_dark "Setup Done"
}

test_tmp_git_attr_generator() {
SOURCE="
# Some other lines.
First line   
Second Line
#AUTO_GEN_BEGIN
#AUTO_GEN_END"
RESULT="
# Some other lines.
First line   
Second Line
#AUTO_GEN_BEGIN
#AUTO_GEN_END"
  # console_dark "${SOURCE}"
  assertEquals "${RESULT}" "$(tmp_git_attr_generator "${SOURCE}" "memory")" 
}

runTest
