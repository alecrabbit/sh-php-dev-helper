# 🐇 PHP Dev Helper

## Workflow [example](https://asciinema.org/a/262591)

## What is it

> Note: WIP

This is a set of shell scripts:

- [`php-tests`](.docs/php-tests.md) - tool to automate local testing
- [`moomba`](.docs/moomba.md)  - composer library creator script using template [alecrabbit/php-package-template](https://github.com/alecrabbit/php-package-template)
- [`build-image`](.docs/build-image.md) - convenient local docker image build tool (WIP)

See [demos](.demo/demos.md)

## Update

> [How to update](.docs/update_option.md)

## Installation

### Requirements

> Note : `moomba` script does not require `docker-compose` nor `docker`

> Docker Engine 17.04.0+

- docker
- docker-compose

### Install

Get your copy of specific version

> Note: Check [releases](https://github.com/alecrabbit/sh-php-dev-helper/releases) tab for the latest version number

 ```bash
 version="0.7.0"
 ```
 ```bash
wget -qO- "https://github.com/alecrabbit/sh-php-dev-helper/archive/${version}.tar.gz" \
| tar -xz && cd sh-php-dev-helper-${version} && echo ${version} > php-dev-helper/VERSION \
&& ./install && cd ..
 ```

Follow the instructions of install script.

Assuming your install path is `~/.local/bin`, make sure your `.profile` file contains these lines:

```bash
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
```

Create your own `.templates_settings`, use `.templates_settings.dist` as example

```bash
cp $HOME/.local/bin/php-dev-helper/.settings/.templates_settings.dist \
$HOME/.local/bin/php-dev-helper/.settings/.templates_settings
```

And edit that [file](.docs/moomba-settings.md) as you wish

> Note: if there is no `.templates_settings` file internal defaults are used.

### Project's [file structure](.docs/project-file-structure.md)

### Tested Operating Systems

> Note: Windows is NOT supported.

Supported OS                        |
----------------------------------- |
Ubuntu Linux (18.04 LTS)            |
Ubuntu Linux (19.04)                |

> Note: it should work practically on any linux installation. Known [issues.](.docs/known-issues.md)
