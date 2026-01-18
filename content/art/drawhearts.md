---
title: "Step to the 💗 beat"
date: 2026-01-18T08:06:06+05:30
image: "/hearts.avif"
layout: "artpiece"
draft: false
---

My first procedurally generated animation drawing concentric heart
growing from the center of the screen. The source code for the
program used to create this piece is [available on my GitHub](https://github.com/lavafroth/drawhearts).

I tinkered around for quite a while before discovering that I can intersect two $xy$ skewed ellipses
with the absolute value operator. Here's my custom equation for the heart shape.

$$ x^2 + y^2 - |x|y = r $$

have fun!
