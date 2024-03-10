---
title: "I Switched to NixOS"
date: 2023-07-08T09:29:34+05:30
tags:
- Meta
- Workflow
- NixOS
draft: false
---

Hi. It's been quite a while since I had last posted. I had been spending my time on some programming projects that withheld me from even participating in CTFs.
Tired of this workflow that I somehow spiraled into, I'm now seeking to learn new things in an attempt to break out of this workflow.

# The End of an Overarching Journey

As any of my long time audience might be familiar with, I daily drove [Arch Linux](https://archlinux.org). A very flexible distribution, Arch allows beginners to get a good grasp of the
Linux way of doing things. It has an amazing package manager as well as [a user repository](https://aur.archlinux.org) for extra software unavailable in the official repositories. It's rather
easy to setup Arch for gaming, thanks to programs like [Lutris](https://lutris.net/) and [Bottles](https://usebottles.com/).

The terminal user interface [installer](https://github.com/archlinux/archinstall) shipped by default has come a long way since its inception and I'm certain that it has made Arch way more beginner friendly than how it was five years ago.
Albeit, this claim is slightly biased since I've been a contributor to the installer for some time now.

I felt that Arch was the endgame. Clearly, it had all the tooling I needed to have a streamlined workflow except for a few hiccups here and there.

That all changed now, I ditched Arch for NixOS.

# Justifications for switching to NixOS

Let's talk about the hiccups I faced when using Arch Linux.

## Atomic Updates

There were some instances following an update to my system where I'd encounter the strangest of problems that even Stack Overflow had no answers to.
I now had an answer, not to the problems individually but to what might have caused them. Unsuccessful updates. A plethora of circumstances including
power outages, batteries dying, unstable network connections and conversely corrupted package downloads would cause some packages to get overwritten
midway through the extraction process resulting in all the aforementioned problems.

In NixOS, all the packages of an update are extracted onto a separate layer from the current working system. The new layer is only available for use
when the entirety of the update has been transacted. This implies, any of the ill circumstances I talked about would completely cancel the transaction
and the new layer would be unavailable for use. This is what is referred to as atomic updates. The update either happens completely, or it does not
happen at all. There is no in-between.

## Generations

The atomicity does not stop at the updates. Whenever we install one or more packages in NixOS, those changes are built on a different layer. These
layers are termed generations. The idea is that if a package causes the system to break because of some software bug, the user can revert to an
older generation that functioned as inteneded. The entire operating system runs an immutable base so that the user cannot accidentally modify a
system binary and shoot themselves in the foot.

## `configuration.nix`

The final piece to the puzzle was reporducibility. Every time I reinstalled Arch due to one of the described problems, it would be extremely difficult
to recall all the extra tools I installed on the previous iterations. The results being a minimal install that amassed baggage every time I realized
in frustration that the tool I needed at the moment was not installed.

NixOS runs the Nix package manager. The entire system can be defined using a single file known as `configuration.nix`. This file is written in a declarative,
functional, lazily evaluated programming language aptly called `nix`. The options in the configuration file vary from bootloader options, networking and users
to edge case situations like installing Nvidia drivers or replacing `sudo` with `doas`. This config file can be separated into multiple files if deemed necessary.

Deploying these configuration on any computer that can run NixOS would result in the same build every time. No more frustration in recalling packages
I would need for my workflow, it's all defined centrally inside `configuration.nix`.

# Conclusion

It has been around a week since I started using NixOS. Although I am in no way an expert in the `nix` language, I find it very intuitive to work with.
The whole learning experience as well as daily driving NixOS has been very enjoyable. I still think Arch is a great disto for beginners to undestand Linux but NixOS felt like the next logical step moving from Arch Linux.

If you find yourself inspired after reading this article, check out this article called [NixOS for the impatient](https://borretti.me/article/nixos-for-the-impatient) as well the [official NixOS website](https://nixos.org/)
to get started. Once you have a rough idea, you could check out [my own NixOS configuration files](https://github.com/lavafroth/dotfiles). Maybe you can incorporate a part of the config you find interesting into your own.

Happy Nixing!
