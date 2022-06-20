---
title: "Humans Suck at Command Sanitization"
date: 2024-07-17T07:55:34+05:30
tags:
- EBNF
- Google Summer of Code
- Rust
- SWHKD
- Waycrate
- Wayland
draft: false
---

Hello and welcome to the eighth instalment in the series where we build a parser
for a domain specific language in Rust. I’d highly recommend going through the
previous articles to make sense of what we’ll talk about today.

Previously, we had built the scaffolding for modes to bind shortcuts to. Today,
we'll create the mechanism to invoke commands in the contexts of the modes that
can be built.

Now, SWHKD has a clever way to enter (and escape) mode contexts with inside commands
by chaining subcommands and mode instructions with double ampersands. Consider the following example:

```
super + a
  ls && @enter mysecretmode && cowsay 'hehe' && @escape
```

In the command for the above binding, we'll run the `ls` command followed by a double ampersand.
Anything following a double ampersand can either be a normal command or a mode instruction beginning
with an `@` sign. In our case, we have a mode instruction that asks the daemon to enter `mysecretmode`,
then we run the `cowsay` command and subsequently escape the mode using the `@escape` instruction.

Our goal for today is to modify the behavior of the command expression to account for this behavior.
Recall that we had already baked in the shorthand functionality into the command expression. Thus,
we need to be extra careful whem implementing this new behavior.

Since we'll need to negate the double ampersands because of the greedy algorithm used by pest, let's create
an expression for the double ampersands instead of having to use the literal string everywhere.

```
command_double_ampersand = { "&&" }
```

First, let's create a model for a standalone subcommand that is neither a shorthand nor a mode instruction.

```
command_standalone =  { (!shorthand_bounds ~ !command_double_ampersand ~ not_newline)+ }
```

Now any chunk that translates into a command after _"compilation"_ is placed under the wrapper expression of
a `command_chunk`.

```
command_chunk = _{ command_shorthand | command_standalone }
```

This includes the `command_standalone` expression since it compiles to itself without any
changes as well as the `command_shorthand` expression since it compiles into multiple variants of a subcommand.
Read the previous posts to see how those are implemented.

Now let's model the mode instructions. The `@enter` instruction requires a modename to actually enter. Thus, we'll
enforce that rule in the grammar as well.

```
enter_mode =  { "@enter" ~ WHITESPACE ~ modename }
```

The `@escape` instruction on the other hand requires no modename since it just escapes the current mode.

```
escape_mode =  { "@escape" }
```

Now to merge these two into a single expression, we'll make sure to trim off any excess whitespace between these
instructions and the double ampersands with a `WHITESPACE?` expression.

```
mode_instruction = _{ WHITESPACE? ~ (enter_mode | escape_mode) ~ WHITESPACE? }
```

Contrary to these instructions, a standalone command or command shorthand will not trim any spaces since we can't
make any assumptions over whether the spaces are actually significant to the execution of the command itself.

Now anything between the double ampersands can either be a mode instruction or one or more of these command chunks.

```
command_chunks_or_mode = _{ mode_instruction | (command_chunk*) }
```

The underscores before some of these expressions mean that they aren't public to the code side and are more of a
convenience for what we're about to build next. Finally, we can build an expression for a single line of command.

```
command_line = _{ command_chunks_or_mode ~ (command_double_ampersand ~ command_chunks_or_mode)* }
```

Since a binding definition will always have the command indented with spaces, most text editors as well as a general
sense would suggest that multiline commands must also have each of their lines indented. Consider the same example
as before except that each subcommand is put on a new line.

```
super + a
  ls \
  && @enter mysecretmode \
  && cowsay 'hehe' \
  && @escape
```

Notice the lines have equal indentation. For such multiline commands, we'll write a final expression to trim the
leading spaces for the commands to retain their semantics.

```
command = ${ NEWLINE ~ WHITESPACE+ ~ command_line ~ (escape_lf ~ WHITESPACE+ ~ command_line)* }
```

The newline and whitespace is what comes immediately after a binding declaration (here, `super + a`). This is followed by a
line of command that can be run. The `WHITESPACE+` between the escaped line feed (trailing slash and newline) and the next
line of command is what trims out the leading spaces.

Okay, that was all for now. In the next post, I'll elaborate on how to extract these mode instructions sprinkled throughout
commands in the code side of this endeavor. See you around.
