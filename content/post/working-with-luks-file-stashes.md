---
title: "Working With LUKS File Stashes"
date: 2026-01-01T07:24:36+05:30
draft: true
---

`THIS POST IS A DRAFT`

LUKS is an incredible solution for encrypting entire partitions in Linux.
Often times, however, we can't afford to create new partitions inside a disk
without having to completely format the drive anew.

In this post, I will guide you through the process of creating and working
with LUKS container files that are encrypted at rest and can be decrypted on
demand with knowledge of the passphrase.

## Creating the image base

```sh
head --bytes=4G /dev/urandom > stash.img
```

## Format the image

### Including the LUKS header

```sh
cryptsetup luksFormat stash.img
```

### With a detached LUKS header

```sh
cryptsetup luksFormat stash.img --header stash.img.luks
```

In either case, cryptsetup will ask you to supply a passphrase which will secure
the contents of this container.


## Interacting with the image

This section shall describe mounting and unmounting the stash both with and without
super user privileges, although, I suppose most readers will be interested in latter
since that's the whole point of portable LUKS file stashes.

### With super user privileges

#### Mounting

```sh
mkdir -p /mnt/stash
cryptsetup open stash.img stash
mount /dev/mapper/stash /mnt/stash
```

#### Unmounting

```sh
umount /dev/mapper/stash
cryptsetup close stash
```

### Without super user privileges

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
