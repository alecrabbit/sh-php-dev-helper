# Usage

## moomba

```text
$ moomba -h
Usage:
    moomba [options]
Options:
    --debug               - run in debug mode
    -h, --help            - show help message and exit
    --update              - update scripts
    -V, --version         - show version

    -p                    - set package name
    -o                    - set owner
    -s                    - set owner namespace
    -n                    - set package namespace
    -x                    - do not use package namespace
    --update-default      - update default template
    -t                    - use template
    -y, --no-interaction      - do not ask any interactive question

Example:
    moomba -p=new-package -o=mike
```

> Note: options order is important \
> [Notes](.docs/update_option.md) on using `--update` option
