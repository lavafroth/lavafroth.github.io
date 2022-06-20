---
title: "Operation Oni, Operation Orchid"
tags:
- CTF
- Forensics
- PicoCTF
- The Sleuth Kit
date: 2022-03-18T07:10:17+05:30
draft: false
---

In this post, we'll walk through the Operation Oni and Operation Orchid challenges
from the PicoCTF competition held in March 2022. Both of these challenges involve
the use of tools from The Sleuth Kit suite. In order to follow along, I'd recommend
installing the suite of tools.

# Operation Oni

The challenge has an associated instance which we'll need to log into using SSH using
the following command:
```bash
ssh -i key_file -p 61948 ctf-player@saturn.picoctf.net
```
We are provided with a compressed disk image `disk.img.gz` which we'll decompress with:

```bash
gunzip disk.img.gz
```

To list the partition table for the given disk image, we will use the `mmls` command.
If `mmls` is unable to properly determine the filesystem of a given volume, we can
specify it using the `-t` flag.

Let's run `mmls` on the disk image by itself.

```bash
mmls disk.img
```

```none 
DOS Partition Table
Offset Sector: 0
Units are in 512-byte sectors

      Slot      Start        End          Length       Description
000:  Meta      0000000000   0000000000   0000000001   Primary Table (#0)
001:  -------   0000000000   0000002047   0000002048   Unallocated
002:  000:000   0000002048   0000206847   0000204800   Linux (0x83)
003:  000:001   0000206848   0000471039   0000264192   Linux (0x83)
```

We can see two linux partitions, one starting at offset `2048` and another at `206848`

In order to list the files in a given volume, we can use the `fls` command. For this,
we will need to specify the offset of the volume using the `-o` flag.

Let's take a look at the first partition at offset `2048`.

```bash
fls -o 2048 disk.img
```

```none
d/d 11: lost+found
r/r 12: ldlinux.sys
r/r 13: ldlinux.c32
r/r 15: config-virt
r/r 16: vmlinuz-virt
r/r 17: initramfs-virt
l/l 18: boot
r/r 20: libutil.c32
r/r 19: extlinux.conf
r/r 21: libcom32.c32
r/r 22: mboot.c32
r/r 23: menu.c32
r/r 14: System.map-virt
r/r 24: vesamenu.c32
V/V 25585:      $OrphanFiles
```

This looks like the boot partition of a linux installation.
Let's move on to the next partition at offset `206848`.

```bash
fls -o 206848 disk.img
```
```none 
d/d 458:        home
d/d 11: lost+found
d/d 12: boot
d/d 13: etc
d/d 79: proc
d/d 80: dev
d/d 81: tmp
d/d 82: lib
d/d 85: var
d/d 94: usr
d/d 104:        bin
d/d 118:        sbin
d/d 464:        media
d/d 468:        mnt
d/d 469:        opt
d/d 470:        root
d/d 471:        run
d/d 473:        srv
d/d 474:        sys
V/V 33049:      $OrphanFiles
```

This looks like the standard linux filesystem hierarchy where we can see the `/home` and `/root` directories.
Let's investigate the `/root` directory. To do so, we will append the inode number associated with the
directory as an argument to `fls`.

The inode number of `/root` is `470` here.
```
d/d 470:        root
```

We'll run the previous command with the inode number.

```bash
fls -o 206848 disk.img 470
```

```none
r/r 2344:       .ash_history
d/d 3916:       .ssh
```

Here, we can see the `.ssh` directory and the root user's shell history file. We'll try listing
the `.ssh` directory. Again, we'll supply the associated inode number, here, `3916`.

```bash
fls -o 206848 disk.img 3916
```

```
r/r 2345:       id_ed25519
r/r 2346:       id_ed25519.pub
```

Here, we can see a pair of SSH private and public keys. The one ending in `.pub` being the public key.
Private keys are often used as an alternative to password authentication to SSH into a machine.
We'll dump the content of this file using the `icat` command. For using this command, we'll need
to specify the offset of the volume and the inode number of the file, `2345` here.

We'll redirect the output of the command into a file called `key_file`.

```bash
icat -o 206848 disk.img 2345 > key_file
```

We can try using the private key to authenticate since this key is not password protected.
Before running the SSH command, we must set the permissions on the file to read / write only
by us.

```bash
chmod 600 key_file
```

Let's use the command that was provided with the challenge.

```bash
ssh -i key_file -p 61948 ctf-player@saturn.picoctf.net
```

