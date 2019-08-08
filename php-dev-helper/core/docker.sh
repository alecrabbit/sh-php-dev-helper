#!/usr/bin/env sh

#######################
### NO DEPENDENCIES ###
#######################

# Args:
#   $1 string working dir
#   $2 string (optional)container name
docker_compose_is_container_started () {
    test "$(cd "${1}" && docker-compose ps 2>&1 | grep "${2:-$(core_lowercase "$(basename "${1}")")}.*Up")" != ""
}

# Args:
#   $1 string working dir
#   $2 string (optional)container name
#   $3 string (optional)string to find
docker_compose_is_debug_image_used () {
    # __name="${2:-$(basename "${1}")}"
    # __attr="${3:-debug}"
    # __result="$(cd "${1}" && docker-compose images 2>&1 | grep "${__name}.*${__attr}")"
    # echo "'${1}' '${__name}' '${__attr}'" >&2
    # echo "'${__result}'" >&2
    # test "${__result}" != ""
    # test "$(cd "${1}" && docker-compose images 2>&1 | grep -A1 "${2:-$(basename "${1}")}.*${3:-debug}")" != ""
    test "$(cd "${1}" && docker-compose images 2>&1 | grep -A1 "${2:-$(core_lowercase "$(basename "${1}")")}" | grep "${3:-debug}")" != ""
}
