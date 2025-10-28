## 1.0.0 - Oct. 2025

- New CLI options, `--encrypt`, `--no-encrypt`, `--export-pass`, `--import-pass`.
- Update the destination to `/mnt/sgpg/`. Use `/mnt/sgpg/Persistent` only if the directory exist (compatible with [Tail Linux](https://tails.net/doc/persistent_storage/index.en.html)).
- Create a directory `/mnt/sgpg/<key-name>/` for each key.
- Can save (export/import) passwords from [pass](https://www.passwordstore.org/) by incremental save

### Bug fixes

- Correct permission when move archive, we can't list keys with wrong permissions.
- Don't check for `*.cert` when create archives, only `*.key`
- Correct the last element returned from array for `--last-lesser` or `--last-master`

### Manual intervention

For those using a previous version, they need to manually import the last master key and re export keys:

    sgpg --path-key /mnt/sgpg/<keymaster>.tar --edit-key
    sgpg --export

## 0.1.0, release 09/10/24

- New `.github/workflow` to publish package on GitHub.
- New command line options
- `--disk-encrypt` if need to use `cryptsetup` or not.
- `--export` create master and lesser archive.

## 0.0.1, release 07/27/24

- Initial push, code release!
