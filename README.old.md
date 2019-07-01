# 🐇 PHP Dev Helper

## What is it

- `php-tests` - tool to automate local testing
- `moomba`  - composer library creator script using template [alecrabbit/php-package-template](https://github.com/alecrabbit/php-package-template)
- `build-image` - convenient local docker image build tool (WIP)

## Usage

### Options

#### moomba

```text
$ moomba -h
Usage:
    moomba [options]
Options:
    -h, --help            - show help message and exit
    -p                    - set package name
    -o                    - set owner
    -s                    - set owner namespace
    -n                    - set package namespace
    -x                    - do not use package namespace
    --update              - update script
    --update-default      - update default template
    -t                    - use template
    -V, --version         - show version
    --no-interaction      - do not ask any interactive question

Example:
    moomba-dev -p=new-package -o=mike

Note: options order is important
```

> [Notes](.docs/update_option.md) on using `--update` option

### Created package file structure(using defaults)

```text
.
├── CHANGELOG.md
├── .chglog
│   ├── CHANGELOG.tpl.md
│   └── config.yml
├── CODE_OF_CONDUCT.md
├── composer.json
├── docker-compose-debug.yml
├── docker-compose.yml
├── .dockerignore
├── .gitattributes
├── .gitattributes.keep
├── .gitattributes.template
├── .github
│   └── ISSUE_TEMPLATE
│       ├── bug_report.md
│       ├── feature_request.md
│       └── misc_issue.md
├── .gitignore
├── LICENSE
├── phpcs.xml
├── phpunit.xml
├── README.md
├── .scrutinizer.yml
├── src
│   └── LooneyTunes
│       └── BasicClass.php
├── TERMINAL_TITLE
├── tests
│   ├── BasicTest.php
│   ├── bootstrap.php
│   └── debug.php
├── TODO.md
├── .travis
│   └── travis-init.sh
└── .travis.yml
```

