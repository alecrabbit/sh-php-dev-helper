# PHP Dev Helper Script

used with [alecrabbit/php-package-template](https://github.com/alecrabbit/php-package-template/)

## Usage

### Standalone

You can install this script to your `~/.local/bin` dir. Make sure your `.profile` file contains these lines:

```bash
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
```

#### File structure

```text
.
├── php-dev-helper-lib
│   ├── BUILD
│   ├── commands.sh
│   ├── helpers.sh
│   ├── options.sh
│   ├── settings.sh
│   ├── updater.sh
│   ├── VERSION
│   └── version.sh
├── php-tests
└── sh-modules
    ├── colored.sh
    ├── console.sh
    ├── core.sh
    └── github.sh
```
