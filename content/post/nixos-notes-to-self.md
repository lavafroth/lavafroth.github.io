---
title: "NixOS Notes to Self"
date: 2025-09-14T18:31:52+05:30
draft: false
---

A dedicated post collecting solutions to minor NixOS headaches.

## `nixos-rebuild` shows no network activity

On rare occasions, a system rebuild will get stuck while downloading a package from a source.
No network activity, no timeout, no writes to the nix store.

```
root@rahu /h/u/dotfiles (main)# nixos-rebuild boot --flake .
building the system configuration...
[0/9 built, 1/0/1 copied (0.0/681.0 MiB), 0.0/670.5 MiB DL] fetching linux-firmware-20250808-zstd from https://cache.nixos.org
```

This issue persists if the build command is simply rerun.
According to @manveru from the NixOS discourse, `nix-daemon` has a bug where it might
not close a connection to the source, with no timeout context. Force kill it with

```sh
sudo pkill -9 nixos-daemon
```

Now reissue the build.


## command-not-found unable to connect to database

The `programs.sqlite` is only generated for the `nixos-` prefixed channels.
This likely means that you are using NixOS unstable. If this is the case,
ensure you use the unstable channel using these commands as root:

```sh
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-channel --update
```

Further reading: [NixOS discourse](https://discourse.nixos.org/t/command-not-found-unable-to-open-database/3807).

