# Usage

## php-tests options

```text
$ php-tests -h
Usage:
    php-tests [options]
Options:
    --debug               - run in debug mode
    -h, --help            - show help message and exit
    --upgrade             - update scripts
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

> Note: options order is important \
> [Notes](update_option.md) on using `--upgrade` option

## Links to used tools

- *PHPStan* - static analysis tool [phpstan/phpstan](https://github.com/phpstan/phpstan)
- *Psalm* - static analysis tool [vimeo/psalm](https://github.com/vimeo/psalm)
- *PHP_CodeSniffer* is an essential development tool that ensures your code remains clean and consistent [squizlabs/PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer)
- *PhpMetrics* provides metrics about PHP project and classes [phpmetrics/PhpMetrics](https://github.com/phpmetrics/PhpMetrics)
- *Multi-tester* - test your dependent packages [kylekatarnls/multi-tester](https://github.com/kylekatarnls/multi-tester)
- The SensioLabs *Security Checker* is a command line tool that checks if your application uses dependencies with known security vulnerabilities [sensiolabs/security-checker](https://github.com/sensiolabs/security-checker)
- *PHP VarDump Check* - to find forgotten variable dump [JakubOnderka/PHP-Var-Dump-Check](https://github.com/JakubOnderka/PHP-Var-Dump-Check)
- *git-chglog* - CHANGELOG generator [git-chglog/git-chglog](https://github.com/git-chglog/git-chglog) (Should be installed on your system)
- *DependencyGraph* - tool to help visualize the various dependencies between packages [innmind/dependency-graph](https://github.com/Innmind/DependencyGraph)

## Requirements to docker images

You can use your own docker images in `docker-compose.yml` and `docker-compose-debug.yml`. See [requirements](docker-images-requirements.md)
