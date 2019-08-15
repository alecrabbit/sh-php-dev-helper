# Notes

## PHP-Tests

- [ ] Add magic number detector [povils/phpmnd](https://github.com/povils/phpmnd)
- [ ] Feature: run without docker(with local php installation)

---

- [x] Feature: Add value processing to `--cl` option, e.g. `--cl=0.2.0..0.2.4` will mean `git-chglog -o CHANGELOG.md 0.2.0..0.2.4`

## Moomba

- [ ] Feature: add `-l | --license` option
- [ ] Feature: initialize git repository, make first commit if user.email and user.name are set
- [ ] Feature: Add option to compare project files in the current dir with template `<name>` files, e.g. `--compare-with[=default]`
- [ ] Feature: Dir control: allow creating packages only in specified directories

---

- [x] Feature: During package creation make `.env` file with `USER_ID` and `CROUP_ID` vars for docker-compose files

## Common

- [ ] Feature: Add installed tools check during install
- [ ] Write tests? 🤦‍
  - [x] started 🎈

---

- [x] Feature: Enhanced notification message `Operation completed`
- [x] Feature: Add option `--notify` to enable notification message
