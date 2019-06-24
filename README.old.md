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

### Links to used tools

- *PHPStan* - static analysis tool [phpstan/phpstan](https://github.com/phpstan/phpstan)
- *Psalm* - static analysis tool [vimeo/psalm](https://github.com/vimeo/psalm)
- *PHP_CodeSniffer* is an essential development tool that ensures your code remains clean and consistent [squizlabs/PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer)
- *PhpMetrics* provides metrics about PHP project and classes [phpmetrics/PhpMetrics](https://github.com/phpmetrics/PhpMetrics)
- *Multi-tester* - test your dependent packages [kylekatarnls/multi-tester](https://github.com/kylekatarnls/multi-tester)
- The SensioLabs *Security Checker* is a command line tool that checks if your application uses dependencies with known security vulnerabilities [sensiolabs/security-checker](https://github.com/sensiolabs/security-checker)
- *PHP VarDump Check* - to find forgotten variable dump [JakubOnderka/PHP-Var-Dump-Check](https://github.com/JakubOnderka/PHP-Var-Dump-Check)
- *git-chglog* - CHANGELOG generator [git-chglog/git-chglog](https://github.com/git-chglog/git-chglog)
- *DependencyGraph* - tool to help visualize the various dependencies between packages [innmind/dependency-graph](https://github.com/Innmind/DependencyGraph)

### Tested Operating Systems

> Note: Windows is not supported.
> Note: it should work practically on any linux installation.

Supported OS                        |
----------------------------------- |
Ubuntu Linux (18.04 LTS)            |
Ubuntu Linux (19.04)                |

> Note: you can encounter some issues on:
>
> OS                                  |
> ----------------------------------- |
> [Alpine](.docs/alpine-issues.md) linux                        |

### Requirements to docker images

You can use your own docker images in `docker-compose.yml` and `docker-compose-debug.yml`. See [requirements](.docs/docker-images-requirements.md)
