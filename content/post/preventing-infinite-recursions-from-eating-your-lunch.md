---
title: "Preventing Infinite Recursions From Eating Your Lunch"
date: 2024-07-04T09:57:01+05:30
tags:
- EBNF
- Google Summer of Code
- Rust
- SWHKD
- Waycrate
- Wayland
draft: false
---

Hello and welcome to the eighth instalment in the series where we build a
parser for a domain specific language in Rust. I'd highly recommend
going through the previous articles to make sense of what we’ll talk about today.

After a bit of back and forth with my mentor, we landed on moving the logic that imports
other config files into the parser crate itself. Config files can reference other modules
using import statements of the following form:

```
include some_other_module.swhkd
```

The grammar side is fairly simple to implement, we match the token "include" followed by
a path to some other file.

```
import_file = { (!NEWLINE ~ ANY)+ }
import      = { "include" ~ import_file }
```

We'll add this to the core set of variants so that we can actually match the expression.

```
content = _{ comment | mode | unbind | binding | import | NEWLINE }
```

Now we could very well blindly recurse through modules imported one after another but
that comes with the subtle pitfall of an infinite recursion. Allow me to elaborate:

Assume you have a module called `module_a` that is the top-level or the root config file.
Let's say it imports another module, `module_b`. If `module_b` now imports `module_a`,
our code enters an infinite recursion state, continuously evaluating these two modules forever.

Thus, the key takeaway is to implement book-keeping for the import paths so that they
form a directional acyclic graph. This requires us to write some additional code for
our parser.

First, let's create a field in our parser struct that stores tha names of all the imports it
has seen.

```rust
pub struct SwhkdParser {
    pub bindings: Vec<Binding>,
    pub unbinds: Vec<Definition>,
    pub imports: BTreeSet<String>,
    pub modes: Vec<Mode>,
}
```

Notice that the import field is a `BTreeSet` or a binary tree set. As you might know, adding
duplicate elements to a set discards them, keeping only the unique elements behind. Although we could have
used a `HashSet` here, a binary tree set is faster since it does not require a dedicated
hashing function. Considering that the average setup
would not wield even a thousand submodules, it's sufficient to store the imports in a set.

We'll create slightly separate implementations to differentiate between the root module
and any submodules it imports. For now, let's tackle the implementation for the submodules.

We create a method for the parser result called `as_import` for loading any of these aforementioned submodules.

```rust
fn as_import(input: ParserInput, seen: &mut BTreeSet<String>) -> Result<Self, ParseError> {
    // ...
}
```

The `seen` argument is how the caller tells the callee about what import paths it has already seen.

While processing import expressions, we keep adding the imports we have seen so far to a local `BTreeSet`.

```rust
let mut imports = BTreeSet::new();
for decl in contents.into_inner() {
    match decl.as_rule() {
        // other rules like bindings
        Rule::import => imports.extend(import_parser(decl)),
    }
}
```

Once all the tokens in the current config have been parsed, we can move on to adding the imports to
the set of `seen` imports.

```rust
while let Some(import) = imports.pop_first() {
    if !seen.insert(import.clone()) {
        continue;
    }
    let child = Self::as_import(ParserInput::Path(Path::new(&import)), seen)?;
    imports.extend(child.imports);
    bindings.extend(child.bindings);
    unbinds.extend(child.unbinds);
    modes.extend(child.modes);
}
```

Although we recurse here, the base case when the set of `seen` elements already contains an import
saves us from entering an infinite loop.

Once that's done, we can return the newly parsed result.

```rust
Ok(SwhkdParser {
    bindings,
    unbinds,
    imports,
    modes,
})
```

Coming back to the root config, this is where we create the topmost set of `seen` imports that can
be passed on to any `Self::as_import` calls.

```rust
pub fn from(input: ParserInput) -> Result<Self, ParseError> {
    let mut root_imports = BTreeSet::new();
    let mut root = Self::as_import(input, &mut root_imports)?;
    root.imports = root_imports;
    Ok(root)
}
```

We start off with an empty set and delegate the loading of the config to the `as_import` function,
sending it a mutable reference to this (kind of) global source of truth, at least throughout the
call stack of import related functions.

Lastly, for the sake of backwards compatibility, we assign the imports we have seen so far to the
root parser result. This was the behavior present in the original parser. Note that the import
fields in the submodules will all be empty since we popped them one by one in this loop:

```rust
while let Some(import) = imports.pop_first() {
    // ...
}
```

Okay, that's all for now. See you soon!
