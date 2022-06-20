---
title: "A SWEET Little Parser"
date: 2024-05-17T07:52:44+05:30
tags:
- Wayland
- Rust
- SWHKD
- EBNF
- Google Summer of Code
draft: false
---

A few days ago, I had announced my project for this year's Google Summer of Code. Today I'll
be explanding upon that. I believe that to construct a good grammar, I should be able to understand
and explain it well. So here goes.

## General Idea

SWHKD's grammar parser, although similar to tools before it like sxhkd, has a more coherent
syntax. For starters, every binding declaration is one or more accelerators followed by a composite key.

The line following the binding declaration must be a tab or space indented command to be run by the client.

Here's a simple example to send a notification to myself using `libnotify` when I press `Super` `a`.

```
super + a
  notify-send "bazinga!"
```

We can also issue multiline commands like we do in a normal shell by adding a bare backslash to the end
of each line. For example, the following binding checks if we have an Arduino connected and only then
sends a notification.

```
super + a
  ls /dev/ttyACM0 && \
  notify-send "bazinga arduino baby!"
```

This means we must ignore any trailing escaped line feeds and consider the two lines separated by them
as one.

Should be pretty simple right? Well, brace yourself for some added complexity: introducing shorthands!

## Shorthands

When it comes to bindings, a shorthand is two or more keys separated by commas inside curly braces.

```
super + {a, b}
```

Each variant of these shorthands must correspond to a variation in the command following the declaration.
This naturally brings us to shorthands in commands. These are much more relaxed, each variant can be a
chunk of a command instead of being restricted to a list of valid keys and modifiers.

If a declaration has shorthands in it, the command following it must also have shorthands.

```
super + {a, b}
  notify-send {"you pressed a", "you pressed b"}
```

Although there exists a bash syntax to do similar shorthands, I like to think of SWHKD shorthands akin
to macros in Rust. Each binding _"compiles"_ to the possible Cartesian products formed by multiplying
these variants.

To give you an example, a binding like this

```
super + {ctrl, alt} + {a, b}
  notify-send {"incoming", "outgoing"} {a, b}
```

would _"compile"_ to the following four bindings:

```
super + ctrl + a
  notify-send "incoming" a

super + ctrl + b
  notify-send "incoming" b

super + alt + a
  notify-send "outgoing" a

super + alt + b
  notify-send "outgoing" b
```

![An animation showing how the shorthands are compiled](/swhkd-macro-compilation.gif)

Obviously we need to make sure that the keys are properly escaped inside these shorthands. For example a comma,
inside a shorthand acts as a separator. To specify a literal comma key, we would need
to consider an escaped comma like `\,` inside a shorthand. The same applies to the curly braces themselves.

Shorthands also allow omitting variants when it comes to modifiers. In such cases, the omissions are represented
by underscores and the plus sign usually outside the shorthand follows every non-empty variant. Take the following
example:

```
super + {_, alt + } h
  {htop, btm}
```

This expands to the following bindings:

```
super + h
  htop

super + alt + h
  btm
```

Notice that there is no extra logic to parse the concatenator (`+`) like we would need to
if the concatenator was outside the brace, because simply expanding the
shorthand set yields the correct outputs.

To not break this exception, we will model shorthands with omissions separate from regular
shorthands.

Now, what if you wanted to be even more succinct and define a bunch of shortcuts over a range
of keys? That's where the next puzzle piece comes into play.

## Ranges

Ranges are technically a subset of shorthands, just as we have used commas so far to separate
each element of a shorthand, SWHKD allows the use of dashes to specify a range of keys.

For example, you can use ranges to switch to workspaces:

```
super + {1-6}
  cosmic-workspaces switch {1-6}
```

This maps the keys 1 through 6 to those in the command to switch to the corresponding workspace.
Ranges can also be used with bare elements separated by commas like the following example:

```
super + (a, 1-6)
  cosmic-workspaces switch {\-\-overview, 1-6}
```

Like the previous example, this one switches through workspaces 1 through 6 for the corresponding
keys. However, pressing `Super` `a` shows us an overview of all the workspaces.

Just like regular shorthands, we need to escape the dash used in the range. That's why, we're using the escaped
version of `--overview` flag.

The observations we have made so far will be used to build the grammar in the project.
The demo repo called [sweet](https://github.com/lavafroth/sweet) (simple wayland event encoding text) is available ~~to my mentors for now but it should be public soon~~ publicly now.
~~I need to double check and make sure my mentors are aware when I make it fully public.~~

In the next post I'll talk about defining the grammar for regular keys. See you then!
