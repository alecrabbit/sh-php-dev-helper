# 🐇 PHP Dev Helper

## What is it

- [`php-tests`](.docs/php-tests.md) - tool to automate local testing
- [`moomba`](.docs/moomba.md)  - composer library creator script using template [alecrabbit/php-package-template](https://github.com/alecrabbit/php-package-template)
- [`build-image`](.docs/build-image.md) - convenient local docker image build tool (WIP)

See [demos](.demo/demos.md)

> Note: WIP, see [README.old.md](README.old.md)

## Installation

### Requirements

> Note : `moomba` script does not require `docker` or `docker-compose`

- docker
- docker-compose
(Docker Engine 17.04.0+)

### Install

Get your copy of specific version

> Note: Check [releases](https://github.com/alecrabbit/sh-php-dev-helper/releases) tab for the latest version number

 ```bash
 version="0.6.5"
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
