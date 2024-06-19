---
title: "Modes, Unbinds and Other Ensembled Parser Patterns"
date: 2024-06-10T08:27:06+05:30
tags:
- EBNF
- Google Summer of Code
- Rust
- SWHKD
- Waycrate
- Wayland
draft: false
---

Hello and welcome to the sixth instalment in this series where we build a parser
for a domain specific language from scratch. I would highly recommend you to go
through the previous articles to make sense of what we'll talk about today.

So far, we have built ranges, shorthands and bindings, starting all the way down
from primitives such as keys and modifiers. Continuing with the theme, we will
ensemble these patterns together along with some newer syntax to build modes.

SWHKD allows us to define additional properties to one or more bindings
by wrapping them in mode blocks. These properties can describe whether
bindings are meant as _one-off_ bindings that immediately exit a mode
or that they must _swallow_ the keypresses and not emit any uinput events.

The syntax of a mode definition is akin to that of `if` statements in bash.
A mode block begins with the word `mode` and ends with the word `endmode`.
The keyword `mode` must be followed by a name for future reference
while debugging a config.

```
mode my_mode_name
  # ...
  # bindings go here
  # ...
endmode
```

The mode name can be followed by one or more mode properties: `oneoff` and
`swallow` as we discussed earlier. Non unqiue properties get automatically
removed. Inside the mode, we can add one or more bindings, comments and unbinds.
Thus, an example mode block could look like the following:

```
mode dir oneoff swallow
	{super, alt} + {ctrl, shift} + l
		{ls, exa} {\-a, \-A} -l

  ignore alt + l
endmode
```

Hold on, what is that `ignore` statement? Well, that is an unbind statement.
It is rather trivial to implement which is why it does not get its own section.
An unbind is a single statement that begins with ignore followed by the `trigger`
for a binding that we built in a previous article. It is modelled in the grammar
side simply as:

```python
unbind = { "ignore" ~ trigger }
```

Coming back to modes, we define the oneoff and swallow expressions like the following:

```python
oneoff  = { "oneoff" }
swallow = { "swallow" }
```

Due to the way EBNF greedily processes inputs, we need to make sure that the mode name
that comes before any of these properties do not accidentally also match them. To do this,
we have to explicitly negate the aforementioned expressions in the token (character) set for mode
names.

```python
modename_characters = _{ !NEWLINE ~ !(oneoff | swallow) ~ ANY }
```

We can now have one or more of these mode name characters build an entire mode name.

```python
modename = { modename_characters+ }
```

For the contents inside a mode, we will create a union representation of comments, bindings
and unbinds as `primitives`. This facilitates easier reuse in future expressions.

```python
primitives = _{ comment | unbind | binding }
```

Since this is a expression catered towards convenience and we don't need it on
the code side, we have silenced it with a leading underscore. For the home stretch now,
let's put all of these smaller expressions together to build the mode expression itself.

```python
mode = {
	"mode" ~ modename ~ oneoff? ~ swallow? ~ comment?
	~ NEWLINE ~ WHITESPACE*
	~ (primitives ~ NEWLINE)+
	~ "endmode"
}
```

We started with the keyword `mode`, followed by a mode name, one or more properties and an optional comment.
Then we move onto the next line where there might be some whitespaces for visual structure and finally one or
more primitives (bindings, comments and unbinds) separated by newlines. Lastly, we end with the `endmode`
statement.

Note that we did not need to care about indentation when talking about modes since they have explicit markers
around their start and end.

Okay, that's about it for now, I'll see you in the next article.
