# Sgpg
Short gpg, tool for manage your gpg key (backup tarball, unprivileged keys, etc)

Followed my [post](https://szorfein.github.io/gpg/build-secure-gpg-key/) to
create a secure gpg key, i need to update my key all the 6 month on each PC
 and each time, it's very very annoying so i build this tool to gain in time
 and sanity :).

So with this tool, 'i,you,we' should use no more than 3 commands max instead of 50...

You always need to create a gpg key as well

    gpg --expert --full-generate-key

## Install sgpg locally

    gem install sgpg

You also need to install dependencies: tar, cryptsetup, shred and gpg.

## Configure
The config is located at ~/.config/sgpg/config.yml. You can use the command line with `--save`:

    sgpg --disk /dev/sdc2 --disk-encrypt --key szorfein@protonmail.com --save

You can register the disk/by-id or disk/by-uuid if you prefer.

    sgpg --disk /dev/disk/by-id/wmn-0xXXXX-part2 --disk-encrypt --save

## Usage

    sgpg -h

When subkeys expire:

    sgpg --last-master --edit-key # update expired keys, change password, etc...
    sgpg --export
    sgpg --close # unmount and close disk

Import the last unpriviliged key (laptop and other)

    sgpg --last-lesser --edit-key # trust (555)
    sgpg --close # unmount and close disk

## Gem push

    gem login
    gem build sgpg.gemspec
    gem push sgpg-0.0.1.gem

