# 🐇 PHP Dev Helper

## What is it

- [`php-tests`](.docs/php-tests.md) - tool to automate local testing
- [`moomba`](.docs/moomba.md)  - composer library creator script using template [alecrabbit/php-package-template](https://github.com/alecrabbit/php-package-template)
- [`build-image`](.docs/build-image.md) - convenient local docker image build tool (WIP)

> Note: WIP, see [README.old.md](README.old.md)

## Installation

### Requirements

> Note : `moomba` script does not require `docker` or `docker-compose`

- docker
- docker-compose
(Docker Engine 17.04.0+)

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

### Project's [file structure](.docs/project-file-structure.md)
