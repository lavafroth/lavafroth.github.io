---
title: "Wayland Tools Rock!"
date: 2024-05-17T07:52:44+05:30
tags:
- Wayland
- Rust
- SWHKD
- EBNF
- Google Summer of Code
draft: false
---

Hey folks. Quite a few months have passed since I last posted here.
As you might have known from my earlier posts, I've been daily driving
Wayland instead of Xorg on my NixOS setup for quite some time now.

One of the tools I stumbled upon while writing my voice automation abomination
was SWHKD (Simple Wayland HotKey Daemon). It's a spiritual successor to sxhkd from the Xorg world
and in a sense better than the former because it works not only in wayland sessions but also
under X and TTY sessions!

I had been using it to chain actions for my voice automation tool and was pleasantly surprised
by the fact that Waycrate (the organization behind SWHKD) had a whole bunch of ideas for this year's
Google Summer of Code.

One of these was to formalize the grammar for the config file so that the hand-rolled parser could
be replaced with a more robust and formally provable solution. I checked out the issue and one of
the organizers was talking about Extended Backus-Naur Form (EBNF) to implement the grammar.

Now, I had only worked with EBNF for small pet projects before, so this felt like the perfect opportunity
to test my skills in a production environment. I've slowly started working on an implementation using
[pest.rs](https://pest.rs) and I'll post more updates on my GSoC progress soon.

For those interested, keep an eye out for any of the [_Google Summer of Code_](/tags/google-summer-of-code) or [_SWHKD_](/tags/swhkd) tags in my blog.
See you soon!