We get a successful login as the user `ctf-player`. Let's list the files in our
home directory.

```bash
ctf-player@challenge:~$ ls
```
```none
flag.txt
```

We'll view the contents of the `flag.txt` file.

```bash
ctf-player@challenge:~$ cat flag.txt
```

```none
picoCTF{k3y_5l3u7h_af277f77}
```

# Operation Orchid

We are provided with a disk image `disk.flag.img.gz` which we'll decompress with:
```bash
gunzip disk.flag.img.gz
```

Let's look at the partition table using `mmls`.

```bash
mmls disk.flag.img
```

```none
DOS Partition Table
Offset Sector: 0
Units are in 512-byte sectors

      Slot      Start        End          Length       Description
000:  Meta      0000000000   0000000000   0000000001   Primary Table (#0)
001:  -------   0000000000   0000002047   0000002048   Unallocated
002:  000:000   0000002048   0000206847   0000204800   Linux (0x83)
003:  000:001   0000206848   0000411647   0000204800   Linux Swap / Solaris x86 (0x82)
004:  000:002   0000411648   0000819199   0000407552   Linux (0x83)
```

Listing the volume at offset `2048` using `fls`, we see a boot partition.

```bash
fls -o 2048 ./disk.flag.img
```

```none
d/d 11: lost+found
r/r 12: ldlinux.sys
r/r 13: ldlinux.c32
r/r 15: config-virt
r/r 16: vmlinuz-virt
r/r 17: initramfs-virt
l/l 18: boot
r/r 20: libutil.c32
r/r 19: extlinux.conf
r/r 21: libcom32.c32
r/r 22: mboot.c32
r/r 23: menu.c32
r/r 14: System.map-virt
r/r 24: vesamenu.c32
V/V 25585:      $OrphanFiles

```

We'll move on to the next Linux partition at offset `411648`.

```bash
fls -o 411648 ./disk.flag.img
```
```none
d/d 460:        home
d/d 11: lost+found
d/d 12: boot
d/d 13: etc
d/d 81: proc
d/d 82: dev
d/d 83: tmp
d/d 84: lib
d/d 87: var
d/d 96: usr
d/d 106:        bin
d/d 120:        sbin
d/d 466:        media
d/d 470:        mnt
d/d 471:        opt
d/d 472:        root
d/d 473:        run
d/d 475:        srv
d/d 476:        sys
d/d 2041:       swap
V/V 51001:      $OrphanFiles
```

Let's try listing the home folder of the root user at `/root`.
```none
d/d 472:        root
```
We'll use its inode number, `472`.

```bash
fls -o 411648 ./disk.flag.img 472
```
```none
r/r 1875:       .ash_history
r/r * 1876(realloc):    flag.txt
r/r 1782:       flag.txt.enc
```

We can dump the contents of the `flag.txt` file using `icat` like we did
previously.

```bash
icat -o 411648 ./disk.flag.img 1876
```

```none
           -0.881573            34.311733
```

A set of coordinates? Latitudes and longitudes? Not very helpful.
Let's dump `flag.txt.enc` to a file we can work on later.

```bash
icat -o 411648 ./disk.flag.img 1782 > flag.txt.enc
```

Let's investigate the shell history to see what the root user was upto the last time.

```bash
icat -o 411648 ./disk.flag.img 1875
```
```none
touch flag.txt
nano flag.txt 
apk get nano
apk --help
apk add nano
nano flag.txt 
openssl
openssl aes256 -salt -in flag.txt -out flag.txt.enc -k unbreakablepassword1234567
shred -u flag.txt
ls -al
halt
```

Ah! So they encrypted the original `flag.txt` with AES256 using the `openssl` command.
We can see the key that was supplied to the command with the `-k` flag.

Now that we know the key, we can decrypt the `flag.txt.enc` file.

We'll use the `-d` flag for decryption, set the input file, the argument to the `-in` flag,
to `flag.txt.enc` and omit the `-out` flag so that it outputs to `stdout`.

```bash
openssl aes256 -d -salt -in flag.txt.enc -k unbreakablepassword1234567
```

```none
*** WARNING : deprecated key derivation used.
Using -iter or -pbkdf2 would be better.
bad decrypt
140377178797312:error:06065064:digital envelope routines:EVP_DecryptFinal_ex:bad decrypt:crypto/evp/evp_enc.c:610:
picoCTF{h4un71ng_p457_17237fce}
```

There we have it, we've captured the flag.
