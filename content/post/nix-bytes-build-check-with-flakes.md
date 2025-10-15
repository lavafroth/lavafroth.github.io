---
title: "Nix bytes: Check if a package builds with flakes"
date: 2025-10-15T18:11:15+05:30
draft: false
---

- Ensure flakes are enabled
- Create the package derviation file in `./package.nix`
- Add the following to `builder.nix`

```nix
(import <nixpkgs> {}).callPackage ./package.nix { }
```

- Run `nix build`  on it

```sh
nix build -f ./builder.nix
```
