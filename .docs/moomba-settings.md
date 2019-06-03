# `moomba` settings

Create your own settings in `.templates_settings` file.

Example to use - `.templates_settings.dist` file:

```text
TMPL_PACKAGE_DIR_PREFIX="php-"
TMPL_PACKAGE_DIR_SUFFIX=""

TMPL_PACKAGE_OWNER="mike"
TMPL_PACKAGE_OWNER_NAME="Mike Wazowski"
TMPL_PACKAGE_OWNER_NAMESPACE="MikeWazowski"
### License type
# "Apache-2.0" "BSD-2-Clause" "BSD-3-Clause" "GPL-3.0" "MIT"
TMPL_PACKAGE_LICENSE="Apache-2.0"

# TMPL_DEFAULT_TEMPLATE="default"
# TMPL_TEMPLATE_VERSION="master"
# TMPL_PACKAGE_NAME="monster-tools"
# TMPL_PACKAGE_DESCRIPTION="Awesome package description"
# TMPL_PACKAGE_NAMESPACE="MonsterTools"
# TMPL_PACKAGE_DIR="php-monster-tools"
# TMPL_PACKAGE_TERMINAL_TITLE_EMOJI="📦"
```

> Note: if there is no `.templates_settings` file internal defaults are used.
