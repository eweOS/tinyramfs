# Tinyramfs

Tiny initramfs written in POSIX shell for eweOS, forked from https://github.com/illiliti/tinyramfs

## Features

- No `local`'s, no bashisms, only POSIX shell
- Portable, not distro specific
- Easy to use configuration
- Make time and init time hooks
- mdev supported
- Resume from swap partition

## Dependencies

* POSIX make (build time)
* POSIX utilities
* POSIX shell
* `switch_root`
* `mount`
* `cpio`
* `ldd`
  - Optional. Required for copying binary dependencies
* `strip`
  - Optional. Required for reducing image size by stripping binaries
* `blkid`
  - Optional. Required for UUID, LABEL, PARTUUID support
* `mdev` OR CONFIG_UEVENT_HELPER
  - Optional. Required for modular kernel, /dev/mapper/* and /dev/disk/* creation
* `busybox loadkmap` OR `kbd loadkeys`
  - Optional. Required for keymap support
* `plymouth`
  - Optional. Required for plymouth support
* `kmod` OR `busybox modutils` with [patch](https://gist.github.com/illiliti/ef9ee781b5c6bf36d9493d99b4a1ffb6) (already included in KISS Linux)
  - Optional. Required if kernel compiled with loadable external modules

## Installation

```sh
make PREFIX=/usr install
```

## Documentation

[here](doc/)

## Thanks

[E5ten](https://github.com/E5ten)
[dylanaraps](https://github.com/dylanaraps)

## Donate

You can donate the [original project](https://github.com/illiliti/tinyramfs) if you like this project

BTC: 1BwrcsgtWZeLVvNeEQSg4A28a3yrGN3FpK
