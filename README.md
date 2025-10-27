# sGPG

<div align="center">
<br/>

[![Gem Version](https://badge.fury.io/rb/sgpg.svg)](https://badge.fury.io/rb/sgpg)

</div>

Short GnuPG, tool for manage your GPG key (backup tarball, unprivileged keys, etc)

Followed my [post](https://szorfein.github.io/gpg/build-secure-gpg-key/) to
create a secure GnuPG key, I need to update my keys all the 6 month on each PC.
It's a very annoying task without scripts so I've develop this tool in
Ruby to gain in time and mental sanity :).

About GnuPG security in brief and what's this tool help you to manage:

- You don't need a passphrase to protect your master key (if your follow all advice)
- Never store your master key on your computer, store it on an encrypted device.
- Always use an unprivileged key on your working machine.
- Create short live keys for Sign, Encrypt and Auth, maximum 6 month (less is better).
- When importing your master keys, (try to) be offline.

To start, you always need to owm/create a GnuPG key as well.

    gpg --expert --full-generate-key

## Install sGPG locally

    gem install --user-install sgpg

You also need to install some dependencies:

- Tar
- Cryptsetup (if you want to encrypt/decrypt the disk)
- Shred (to remove the master key efficiently)
- And GnuPG of course.

## Configure

The config file is located at `~/.config/sgpg/config.yml`. You can use the command line with `--save`:

    sgpg --disk /dev/sdc2 --encrypt --key szorfein@protonmail.com --save

You can register the disk/by-id or disk/by-uuid if you prefer.

    sgpg --disk /dev/disk/by-id/wmn-0xXXXX-part2 --encrypt --save

## Usage

    sgpg -h

When subkeys expire:

    sgpg --last-master --edit-key # update expired keys, change password, etc...
    sgpg --export # create master and lesser archive
    sgpg --close # unmount and close disk

Import the last unprivileged key (laptop and other)

    sgpg --last-lesser --edit-key # trust (555)
    sgpg --close # unmount and close disk

Manually choose an archive

    sgpg --open # mount disk
    sgpg --path-key /mnt/sgpg/Persistent/archive.tar --edit-key

## Gem push

    gem login
    gem build sgpg.gemspec
    gem push sgpg-0.0.1.gem
