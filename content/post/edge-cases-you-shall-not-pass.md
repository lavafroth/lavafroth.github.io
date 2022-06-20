---
title: "Edge cases? You Shall Not Pass!"
date: 2024-06-03T08:18:19+05:30
tags:
- EBNF
- Google Summer of Code
- Rust
- SWHKD
- Waycrate
- Wayland
draft: false
---

This post is a part of a series that explains the architecture of the config parser
I am building for swhkd as a part of Google Summer of Code. I highly recommend reading
through the previous posts as I'll be referring to them from time to time.

In the last post I talked about key attributes that can be used as prefix to denote
the timing of an event, on key press (`send` / `~`) or release (`on_release` / `@`). One nuanced
case we did not cover was the use of these attributes inside shorthands.

If a user is supplying a config file with a shorthand along with any of these attributes, should the
attribute remain outside the shorthand or be prefixed for each variant inside the shorthand? Consider
the following two cases: one where the attribute is outside the shorthand context

```
super + @{a, b, c-f}
  ...
```

and another with the attribute inside the shorthand context.

```
super + {@a, b, c-f}
  ...
```

We can notice that while the first case is easier to implement, the second case gives us more granularity where different keys can have different attributes.
However, this introduces another hidden complexity that we have to tackle, what if range bounds have different attributes? Take the following example:

```
super + {~a-@f}
  ...
```

What does it mean to have a range with the keypress send event for `a` to the keypress release event for `f`? Should the elided inbetweens have a `send` or an `on_release`
modifier? The original parser also conveniently sidesteps this entirely by not entertaining attributes in shorthands (bruh).
Since we can never be sure of what the user is trying to convey in such cases, our best attempt at handling this would be to simply throw an error to the user.

Thus, our new parser adds the ability to have attributes inside a shorthand as long as range bounds have the same attribute, all the while maintaining backward compatibility
with the older parser!

Now let's come to the second issue that I discovered during some manual testing this week. I supplied the following config to my parser

```
super + \+
   mpv ~/Music
```

and to my horror, the parser parsed the following:

```
Binding [Modifier("super"), Key { key: "", attribute: KeyAttribute(0x0) }] → mpv ~/Music
```

Did you catch it? Take a closer look at the key field in the definition, the escaped key is parsed as empty for some reason.
It turns out that the escaped keys that were part of the `shorthand_allow` expression were not consistently exposed as a rule
for the code side. Thus, I forgot to parse them back as keys.

To fix this, we restructure the expressions for keys in normal and shorthand contexts.

```python
keys_always_escaped = _{ "\\~" | "\\@" | "\\+" | "\\\\" }
key_base = { keys_always_escaped | ^"enter" | ^"return" | ASCII_ALPHANUMERIC }

key_attributes = _{ send? ~ on_release? }
key_normal =  { key_attributes ~ (key_base | "," | "-") }
key_in_shorthand = { !shorthand_deny ~ key_attributes ~ (shorthand_allow | key_base) }
```

This makes our life a tad bit easier because for every match of a `key_normal` or a `key_in_shorthand`,
we can easily extract the variants of `key_attributes` if any as well as the key itself from the `key_base` or `shorthand_allow`.

Finally, let get to unescaping the keys themselves. Initially, the idea was to use `unescape` function from the snailquote crate
since it allows unescaping any escaped sequence, be it ASCII or unicode. However, we quickly find that we also have to check
whether the keys we just unescaped are supposed to escaped in the first place.

It makes more sense here to write a small function ourselves to both check for values we know must be escaped as well as escaping
them.

```rust
fn unescape(s: &str) -> &str {
    let chars: Vec<_> = s.chars().collect();
    let ['\\', ch] = &chars[..] else {
        return s;
    };
    // Pest guarantees this for us. Still keeping a bit of sanity check.
    assert!(matches!(ch, '{' | '}' | ',' | '\\' | '-' | '+' | '~' | '@'));
    &s[1..]
}
```

With this new function, our parser correctly unescapes the keys like so:

```
Binding [Modifier("super"), Key { key: "+", attribute: KeyAttribute(0x0) }] → mpv ~/Music
```

Okay, that's all for now. I know I was supposed to talk about modifiers. I will do that in
the next post because fixing this bug and keeping logs of why I did it felt more important.

See you soon!
