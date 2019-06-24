# Usage

## php-tests

```text
$ php-tests -h
Usage:
    php-tests [options]
Options:
    --debug               - run in debug mode
    -h, --help            - show help message and exit
    --update              - update scripts
    -V, --version         - show version

    -a, --all             - run all (substitutes -c, -s, --cs, -b)
    -b                    - enable php code sniffer beautifier
    --cl                  - update CHANGELOG.md
    -c, --coverage        - enable phpunit code coverage (includes -u)
    --cs                  - enable php code sniffer
    --ga                  - generate .gitattributes file
    -g, --graphs          - create dependencies graphs
    --metrics             - enable phpmetrics
    --multi               - enable multi-tester
    --phpstan             - enable phpstan
    --psalm               - enable psalm
    -s, --analyze         - enable static analysis tools (--phpstan and --psalm)
    --security            - enable security checks
    -t, --total           - all options enabled
    -u, --unit            - enable phpunit
    -v                    - enable check for forgotten var dumps
    --without-composer    - do not check for 'composer.json' file and 'vendor' dir
```

> Note: options order is important
