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
  
I chose [jdupes](https://github.com/jbruchon/jdupes) as my weapon of choice for finding and removing the duplicates.
It's free and open-source and is cross platform.

For a given folder we would run the following to wipe the duplicates:

```powershell
jdupes -rdNz .
```

Let me explain the flags:

Flag|Explanation
-|-
`r`|Find duplicates recursively
`d`|Delete duplicates
`N`|No-prompt: when used with the `d` flag, it keeps the first file and removes all the others in a collection of duplicates 
`z`|Consider zero length files to be duplicates

The `.` here means the current directory.

Please read the tool's help page for more granular control during the cleanup.
 
The computer in question runs Microsoft Windows and there's a thing
common in almost all Windows setups, *drives*.

This was a glaring issue. There could be files that are unique in a given drive but are actually duplicates
in the inter-drive space. There are two ways to combat this.

First method:
- Run jdupes on a drive to free some space
- Move some data from other drives into the current drive to fill it up again
- Repeat

This, obviously, is a terrible idea beacause we have the overhead cost of moving the files after each run
as well as the fact that we have to run jdupes exhaustively for many iterations.

Second (and probably the more elegant) method:
- From the space of drives to be cleaned, pick a random drive (parent)
- Hardlink all the other drives from the space into the drive we picked previously (children)
- Run jdupes

This method only requires us to run jdupes once.

Assuming we have picked the `A` drive as the parent and the `E` drive is one of the children,
we would run the following powershell command to hardlink `E` drive to a folder called `Edrive` in `A`.
 
```powershell
New-Item -ItemType HardLink -Path A:\Edrive -Value E:\
```

We would repeat this for all the children drives, modifying the command
ever so slightly to meet our needs.

This implies that when we run jdupes from the root of the `A` drive, it would
traverse the hardlinks and find duplicates in the inter-drive space.

Next, we'd go to the root of `A` drive and run jdupes.
```powershell
A:
jdupes -rdNz .
```

Finally we remove the hardlinks:
```powershell
rm A:\Edrive
```

> Note: Do not run jdupes at `SYSTEMROOT` (`C:` drive for most people)
as there are legitimate duplicates which, if deleted, can brick a system. I'd recommend
running jdupes in individual directories like _Music_, _Documents_, etc.
