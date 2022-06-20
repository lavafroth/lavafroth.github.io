---
title: "How I Use SWHKD in My Workflow"
date: 2024-08-01T17:17:31+05:30
tags:
- SWHKD
- Waycrate
- Wayland
- Google Summer of Code
- Workflow
- Video Editing
draft: false
---

SWHKD is the project that I have been working on for the past few months as a part of Google Summer of Code for this year.
Now that we are done with the development process, I want to talk about why I wanted to improve the project. Although
the easy answer is to get paid or to get a more production facing OSS development experience,
for me, the most important driving force is using it in my own workflow.

In hindsight, I should have talked about this earlier. You
see, I have been editing videos for my YouTube channel since March of this year. Granted, I take quite some time to churn out an entire video since
I am the only person in my _"team"_. Meaning, I have to perform all of the steps in the pipeline: the research, script, animations,
voiceover and video editing.

At some point, the frustration kicked in when I found myself doing the smallest of actions in my editor using
the cursor. While the cursor can be a nice tool in many cases, some actions like removing the space between two clips are better
suited for keyboard shortcuts. So that week, I learned the keybindings of my video editor, Kdenlive.

I also changed the keybindings for a lot of actions like snapping the playhead to the start or end of a clip as `a` and `d` respectively.
I borrowed quite a bit of the movement keybinds from gaming since, just like gaming, my left hand is on the left half of the keyboard
but the right hand is controlling the mouse pointer.

> Tip: Avoid shortcuts that require you to raise your hand. Raising your hands adds friction in the way of video editing.

My biggest gripe is that till date, there is no way to record multiple operations and bind then to a keyboard shortcut.

## Enter SWHKD

To make my workflow as fast as possible, I have an entire config to perform these recorded _"macros"_ with at shortcuts involving at most two keys.

Take the example of a ripple cut which involves removing the part of the clip before the playhead ...

![](/video-editing-workflow-0.avif)

... and shift the rest of the clips back to where the original one started.

![](/video-editing-workflow-1.avif)

With my current setup of Kdenlive, I have to perform 3 keypresses back to back to do this:
- `r` to use the ripple tool
- `q` to make the cut and perform the shift
- `s` to go back to using the selection tool

However, SWHKD combined with `ydotool` allows me to do this in a single (or two depending upon how you seen it) keypress of `Shift` `Q`.

Whenever I'm editing a video, I'll launch a script that start `swhkd` with my Kdenlive config.

```bash
swhks &
sudo sh -c "(ydotoold -P 0622 &);"
pkexec swhkd --config $PWD/kdenlive.swhkd
```

The Kdenlive config defines a mode which I have to explicitly enter using `Super` `k` at the start of video editing so that at some point
of time, if I get derailed into research, I can exit the mode with the same keypress.

```
mode kdenlive
    shift + q
        # 19, 16, 31 = r, q, s
        sleep 1 && \
        YDOTOOL_SOCKET=/tmp/.ydotool_socket ydotool key 19:1 19:0 && \ 
        YDOTOOL_SOCKET=/tmp/.ydotool_socket ydotool key 16:1 16:0 && \
        YDOTOOL_SOCKET=/tmp/.ydotool_socket ydotool key 31:1 31:0
super + k
    notify-send "exiting kdenlive mode" && @escape
endmode
```

Inside the mode, when I press `Shift` `Q`, the input event codes for the
respective keys are sent using `ydotool` and I get a pretty seamless experience.
Of course you can extend this to whatever actions you find yourself performing
most often while editing videos or any other task for that matter. To save you
the trouble of searching for the input codes like 19, 16 and 31 used here, check
out this [kernel source file](https://elixir.bootlin.com/zephyr/v3.7.0/source/include/zephyr/dt-bindings/input/input-event-codes.h) which defines the input
event codes for keys and mouse buttons. Also, yes there is a small delay you should
keep before sending other keys because I have often found my input overlap with the
scripted keypresses.

Okay that's about it for now, hope you enjoyed this little sneak peek into how I'm making
my videos. Bye!
