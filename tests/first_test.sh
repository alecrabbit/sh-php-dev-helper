#!/usr/bin/env sh

# Disable source following.
#   shellcheck disable=SC1090,SC1091
#   shellcheck disable=SC2006

. ./tests_helpers.sh

test_core_bool_to_string() {
    assertEquals "True" "`core_bool_to_string "${CR_TRUE}"`"
    assertEquals "False" "`core_bool_to_string "${CR_FALSE}"`"
    assertEquals "Error" "`core_bool_to_string "${CR_ERROR}"`"
    assertEquals "Misc" "`core_bool_to_string "Misc"`"
}

test_core_int_to_string() {
    assertEquals "Enabled" "`core_int_to_string "${CR_ENABLED}"`"
    assertEquals "Disabled" "`core_int_to_string "${CR_DISABLED}"`"
    assertEquals "2" "`core_int_to_string "${CR_ERROR}"`"
    assertEquals "Misc" "`core_int_to_string "Misc"`"
}

# test_core_set_terminal_title() {
#     assertEquals '\033]0;Title\007' "$(core_set_terminal_title "Title" >&1 2>&1)"
#     # assertEquals "\033]0;Some new title\007" "`core_set_terminal_title "Some new title"`"
# }

test_core_str_replace() {
    assertEquals "22202222" "`core_str_replace "22212222" "1" "0"`"
    assertEquals "https://github.com/kward/shunit2" "`core_str_replace "https://github.com/kward/shunit2.git" "\.git" ""`"
}

test_core_get_title_from_file() {
    assertEquals "Terminal" "$(core_get_title_from_file "nonexistent")"
    assertEquals "Some other title" "$(core_get_title_from_file "terminal_title_file")"
}

test_check_command () {
    check_command "git"
    assertTrue $?
    check_command "nonexistent"
    assertFalse $?
} 


# Load shUnit2
# shellcheck disable=SC1091
. ./shunit2