# PHP Dev Helper Script

## Usage

### As a part of php template

used with [alecrabbit/php-package-template](https://github.com/alecrabbit/php-package-template/)

### Standalone

You can install this script to your `~/.local/bin` dir. Make sure your `.profile` file contains these lines:

```bash
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
```

### Options

```text
$ php-tests -h
Usage:
    php-tests-dev [options]
Options:
    -h                    - show help message and exit
    -a, --all             - run all (not includes --metrics and --multi)
    -b                    - enable php code sniffer beautifier
    -c, --coverage        - enable phpunit code coverage (includes -u)
    --cs                  - enable php code sniffer
    --metrics             - enable phpmetrics
    --multi               - enable multi-tester
    --phpstan             - enable phpstan
    --psalm               - enable psalm
    -s, --analyze         - enable static analysis tools (--phpstan and --psalm)
    -u, --unit            - enable phpunit
    --update              - update script
    -V, --version         - show version
    --without-composer    - do not check for 'composer.json' file and 'vendor' dir

Note: options order is important
```

> Notes on using `--update` option: [link](.docs/update_option.md)

### Links

- [phpstan/phpstan](https://github.com/phpstan/phpstan)
- [vimeo/psalm](https://github.com/vimeo/psalm)
- [squizlabs/PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer)
- [phpmetrics/PhpMetrics](https://github.com/phpmetrics/PhpMetrics)
- [kylekatarnls/multi-tester](https://github.com/kylekatarnls/multi-tester)

### File structure

```text
.
├── moomba
├── php-dev-helper-lib
│   ├── BUILD
│   ├── commands.sh
│   ├── functions.sh
│   ├── options.sh
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
│   ├── updater.sh
│   └── VERSION
└── php-tests
```

> Note: `moomba` is an upcoming package installation script

### Tested Operating Systems

OS                                  |
----------------------------------- |
Ubuntu Linux (18.04 LTS)            |
