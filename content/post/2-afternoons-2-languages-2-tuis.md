---
title: "2 Afternoons, 2 Languages, 2 TUIs"
date: 2024-05-23T18:37:47+05:30
draft: true
---

Yesterday I created a tool in Golang to help me render my animations a little faster. Although the alterior reason was to check my Golang proficiency,
today I rewrote it in Rust and I was blown away by the differences in the final products.

When I'm rendering animations for a YouTube video, the general development iteration comprises me creating or modifying a file, switching to a different terminal
pane and manually issuing a `manim` command for the respective file to render and play the animation. My goal was to automate the last two processes, switching terminal panes and manually issuing a command. The idea behind it is that there would be a tool running
in the background that listens for filesystem events, like when a file gets created or modified, and if the file happens to contain an animation, renders it.
On linux systems, it's mostly a bunch of bindings to `inotify` but I have used platform agnostic libraries for both the languages.

There are also a few knobs that can be turned when it comes to rendering these animations. Arguably the most important one among them is the quality parameter.
A bulk of my development cycles are spent rendering the animations at a low quality and previewing them for feedback. However, once I'm satisfied with the animation,
I tend to create a high quality render for sanity checks as well as for placing them on the final project timeline.

Since I'm working solo for now without editors and peer animators, there's no race condition as to which animation gets rendered first it two files are modified
at the same time.

The Go version took me around 6 hours to finish. The Rust version fared at a maximum of 4 hours. It's incredibly fascinating how a change in the language made a perceptible
difference in the architecture of the final products. The Go tool should have taken less time compared to the Rust tool because I used the [CharmBracelet](https://charm.sh)
stack including [BubbleTea](https://github.com/charmbracelet/bubbletea), [Bubbles](https://github.com/charmbracelet/bubbles) and [LipGloss](https://github.com/charmbracelet/lipgloss).
For those who are unaware, BubbleTea uses the Elm architecture for rendering and I have already worked on a GUI project
that employs the Elm architecture.

For the Rust side, I went with [ratatui](https://github.com/ratatui-org/ratatui)
with a few libraries like `tui-term` and tui-explorer for scaffolding.
`tui-term` enabled me to easily spawn a pseudo terminal session in a pane
inside the current program and tui-explorer was useful for a quick and easy
file explorer.

The Go version had pretty things like modals and popups to the point that it was more akin to a GUI application. In some sense, it felt more beginner friendly.

I had this strikingly different mindset when I was developing the Rust version. Knowing that my hands are chained to the keyboard and that I don't need a mouse,
I designed the Rust version to be more keyboard centric. Using the `tab` or arrow keys to move around? No thank you, `hjkl` is fine by me. Focus on buttons and then
hit enter to perform actions? Nah, key chords are faster. For this version, I chose to go the minimalist route, taking subtle inspirations from helix.

Helix has a feature akin to the `whichkey` plugin for `neovim` where if you press a key like `g` and wait, it shows you what keys to press next for related actions.
For the `g` example, it would say that you can press `g` again to go to the file's start, `e` to go the file's end and so on.

The Rust tool has a single pane at the center which displays the output of `manim` commands that get executed. A to status line describes the current working directory and the current render quality.
Lastly, there's a bottom legend that tells you what key chord you can chain next for a particular action. For example, you start a key chord by pressing `space`,
then you can press `q` to enter the context of setting the render quality. Finally you can press keys like `l` for 480p, `m` for `720p`, `h` for 1080p and so on.

The last point that goes in favor of the second version's architecture is how the key chords solidify in my muscle memory and after just using it for a few minutes,
I'm already incredibly (blazingly) fast at it. Compare that to the intuitive design of the first architecture using `tab`s and arrow keys which always feels hit or miss.

However, I don't think this is necessarily a fault of BubbleTea or any of the other CharmBracelet products. Rather, it's a fault in my perception of the languages. I've
always thought of Go as a loosey-goosey language because it feels like Python with more sanity and less magic. When I'm building a Golang tool, it feels like I'm
making a paper plane whereas building a Rust application feels like using magnalum to build an actual airplane.

With that said, if you're a beginner and `Arc<RwLock<T>>` gave you a jumpscare, it might be worth sticking with Go and the CharmBracelet stack, it's simple and one
can go pretty far with it. If you're good with Rust, don't sleep on ratatui. It's way better than how I remember it from a couple years ago. If you're interested
in the code, check out the Go project [here](https://github.com/lavafroth/hackermanim-tui) and the Rust project [here](https://github.com/lavafroth/hm).

Until next time, remember, Rust is 2 fast 2 furious.
