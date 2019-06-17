# Using --update option

```text
$ php-tests --update
Current version: 0.6.0
New version found: 0.6.1
Updating...
Installing package
0.6.0@c1729a8 -> 🆕 0.6.1@872b081
Update complete
```

You can add version to update to (e.g. to rollback after update)

```text
$ php-tests --update=0.6.0
You are already using this version: 0.6.0
```

> Note: Check [releases](https://github.com/alecrabbit/sh-php-dev-helper/releases) tab for the latest version number

Also allowed to use `master` and `develop` versions

```bash
php-tests --update=master
```

```bash
php-tests --update=develop
```

> Note: update function considers `master` or `develop` versions as latest. To update later to a numbered version you should use the option `--update=<version-number>`. Simple `--update` won't work as you expect.
