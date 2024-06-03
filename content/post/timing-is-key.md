---
title: "Timing is Key: A Tale of Keystrokes and Timings"
date: 2024-05-29T21:18:22+05:30
tags:
- EBNF
- Google Summer of Code
- Rust
- SWHKD
- Waycrate
- Wayland
draft: false
---

Whether you're playing a video game or competing in a constrained attack-defense CTF, your keystroke timings matter.
We at waycrate value your precision, to the extent that you can configure your keybindings to perform actions either
on a key's press or a release.

Hi, my name's Himadri and this post is a part of a series explaining how
we (basically just me) are rewriting the config parser for swhkd using EBNF
grammar. I highly recommend reading the previous posts because I'll be referring
to them from time to time. In the last post, we talked about regular keys
that form the foundation of bindings. However, we glossed over the `send` and
`on_release` expressions in the code.

The `send` and `on_release` attributes are extensions that could be added to regular keys to be more specific about
the timing of an event. To make a binding respond to either key presses or releases, they are prefixed with the `~`
or the `@` characters respectively.

![](/swhkd-send-release.gif)

For example, a bindings with that responds to `super` `a` can be made to respond specifically to the keypress instead
of the key release like the following:

```
super + ~a
  notify-send 'hello'
```

Now, to encode this as a formal grammar, we need to observe that these
attributes can be used both inside and outside shorthand contexts. This means,
the binding declarations `super + ~a` and `super + {@a, ~b}` are equally valid.

Intuitively, this begs the question of how keys like `~` or `@` could be specified literally.
The answer is similar to what we did for commas and dashes in shorthand contexts, we need
to escape the keys. The only difference this time is that the keys are escaped both inside
and outside shorthand contexts. In retrospective, the plus sign that has been serving as
the concatenator also needs to be escaped for literal representation.

To fix this, let's declare a convenience expression called `keys_always_escaped`.

```python
keys_always_escaped = _{ "\\~" | "\\@" | "\\+" }
```

This is how we will allow the user to literally mention a tilde or a plus.

Next, we modify the expression for a regular `key` to include these escaped literals besides the regular
ASCII alphanumeric characters.

We change the expression from

```python
key = { ^"enter" | ^"return" | ASCII_ALPHANUMERIC }
```

to the following:

```python
key = { keys_always_escaped | ^"enter" | ^"return" | ASCII_ALPHANUMERIC }
```

Don't worry, we will add other symbols like semicolons, parentheses and the like to this expression
but we are starting off being a bit restrictive so that we can catch errors early.

We have to compensate for this change for the code side as well. This is the first time you'll see
real code from the project besides the formal grammar.

```rust
#[derive(Debug, Clone)]
pub struct Key {
    pub key: String,
    pub attribute: KeyAttribute,
}
```

Notice how the `Key` variant has a field called `attribute` of type
`KeyAttribute`. This `KeyAttribute` is a bitflag represented by a
`u8` or a single byte. Why a single byte? Because it makes the underlying data
fairly inexpensive to copy. Although a boolean value should ideally be represented
by a single bit, most modern processor architectures use a single byte to represent them.
Bitflags can help us shave off the unused space.
We are using macros fromthe bitflag crate since Rust
does not natively have C-styled bitflags.

```rust
bitflags::bitflags! {
    #[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash)]
    pub struct KeyAttribute: u8 {
        const None = 0b00000000;
        const Send = 0b00000001;
        const OnRelease = 0b00000010;
        const Both = Self::Send.bits() | Self::OnRelease.bits();
    }
}
```

According to the bitflag, the variant `None` is internally represented by a `0`,
`Send` is represented as a `1`, `OnRelease` as `2`, etc. Since all we care about
is whether an attribute is there or not, we can use a single bit as a bin for
each attribute. Any time we see one of the variants, we bitwise or the current
attribute set to flip the respective bit on.

```rust
match inner.as_rule() {
    Rule::send => attribute |= KeyAttribute::Send,
    Rule::on_release => attribute |= KeyAttribute::OnRelease,
    Rule::key => key = pair_to_string(inner),
    _ => {}
}
```

This saves us from writing cumbersome if statements that would have made more
sense if counting the occurrences was involved.

That's all for today, I hope you were impressed by the bitwise trick. In the
next post, I will talk about how I'm implementing the grammar for modifier keys
and how they can be different from regular keys. See you soon!
