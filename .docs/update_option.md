# Using --update option

You can add version to update to(e.g. to rollback after update)

```bash
$ php-tests --update=0.0.47
You are already using this version: 0.0.47
```

Also allowed to use `master` and `develop` versions

```bash
php-tests --update=master
```

```bash
php-tests --update=develop
```

> Note: update function considers `master` or `develop` versions as latest. To update later to numbered version you should use option `--update=<version-number>`. Simple `--update` won't work.