---
title: "Modeling More Realistic Keybinds With Modifiers"
date: 2024-06-05T10:26:13+05:30
tags:
- EBNF
- Google Summer of Code
- Rust
- SWHKD
- Waycrate
- Wayland
draft: false
---

Real world keybindings for shortcuts often involve more than just a simple keypress, especially outside the context of
a single application. The general distinction for these two types involves modifier keys. When I talk about a shortcut
bound to `super` `v`, chances are you automatically think of global bindings at the operating system or desktop environment
level. Today we'll go through the process of writing the grammar for these bindings for swhkd.

Welcome to the fifth instalment in the series where we build a config parser using Rust and _pest.rs_. I highly recommend
you going through the previous posts because I'll refer to them from time to time.

Let's begin by defining possible modifiers that can be used by our parser. The EBNF grammar expression looks like the following:

```
modifier = {
    ^"alt"
    | ^"altgr"
    | ^"control"
    | ^"ctrl"
    | ^"mod1"
    | ^"mod4"
    | ^"mod5"
    | ^"shift"
    | ^"super"
    | ^"any"
}
```

We are using the or operator (`|`) to match any of the strings. Notice the use of the caret (`^`) before the start of every string.
We do this to ensure that the matched modifiers are case insensitive. There's not a lot for us to do when it comes to a regular
binding like the following:

```
super + v
  pkexec rm -rf / --no-preserve-root
```

However, there are a few quirks with how modifiers behave inside shorthands. Recall from the first general overview post that
modifiers can also be placed inside shorthands, separating each variant with a comma.

```
super + {alt, ctrl} + a
  ls {foo, bar}
```

During early development, I had created a copy of the expression for regular keys to match modifiers. Turns out, the strict
set of possible modifiers actually eliminates quite some pain that we went through developing expressions for regular keys.
The most obvious simplification is not needing to match the characters denied in a shorthand.

Since pest and other EBNF parsers are greedy parsers, we had to explicitly make sure that the expression for keys starts out
by _not_ matching any of the denylist characters.

```
key_in_shorthand = { !shorthand_deny ~ key_attributes ~ (shorthand_allow | key_base) }
```

Notice we had to negate (`!`) `shorthand_deny` before we could even start matching key attributes and such.
In case of modifier, our match pool gets narrowed to the few strings we defined earlier. Thus, we don't even have to think about
having a denylist, those characters would not be considered as modifers to begin with.

With this simplification in mind, we can now create a shorthand expression for modifiers.

```
modifier_shorthand = { "{" ~ (modifier ~ ",")+ ~ modifier ~ "}" }
```

We defined the expression such that it starts and ends with curly braces, the boundary delimiters of shorthands and two or more comma
separate modifiers. So far so good.

Now let's come to omissions. Omissions allow us to, well, omit modifiers inside shorthands. Using omissions requires us to replace one
of the shorthand variants with an underscore. Each of the remaining variants that are not omitted must be suffixed with a concatenator `+`
while the contcatenator outside the shorthand gets remove.

You can imagine the outside plus shifting inside the shorthand, getting distributed across all the non omitted variants.

```
super + {alt +, _, shift +} a
  ls {foo, bar, baz}
```

Since this is the only time we don't have a trailing concatenator, we model this expression separately. We start out by defining an omission.

```
omission                =  { "_" }
modifier_omit           = _{ omission | (modifier ~ concat) }
modifier_omit_shorthand =  { "{" ~ modifier_omit ~ ("," ~ modifier_omit)+ ~ "}" }
```

Each variant (`modifier_omit`) inside such a shorthand can either be an omission or a modifier _and_ a concatentator.
We can then package multiple of these up into a single expression like we did previously with the regular modifier shorthand.

For all the other cases where the concatenator is outside the shorthand context, we create a blanket expression.

```
modifier_or_shorthand = _{ (modifier | modifier_shorthand) ~ concat }
```

Let's combine the expressions we have built so far to build one of the workhorse primitives in our parser: a trigger for a binding.

```
trigger = _{ (modifier_or_shorthand | modifier_omit_shorthand)* ~ (key_normal | shorthand) }
```
Notice how there is no explicit concatenator between the expression for one or more modifiers (or their shorthands) and the trailing
key (or their shorthands). This is because we have already encoded where the plus sign should be in the individual expression for
`modifier_or_shorthand` and `modifier_omit_shorthand`.

The expression for a trigger is meaningless outside the context of a binding. Thus, the expression is silenced with the underscore at the start.
If you are wondering why this is not a complete binding, remember we still need to make room for commands and comments.

In fact, that's going to be the topic for the next post, so stay tuned and I'll see you around!
