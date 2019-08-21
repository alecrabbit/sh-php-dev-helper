# Using --upgrade option

> Asciinema [cast](https://asciinema.org/a/262567)

```text
$ php-tests --upgrade
Current version: 0.7.0
New version found: 0.7.1
Updating...
Installing package
0.7.0@c1729a8 -> 🆕 0.7.1@872b081
Update complete
```

You can add version to update to (e.g. to rollback after update)

```text
$ php-tests --upgrade=0.7.0
You are already using this version: 0.7.0
```

> Note: Check [releases](https://github.com/alecrabbit/sh-php-dev-helper/releases) tab for the latest version number

Also allowed to use `master` and `develop` versions

```bash
php-tests --upgrade=master
```

```bash
php-tests --upgrade=develop
```

> Note: upgrade function considers `master` or `develop` versions as latest. To upgrade later to a numbered version you should use the option `--upgrade=<version-number>`. Simple `--upgrade` won't work as you expect.
