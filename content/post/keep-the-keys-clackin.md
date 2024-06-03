---
title: "Keep the Keys Clackin'"
date: 2024-05-27T08:59:29+05:30
tags:
- EBNF
- Google Summer of Code
- Rust
- SWHKD
- Waycrate
- Wayland
draft: false
---

This is the second post in a series of posts I'm writing for Google Summer of Code.
Each post covers a separate topic.
While the previous posts might have given you an overview of ideas, this post will delve
into more technical details. I highly recommend reading the previous posts because I will
refer to them from time to time.

Let's begin with why we chose EBNF grammar in [pest.rs](https://pest.rs) instead of regular expressions.

# Why EBNF?

Let's say we have the following regular expression to match any line that starts with an _"a"_ and ends
with a _"e"_:

```regex
a.*e
```
The dot star matches any character any number of times.

Let's say we supply a word _"apple"_ for this regex to match.
Intuitively we can conclude that the regular expression will match but we often misunderstand how the matching
happens. The regex engine will simply match as much as it can, that is, the `.*` will match upto and
including the last _"e"_. Once it realizes that there are no characters left, it backtracks the `.*` to match slightly less
upto the _"l"_ so that it can match the _"e"_.

![](/swhkd-regex.gif)

This backtracking causes the algorithm to have an exponential time complexity. We want to build a fast parser, one that doesn't
hopefully get throttled by large files or multiple imports. The Extended Backus-Naur Form (EBNF) grammar in _pest.rs_ follows a simple
greedy matching strategy which gives it a rather fast linear time complexity at the cost of us having to be a little bit more careful
while defining our expressions.

# Keys

According to SWHKD's definition of bindings, a keybind declaration must at least be a regular key.
This means, there's technically nothing stopping you from having a binding to a keypress like `a` that runs a command
to annoy the user with notifications.

```
a
  notify-send 'LOL you pressed a!'
```

However, generally keys are used in conjunction with modifiers prefixed before them.

From our general intuition, we might be able to conclude that a regular key must contain the ASCII alphanumeric characters,
symbols and control characters like backspace, enter, etc.

Recall from the previous post that our grammar supports shorthands delimited by curly braces and commas.
We also noted that certain keys inside these shorthands must be different from their counterparts outside shorthands.

The most obvious example is specifying a literal curly brace. Inside a shorthand, we have to escape the keys
with a backslash. Thus, `{` has to be written as `\{` inside shorthands.

To respect the difference between these two contexts, keys inside shorthands are modeled differently from those outside.

We start by defining what gets denied or allowed in shorthands.

```
shorthand_bounds =  { "{" | "}" }
shorthand_deny  = { NEWLINE | shorthand_bounds | "," | "-" }
shorthand_allow = { "\\," | "\\\\" | "\\{" | "\\}" | "\\-" }
```

Now we will define a key to be used in a regular context.

```
key = { ^"enter" | ^"return" | ASCII_ALPHANUMERIC }
key_normal =  { send? ~ on_release? ~ (key | "," | "-") }
```

You may ignore the `send` and `on_release` attributes for now but that is the
general definition of keys in the grammar.

```
key_in_shorthand = {
 !shorthand_deny ~ send? ~ on_release? ~ (shorthand_allow | key)
}
```

In case of keys in a shorthand, we first make sure that it does not match keys denied in the context of
a shorthand (`!shorthand_deny`). Ignoring the attributes again, we match the allowed escaped versions of
the keys denied earlier (`shorthand_allow`) or any other regular key that does not need escaping.

We had also talked about a convenience features that allowed us to specify a range using dashes.
Since they are meant to be used inside shorthands, we reuse the `key_in_shorthand` expression to define
a key range like so:

```
key_range = { key_in_shorthand ~ "-" ~ key_in_shorthand }
```

We use a blanket expression for building the overall shorthand expression called `key_or_range`. It does
exactly what it says, it is either a bare key or a dashed range in a shorthand context.

```
key_or_range = _{ key_range | key_in_shorthand }
```

Note the use of the underscore while defining the grammar. This allows us to reference the expression without
needlessly exposing it to the code side.

We will now slowly build a shorthand from the expressions defined so far.
Let's think through what makes up a shorthand, starting from the outside.

A shorthand must begin and end in opening and closing curly braces respectively.

```
shorthand = {
    "{"
    ~ // ...
    ~ "}"
}
```

When does a shorthand make sense to use? Well, we generally use them to define two or more bindings succinctly.

Therefore, we can dedeuce the possible expressions that a shorthand may begin with.
These are as follows:

first | second | example
------|--------|---------
|key  | key    | `{a,b}`
|key  | range  | `{a,b-c}`
|     | range  | `{a-c}`

We can model these three cases in the grammar like so:

```
(key_in_shorthand ~ "," ~ key_in_shorthand)
| (key_in_shorthand ~ "," ~ key_range)
| key_range
```

These starting expressions can be followed by one or more keys or ranges. This is where the blanket expression `key_or_range` we defined
earlier make our lives easy. We can also make the above expression a little concise by abusing the blanket expression.

You see, for the first two possibilities, we are essentially saying that it needs to be a `key_in_shorthand`, a comma
and *either another key or a range*. So those two can boil down to use a `key_or_range` after the comma.

```
(key_in_shorthand ~ "," ~ key_or_range)
| key_range
```

Putting it all together, we get the following expression for a shorthand.

```
shorthand = {
    "{"
    ~ ((key_in_shorthand ~ "," ~ key_or_range) | key_range)
    ~ ("," ~ key_or_range)*
    ~ "}"
}
```

Here `("," ~ key_or_range)*` represents the zero or more keys or ranges that the user may supply after the starting sequence.

That's all for today, I hope my explanation was not too convoluted. In the next post, I will talk about the `send` and the `on_release`
attributes that describe the timing of a keypress and how we handle the grammar for them.

Talk to you then!
