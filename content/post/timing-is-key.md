---
title: "Timing is Key: A Tale of Keystrokes and Timings"
date: 2024-05-29T21:18:22+05:30
draft: true
---

### Status: Draft

Whether you're playing a video game or competing in a constrained attack-defense CTF, your keystroke timings matter.
We at waycrate value your precision, to the extent that you can configure your keybindings to perform actions either
on a key's press or a release.

Hi, my name's Himadri and this post is a part of a series explaining how we (basically just me) are rewriting the
config parser for swhkd using EBNF grammar. In the last post, we talked about regular keys that form the foundation
of bindings. However, we glossed over the `send` and `on_release` expressions in the code.

The `send` and `on_release` attributes are extensions that could be added to regular keys to be more specific about
the timing of an event.

