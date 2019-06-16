# 🐇 PHP Dev Helper

## What is it

- `php-tests` - tool to automate local testing
- `moomba`  - composer library creator script using template [alecrabbit/php-package-template](https://github.com/alecrabbit/php-package-template)
- `build-image` - convenient local docker image build tool (WIP)

See [demos](.demo/demos.md)

## Installation

### Requirements

> Note : `moomba` script does not require `docker` or `docker-compose`

- docker
- docker-compose (17.04.0+)

### Local installation

Get your copy of specific version

> Note: Check [releases](https://github.com/alecrabbit/sh-php-dev-helper/releases) tab for the latest version number

 ```bash
 version="0.6.0"
 wget -qO- "https://github.com/alecrabbit/sh-php-dev-helper/archive/${version}.tar.gz" \
 | tar -xzv && cd sh-php-dev-helper-${version} && ./install
 ```

Follow the instructions of install script.

Make sure your `.profile` file contains these lines:

```bash
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
```

Create your own `.templates_settings`, use `.templates_settings.dist` as example ([settings](.docs/moomba-settings.md))

### File structure

```text
.
├── moomba
├── php-dev-helper-lib
│   ├── BUILD
│   ├── commands.sh
│   ├── functions.sh
│   ├── mmb.sh
│   ├── options.sh
│   ├── .settings
│   │   ├── .sh-pdh-settings.dist
│   │   └── .templates_settings.dist
│   ├── settings.sh
│   ├── sh-modules
│   │   ├── capitalize.sed
│   │   ├── colored.sh
│   │   ├── console.sh
│   │   ├── core.sh
│   │   ├── docker.sh
│   │   ├── github.sh
│   │   ├── git.sh
│   │   ├── updater.sh
│   │   └── version.sh
│   ├── templates
│   │   └── .licenses
│   │       ├── Apache-2.0
│   │       ├── BSD-2-Clause
│   │       ├── BSD-3-Clause
│   │       ├── GPL-3.0
│   │       └── MIT
│   ├── tmp.sh
│   ├── updater.sh
│   └── VERSION
└── php-tests
```

## Usage

### Options

#### php-tests

```text
$ php-tests -h
Usage:
    php-tests [options]
Options:
    -h, --help            - show help message and exit
    -a, --all             - run all (not includes --metrics and --multi)
    -b                    - enable php code sniffer beautifier
    -c, --coverage        - enable phpunit code coverage (includes -u)
    --cs                  - enable php code sniffer
    --metrics             - enable phpmetrics
    --multi               - enable multi-tester
    --phpstan             - enable phpstan
    --psalm               - enable psalm
    -s, --analyze         - enable static analysis tools (--phpstan and --psalm)
    --security            - enable security checks
    -u, --unit            - enable phpunit
    --update              - update script
    -V, --version         - show version
    -v                    - enable check for forgotten var dumps
    --without-composer    - do not check for 'composer.json' file and 'vendor' dir

Note: options order is important
```

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
├── composer.json
├── docker-compose-debug.yml
├── docker-compose.yml
├── .dockerignore
├── .gitattributes
├── .github
│   └── ISSUE_TEMPLATE.md
├── .gitignore
├── LICENSE
├── phpcs.xml
├── phpunit.xml
├── README.md
├── .scrutinizer.yml
├── src
│   └── LooneyTunes
│       └── BasicClass.php
├── TERMINAL_TITLE
├── tests
│   ├── BasicTest.php
│   ├── bootstrap.php
│   └── debug.php
├── TODO.md
├── .travis
│   └── travis-init.sh
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

> Note: it should work practically on any linux installation.

OS                                  |
----------------------------------- |
Ubuntu Linux (18.04 LTS)            |
Ubuntu Linux (19.04)                |
