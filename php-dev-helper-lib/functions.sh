#!/usr/bin/env sh
_check_working_env () {
    if user_is_root
    then
        console_fatal "DO NOT run this script under root!"
    fi
    console_debug "Checking user: $(whoami)"

    if ! check_command "docker-compose"
    then 
        console_fatal "docker-compose is NOT installed!"
    fi
    console_debug "Checking docker-compose: installed"
    if ! core_is_dir_contains "${WORK_DIR}" "${_DOCKER_COMPOSE_FILE} ${_DOCKER_COMPOSE_FILE_DEBUG}"
    then
        console_notice "\nAre you in the right directory?"
        console_fatal "docker-compose*.yml file(s) not found in current directory"
    fi
}


_generate_report_file () {
    cat <<EOF > "${PTS_TEST_REPORT_INDEX}"
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
  <title>${PROJECT_NAME}</title>
</head>
<body>

<h1>Report &lt;${PROJECT_NAME}&gt;</h1>

<p>Some links could be empty</p>
<a href='${PTS_TMP_DIR_PARTIAL}/${PTS_COVERAGE_DIR}/html/index.html'>Coverage report</a><br>
<a href='${PTS_TMP_DIR_PARTIAL}/${PTS_PHPMETRICS_DIR}/index.html'>Phpmetrics report</a><br>

</body>
</html> 
EOF
}