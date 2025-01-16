---
title: "A Tale of a Frugal Home Server"
date: 2025-01-04T10:04:37+05:30
draft: true
tags:
- NixOS
- Home Server
- Automation
- Jellyfin
- Photoprism
---

Having run an on-premise server for the past two years, I think my setup has finally
matured enough to be worth talking about.

At any point, you can check out the source code for the server's infrastructure [here](https://github.com/lavafroth/dotfiles/tree/main/hosts/rahu) for a concrete example.
For each service I talk about, I will also link the respective definitions in my config.

My minimalist mindset has unsurprisingly aided the architecture of my server.
Throughout the rest of the post, you will come across the following broad strokes:

- Easy is not always simple
- Simple is better than easy
- There must be one (and exactly one) way of doing something

## Hardware

The server is an old laptop which was on the verge becoming e-waste. Despite having a touchscreen
display, the LCD had been battered into shards, making it no better than a shiny paperweight.

Although one could have kept the display, I carefully disassembled the machine to disconnect the corresponding
ribbon cable because we are aiming for a headless setup.

Removing the display reduced the power draw to 4 watts at idle. Thus, I would highly recommend it.

![A picture of the home server sans the display](/home-server/server.png)

## Software

I have seen a lot of people grow monstrous fleets of docker containers in the name of "simplicity" and ease of use.
Yet others take this further with dedicated operating systems like CasaOS to install containerized services in a single click.

Sure, these solutions might be easy but they are certainly not simple.
Containers introduce the overhead of Linux kernel namespaces. This means
accessing files on the host additionally requires creating a mount namespace.

To avoid all of that overhead, I opted for NixOS.

With NixOS, I can define the state of my system in a single configuration file, ensuring that the services
are running close to bare metal without any abstractions. Most of the services require adding something along the lines of

```nix
services.myservicename.enable = true;
```

to the configuration file and issuing a system rebuild with the `nixos-rebuild` command.

### Storage Management

Initially, I had configured three different routes to transfer files to the server.
Of these, only one service is in use today.

#### Syncthing
I had enabled Syncthing to automatically synchronize media from my phone. While it is a decent solution for a lot
of use cases, _it does not support partially sharing the contents of a directory_. This annoying 'all or nothing' nature
of Syncthing's file sharing is what drove me away from it.

#### Samba
A lot of people recommended samba because of its support on almost all platforms. However, it turned out to be extremely
slow. Yes, it boasts fancy video streaming capabilities but there are better solutions to building a media library than
manually searching for a file like a caveman.

#### SSHFS ([source](https://github.com/lavafroth/dotfiles/blob/c17a6053211145b08815cfaa0fe645c449e55ebd/hosts/rahu/configuration.nix#L154))

SSHFS is the sneaky third option that made the win! It is often referred to as SFTP (Secure File Transfer Protocol)
but the filesystem is usually FUSE mounted as `sshfs`.

The added advantage is that the connections go over SSH and uses the same credentials we would use to log into the server
as our user.

SFTP is fast and available on almost all platforms:
- Linux: Native support
- Android: Native support on some devices. Alternatively, use [Material Files](https://play.google.com/store/apps/details?id=me.zhanghai.android.files&hl=en-US)
- Windows: Supported through [WinSCP](https://winscp.net/eng/index.php)
- iOS: Suppported through [Pisth](https://pisth.github.io/ios/)

### Freedom from the Botnet

Finally, we can talk about weeding out the proprietary services that are holding us back
and replacing them with more privacy respecting alternatives.

#### Google Photos → Photoprism ([source](https://github.com/lavafroth/dotfiles/blob/c17a6053211145b08815cfaa0fe645c449e55ebd/hosts/rahu/configuration.nix#L19C1-L27C5))

Since I backup my phone's camera roll to the server, it's often nice to have these photos and videos
tagged and organized. Photoprism packs all the functionality of Google Photos including tagging people,
pets and places in photos, as well as searching through them along the timeline.

![](/home-server/photoprism.png)

#### Netflix / Spotify → Jellyfin

Instead of overpriced and restrictive services like Netflix or Spotify that shove ads in your face
even if you have paid for them, I have migrated to buying pieces of media including movies
and music, ripping them off the discs and saving them on the server. This way we don't have to sit
through piles of DVDs to find out a movie to rewatch.

Albeit there's a caveat to this, media that is not sold in physical copies.

I have set Jellyfin to monitor a directory where I store the ripped media from the CDs or DVDs.
Jellyfin then automatically updates its catalogue (index) when something new is added.

For music, Jellyfin also supports adding lyrics through `.lrc` files. A feature that is paywalled
on services like Spotify.

Here's a screenshot of the one album I have so far.

![](/home-server/jellyfin.png)

## Finishing thoughts

Using Nix for infrastructure has been a great success in my books. One of the greatest appeals is that
there's little to no setup involved for most of the services, because someone else has already figured
that out for you!

I have also enabled automatic updates which are scheduled every week. This works while leaving a backup of
the last known working state (generation), so even if the update fails, the server *must* keep working.
There's simply no way for the software side of the server to break.

What does that mean to an outsider? Less tech savvy people in my family just need to power the machine on
if it isn't already. That's it!

Sysadmins need not apply.
