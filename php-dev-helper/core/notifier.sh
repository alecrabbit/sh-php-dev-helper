#!/usr/bin/env sh

notifier_notify () {
    if [ "${OPTION_NOTIFY:-${CR_FALSE}}" -eq "${CR_TRUE}" ];then
        if check_command "notify-send"; then
            notify-send "${1}" "${2}"
        else
            console_debug "Can't send notification"
        fi
    fi
}