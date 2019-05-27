# Using --update option

```text
$ php-tests --update
Current version: 0.2.4
New version found: 0.2.5
Updating...
Installing package
Update complete: 0.2.4@b191f57 -> 🆕 0.2.5@c656fcf
```

You can add version to update to (e.g. to rollback after update)

```text
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