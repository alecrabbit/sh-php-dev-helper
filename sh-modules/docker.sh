#!/usr/bin/env sh
# Args:
#   $1 string working dir
#   $2 string (optional)container name
docker_compose_is_container_started () {
    test "$(cd "${1}" && docker-compose ps 2>&1 | grep "${2:-$(basename "${1}")}.*Up")" != ""
}

# Args:
#   $1 string working dir
#   $2 string (optional)container name
#   $3 string (optional)string to find
docker_compose_is_debug_image_used () {
    test "$(cd "${1}" && docker-compose images 2>&1 | grep "${2:-$(basename "${1}")}.*${3:-debug}")" != ""
}
