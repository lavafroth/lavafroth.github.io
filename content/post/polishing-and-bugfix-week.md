---
title: "Polishing and Bugfix Week"
date: 2024-07-29T13:46:41+05:30
tags:
- EBNF
- Google Summer of Code
- Rust
- SWHKD
- Waycrate
- Wayland
draft: false
---

Hello and welcome to the last instalment in the series where we build a parser
for a domain specific langauge in Rust. Please go through the previous articles
since this article assumes you are aware of such contextual details.

Let's start with the bugfixes.

# Eagerly removing unbinds

While going through the tests, I figured that
the prior parser eagerly parses unbinds and removes said keystroke combinations
from our binding set. Unlike the previous iteration, our iteration had unbinds
as a separate set which deferred the task of the removing the set intersection
to the upstream crate instead.

To fix this, we follow the good old adage, _"fix it in post"_. With the import
functionality taking care of duplicate imports, all imports are parsed using
the private `SwhkdParser::as_import` function, passing in the respective inputs as
well as a state struct to keep track of imports we've already seen. The only
exception to this rule is for the root of all the imports. For the root config,
we have a `from` function that accepts a single input (raw text or path) and repeatedly
uses the `as_import` function on all subsequent inputs.

Since we know that the upstream crate will only be able to use the public `from` function,
we can add the fix right after every import has been parsed. We add the following
loop to remove any binding in our binding list as long as it also exists in the
unbinds list.

```rust
for def in root.unbinds.iter() {
    if let Some(i) = root.bindings.iter().position(|b| b.definition.eq(def)) {
        root.bindings.remove(i);
    }
}
```

# Overwriting bindings that are redefined

I had a talk with my GSoC mentor last week where we discussed whether bindings
from imports that get redefined in the root config should be overwritten. After
some back and forth, we decided to stick with the older behavior of overwriting.

To implement this, instead of blindly extending the list of bindings with what
has been parsed, we check if a binding with the same definition exists. If so,
we replace the binding's command with the new command.

```rust
for binding in binding_parser(decl)? {
    if let Some(b) = bindings
        .iter_mut()
        .find(|b| b.definition == binding.definition)
    {
        b.command = binding.command;
        b.mode_instructions = binding.mode_instructions;
    } else {
        bindings.push(binding);
    }
}
```

# Unescaping commands in shorthands

This one's a fairly straightforward one but I probably would have missed it if it
were not for the tests. The commands, just like keys, must be unescaped when present
in shorthands. This is so that we can distinguish a comma separating two
shorthand elements or a dash representing a range from a literal comma or a dash.

Solution? Simply reuse the unescape function we used in for the keys.

```rust
// ...
Rule::command_component => {
    command_variants.push(unescape(component.as_str()).to_string())
}
// ...
```

# Removing trailing double ampersands from commands

When defining commands for bindings, swhkd allows us to chain commands with
double ampersands (`&&`). Not only that, we can also invoke modes with special
syntax. If the `&&` is followed by a `@enter` and a modename, we enter a mode
whereas a `@escape` allows us to exit a mode.

In a previous article where we built a way to extract these modes during a single
pass iteration, we extract the mode instruction to our list of mode instructions
and if the last component was not a `&&`, we keep the `&&`.

This idea was somewhat flawed since and expression like the following keeps an
extra trailing `&&`.

```
echo hi && ls && @enter mymode
```

Clearly, the last `&&` has no problem staying beside the `ls` while the `@enter`
mode instruction was happily extracted away. The result `echo hi && ls &&` isn't
a valid command though.

To fix this, we add a small snippet of code to pop off the last element if it happens
to be just one `&&`.

```rust
if comm
    .last()
    .is_some_and(|last| last.len() == 1 && last[0] == "&&")
{
    comm.pop();
}
```

# Wrapping up

So yeah, those were the small bugs that needed to be squashed and with that all
the previous tests as well as new tests are passing. This also marks the end of
the development phase on my end. Perhaps in a next post, I'll talk about how I
actually use SWHKD in my daily workflows. Stay tuned!
