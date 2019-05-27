# Using --update option

You can add version to update to (e.g. to rollback after update)

```bash
$ php-tests --update=0.1.54
You are already using this version: 0.1.54
```

> Note: Check [releases](https://github.com/alecrabbit/sh-php-dev-helper/releases) tab for latest version number

Also allowed to use `master` and `develop` versions

```bash
php-tests --update=master
```

```bash
php-tests --update=develop
```

> Note: update function considers `master` or `develop` versions as latest. To update later to a numbered version you should use the option `--update=<version-number>`. Simple `--update` won't work as you expect.