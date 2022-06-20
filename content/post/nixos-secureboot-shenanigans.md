---
title: "NixOS Secureboot Shenanigans"
date: 2024-12-20T12:26:10+05:30
draft: false
tags:
- Nix
- NixOS
- Secureboot
- sbctl
- lanzaboote
- Debugging
---

# Key takeaways

- This issue only pertains to secureboot on NixOS using lanzaboote. Most Linux users have secureboot disabled. If you are paranoid like me and have enabled it, continue reading.
- Make sure to track the latest version of `lanzaboote`. ([example](https://github.com/lavafroth/dotfiles/commit/4d64808ffbc135b5bf5a61df17ef02d7da8452b7))
- Set the PKI bundle location to the newer `sbctl` default. ([example](https://github.com/lavafroth/dotfiles/commit/1fa71734bb3af83b8de9134e68f0153f49a18205))

# Deprecated `overrideScope'`

For the past few months, I started noticing this new warning when rebuilding my system with `nixos-rebuild`.

```
warning: `overrideScope'` will be deprecated soon
```

I thought nothing of it since NixOS sometimes has these small spans of time when things are being migrated.

A couple days ago, I bumped my flake with `nix flake update` and this somewhat longstanding warning turned into
and error.

```
error: attribute 'overrideScope'' missing
```

After a bit of digging around I discovered that the problem was caused due the out-of-date `crane` dependency
required for [`lanzaboote`](https://github.com/nix-community/lanzaboote/), the Rust utility for the secure boot shim[^1]. After looking through [this issue on github](https://github.com/nix-community/lanzaboote/issues/411)
as well as the lanzaboote repository, it dawned on me that I had been using a version of lanzaboote released even before July this year.

This meant I had to update the version in my `flake.nix` inputs like so

```diff
     lanzaboote = {
-      url = "github:nix-community/lanzaboote/v0.3.0";
+      url = "github:nix-community/lanzaboote/v0.4.1";
       inputs.nixpkgs.follows = "nixpkgs";
     };
```

With that, I ran another `nix flake update` and enqueued my system for a rebuild.
I deleted a few entries from `/boot/EFI/nixos` because the [new release](https://github.com/nix-community/lanzaboote/releases/tag/v0.4.1) uses double the scratch space as needed by the previous version. Also, I had around 16 older generations of my setup for the sake of posteriety.

# Where is the PKI Bundle?

The rebuild led to yet another error, this time concerning a nonexistent path.

```
Installing Lanzaboote to "/boot"...
Failed to install generation 303: Get stub name: No such file or directory (os error 2)
Failed to install bootloader
warning: error(s) occurred while switching to the new configuration
```

The hardest part of debugging this was to know what program was causing this issue and what path it was looking for.
Fortunately, we can use `strace` to see what system calls are being made by `nixos-rebuild`. We also add the `-f` flag to follow the system
calls of child processes.

```sh
sudo strace -f nixos-rebuild boot --flake /home/h/Public/dotfiles#cafe
```

From the obscenely long logs which I will spare you from reading, one could observe that the secureboot key management tool `sbctl`
looks for the path `/var/lib/sbctl`. This correlates with [this issue](https://github.com/nix-community/lanzaboote/issues/413) and [this commit](https://github.com/Foxboron/sbctl/blob/cd6dd1c6a02f5b4b3b93669e78671b656ddcfe67/config/config.go#L107C19-L107C34) confirming that `sbctl` has switched the default
public key infrastructure bundle (`pkiBundle`) location to `/var/lib/sbctl`.

I finally solved the issue by setting the respective parameter in my config.

```nix
boot.lanzaboote = {
  enable = true;
  pkiBundle = "/var/lib/sbctl";
};
```

I recommend performing garbage collection on your system before queueing another rebuild because the last error
causes you to land in a generation that is unavailable in the systemd-boot menu.

Honestly, I think this whole issue would have been much easier to resolve if `sbctl` spelled out the path it was looking for in the error message.

Anyways, that's all for today, hope this helps! 

[^1]: I have two NixOS outputs defined for my work setup, one with secureboot and another without. See my system config [here](https://github.com/lavafroth/dotfiles).
