+++
title = "Working With LUKS File Stashes"
date = 2026-01-01T07:24:36+05:30
draft = false
tags = [
  "Linux",
  "LUKS",
  "Cryptography"
]
+++

LUKS is an incredible solution for encrypting entire partitions in Linux.
Often times, however, we can't afford to create new partitions inside a disk
without having to completely format the drive anew.

This post will guide you through the process of creating and working
with LUKS container files that are encrypted at rest and can be decrypted on
demand with knowledge of the passphrase.

## Creating the Image Base

```sh
head --bytes=4G /dev/urandom > stash.img
```

## Format the Image

The image can be formatted by either including the header in the image itself or
keeping a detached header.

In either case, `cryptsetup` will ask for passphrase which will secure
the contents of this container.

### Including the LUKS Header

```sh
cryptsetup luksFormat stash.img
```

### With a Detached LUKS Header

> Note: Using a detached LUKS header is unsupported by `udisksctl`. Mounting such images
can only be done using `cryptsetup` with superuser privileges.

```sh
cryptsetup luksFormat stash.img --header stash.img.luks
```

## Formatting the Drive with a Filesystem

Superuser privileges are required for this action. Run the following as root.

```sh
mkdir -p /mnt/stash
cryptsetup open stash.img stash # --header stash.img.luks
mkfs.ext4 /dev/mapper/stash
mount /dev/mapper/stash /mnt/stash
chown -R :users /mnt/stash
chmod -R g+rw /mnt/stash
umount /mnt/stash
cryptsetup close stash
```

## Interacting with the Image

This section shall describe mounting and unmounting the stash both with and without
superuser privileges, although, I suppose most readers will be interested in latter
since that's the whole point of portable LUKS file stashes.

### With Superuser Privileges

#### Mounting

The following commands will
- Create a mount point at `/mnt/stash`
- Open the image with `cryptsetup` as `/dev/mapper/stash`
- Mount the mapper device to the mount point

```sh
mkdir -p /mnt/stash
cryptsetup open stash.img stash # --header stash.img.luks
mount /dev/mapper/stash /mnt/stash
```

#### Unmounting

```sh
umount /dev/mapper/stash
cryptsetup close stash
```

### Without Superuser Privileges

#### Mounting

```sh
udisksctl loop-setup --file stash.img
```

This returns the path to a loop device, for example, `/dev/loop0`.

```sh
udisksctl unlock --block-device /dev/loop0
```

Enter the passphrase previously used for formatting the image. The drive should be accessible via a graphical file manager.

#### Unmounting

```sh
udisksctl lock --block-device /dev/loop0
udisksctl loop-delete --block-device /dev/loop0
```
