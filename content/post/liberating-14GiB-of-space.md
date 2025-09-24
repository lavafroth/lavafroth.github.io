---
title: "Liberating 14GiB of disk space"
tags:
- Powershell
- Windows
- Workflow
date: 2022-02-21T13:15:26+05:30
draft: false
---

The idea is simple:
- Remove all duplicates, including zero length files
- Fine tuning: Hand-pick and remove files deemed unnecessary

Since the mileage for second step might vary from person to person, I'll elaborate on the first step.
  
I chose [jdupes](https://codeberg.org/jbruchon/jdupes) for deleting the duplicates because it's open-source and is cross platform.

For a given folder we would run the following to wipe the duplicates:

```powershell
jdupes --recurse --delete --no-prompt --zero-match .
```

This will recursively delete all the duplicates except the source file without prompting for a confirmation.
It will also consider zero length files to be duplicates.
 
The target OS is Windows, which has the glaring problem of *drives*.

There could be files unique in a given drive but are actually duplicates
in the inter-drive space. There are two ways to combat this.

### Rinse, move, repeat
  - Run jdupes on a drive to free some space
  - Move some data from other drives into the current drive to fill it up again
  - Repeat

This, obviously, is a terrible idea beacause we have the overhead cost of moving the files after each run
as well as the fact that we have to run jdupes exhaustively for many iterations.

### Single pass with hardlinks
  - Pick a random drive as the parent node
  - Hardlink all the other drives to the parent
  - Run jdupes

Consider the following scenario

- Parent drive: A
  - Child drive: E
  - Child drive: B
  - etc.

To create the hardlink of `E` in `A`, we would run the following in powershell.
 
```powershell
New-Item -ItemType HardLink -Path A:\Edrive -Value E:\
```

We repeat this for the rest of the drives like drive `B` where
- `Edrive` becomes `Bdrive`
- `E:` becomes `B:`

When we run jdupes from the `A` drive with

```sh
cd A:
jdupes --recurse --delete --no-prompt --zero-match .
```

it traverses the hardlinks and removes duplicates in all the linked drives.

Finally we can remove the hardlinks

```powershell
rm A:\Edrive
```

> Note: Do not run jdupes at `SYSTEMROOT` (the root of `C:` drive for most people)
as there are legitimate duplicates which, if deleted, can brick a system. I'd recommend
running jdupes in individual directories like _Music_, _Documents_, etc.
