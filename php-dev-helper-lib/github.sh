#!/usr/bin/env sh
github_get_latest_release() {
  curl --silent "https://api.github.com/repos/${1}/releases/latest" |   # Get latest release from GitHub api
    grep '"tag_name":' |                                                # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                        # Pluck JSON value
}
github_get_tags() {
  curl --silent "https://api.github.com/repos/${1}/tags" |              # Get tags from GitHub api
    grep -m1 '"name":' |                                                # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                        # Pluck JSON value
}
github_get_latest_version () {
    __latest="$(github_get_latest_release "${1}")"
    if [ "${__latest}" = "" ]; then
        __latest="$(github_get_tags "${1}")"
        if [ "${__latest}" = "" ]; then
            echo "No releases or tags found for repository '${1}'" >&2
            unset __latest
            return 1
        fi
    fi
    echo "${__latest}"
    unset __latest
    return 0
}