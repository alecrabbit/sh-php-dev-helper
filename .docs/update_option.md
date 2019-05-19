# Using --update option

You can add version to update to

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

> Note: after updating to `master` or `develop` update function considers these versions as latest. To update to numbered version you should use option `--update=<version-number>`