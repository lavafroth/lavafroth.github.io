---
title: "Wrapping up GSoC 2024"
date: Sat, 24 Aug 2024 10:28:50 +0530
tags:
- EBNF
- Google Summer of Code
- Rust
- SWHKD
- Waycrate
- Wayland
draft: false
---

# Overview

Hello and welcome to the final GSoC post for 2024! My task was to formalize the SWHKD parser using context-free EBNF notation. This post is to serve as a birdseye view of what
I have developed over the past few months.

# Report

## Implementing the EBNF parser in Pest

I started out with the scaffolding of the parser in an extended Backus-Naur form garmmar template
in a separate repository called [SWEET](https://github.com/lavafroth/sweet) using a Rust framework
called [pest.rs](https://pest.rs). Quite a lot of time was
spent in modelling the architecture of the syntax tree for our domain specific language.

Here's a simplified syntax tree of the grammar parser.

![A flowchart showing the working of the abstract syntax tree](/sweet-architecture.svg)

One of the most helpful design choices was to have an acyclic dependency graph which enabled composing
expressions into larger blocks.

## Isolating shorthands into separate expressions

Shorthands expressions inside curly braces which were previously parsed dynamically have now been moved
to work statically from the grammar side itself. This has two advantages:

- The matching of both comma separated _"slice"_ blocks and dash separated _"range"_ blocks can be proven from the grammar template itself.
- Extracting the components inside these blocks are performed in a single pass.

The latter is a theme that will continue throughout the rest of this report.

## Moving towards static checks

Many of the checks that were hand rolled previously have now been moved to the grammar side.
This again means that the checks are now performed statically. Here, we are borrowing from the
ideas of the Rust programming language itself which promotes making invalid states unrepresentable.

One such example is validating characters inside ranges. The specification requires these characters
to be within the ASCII range. We define this constraint inside the grammar template itself.

This way, if some invalid input is supplied, it never hits the business logic and errors out early.

## Separating channels of commands and mode instructions

SWHKD supports entering or escaping a mode by placing special instructions after the double ampersands between two commands.
Previously,
these instructions were extracted from the commands dynamically right before they were being run,
**line by line**. This may lead to edge cases where the command being run is not what the user
intended.

To sanitize this, we perform static extraction of these modes in the context of an entire block of
commands. We create a separate structure linked to a command structure that can hold arbitrarily many of these mode instructions
and the instructions are run only after all the command chunks have been executed.

## Eliminating ambiguity in shorthands

This is one of the breaking changes introduced in the new parser. Previously, when modifiers were
used inside shorthands, one could place the concatenator (plus sign) either outside or inside the
braces. This allowed somewhat off looking combinations like these:

```
{super, control + } + a
  notify-send {'hello', 'goodbye'}
```

This was allowed because the older parser simply ignored the concatenator since the closing curly
brace acts as a confirmation that the shortand is ending anyways.

The new parser disallows this behavior. When using multiple modifiers, one must simply place an concatenator after the shorthand ends.
The above example then turns into the following:

```
{super, control} + a
  notify-send {'hello', 'goodbye'}
```

The exception to this rule is when using omissions. To omit a modifier, we must replace it with an
underscore and move the concatenator inside the braces and add them to each modifier inside the shorthand.
For example, if we wanted to omit the "control" modifier, we would write the following:

```
{super + , _} a
  notify-send {'hello', 'goodbye'}
```

This is the _only_ way to represent modifier shorthands since a key or a key shorthand must finish
a binding's trigger. A good comparison would be bash or Rust macro expansions. Here's an animation as to how we perform
a "compilation".

![](/swhkd-macro-compilation.gif)

The new parser simply keeps track of shorthand values including ranges and slices as long as it is
ingesting newer content. These shorthands are lazily evaluated in the end when all files, including
imports have been ingested.

## More human friendly errors

One of the most difficult ways to get a working config for a tool like SWHKD is the lack of helpful
errors. The new parser addresses most of these issues. With the pest crate, we have been able to
provide rich contextual errors. Here's an example:

```
Error: unable to parse grammar from invalid contents

Caused by:
      --> hotkeys.swhkd:20:11
       |
    20 | super + k + control
       |           ^---
       |
       = expected command
```

Instead of just printing what the error was, we try to help the user by letting them know about what
the parser expected, where in the source file does the error exists and any suggestion available to
fix the error.

This not only applies to the grammar errors but to all of the errors in the business logic. Here's an
example of when the number of shorthand variants in the trigger don't match the number of command variants.

```
Error: unable to parse grammar from invalid contents

Caused by:
      --> 35:1
       |
    35 | super + {alt + , _, shift + } a
    36 |  notify-send 'hello'␊
       | ^------------------^
       |
       = the number of possible binding variants 3 does not equal the number of possible command variants 1.
```

Our custom error
structures wrap around pest's error types to provide such additional context as and when needed.

# Conclusion

Debugging a context free grammar syntax like EBNF was certainly challenging although this issue was solved
relatively easily thanks to the excellent editor provided at the [pest.rs](https://pest.rs) website. The parser
has reached complete feature parity, being slightly stricter in some cases as I
had planned with my mentor, Aakash Sen Sharma. Huge thanks to him for the helping me out with getting familiar
with the codebase quickly. The rest of the waycrate community has also been incredibly warm and welcoming.

I plan to add a heuristics model to SWHKD for detecting input devices better and more generally
to continue improving SWHKD. Feel free to check out the other posts on [my blog](https://lavafroth.is-a.dev/tags/google-summer-of-code) which go deeper into the process
of building this parser. This has been my GSoC 2024, thank you so much for reading this!
