## 1.0.0

- New CLI options, `--encrypt`, `--no-encrypt`, `--export-pass`, `--import-pass`.
- Update the destination to `/mnt/sgpg/`. Use `/mnt/sgpg/Persistent` only if the directory exist.
- Create a directory `/mnt/sgpg/<key-name>/` for each user.
- Can save passwords from [pass](https://www.passwordstore.org/) by incremental save with rsync

### Bug fixes

- Correct permission when move archive, we can't list keys with wrong permissions.
- Don't check for `*.cert` when create archives, only `*.key`

## 0.1.0, release 09/10/24

- New `.github/workflow` to publish package on GitHub.
- New command line options
- `--disk-encrypt` if need to use `cryptsetup` or not.
- `--export` create master and lesser archive.

## 0.0.1, release 07/27/24

- Initial push, code release!
