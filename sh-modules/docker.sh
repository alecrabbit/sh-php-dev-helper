#!/usr/bin/env sh
### Define constants
true; CR_TRUE=${CR_TRUE:-$?}
false; CR_FALSE=${CR_FALSE:-$?}

docker_compose_is_container_started () {
    __work_dir="${1}"
    __name="$(basename "${__work_dir}")"
    __result="$(cd "${__work_dir}" && docker-compose ps | grep -e "${__name}" -e "Up")"
    if [ "${__result}" != "" ]
    then
        return "${CR_TRUE}"
    fi
    unset __work_dir __result __name
    return "${CR_FALSE}"
}