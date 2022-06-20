---
title: "Test Driven Development - The Pinnacle of Engineering"
date: 2024-06-24T08:45:49+05:30
tags:
- EBNF
- Google Summer of Code
- Rust
- SWHKD
- Waycrate
- Wayland
draft: false
---

Hello and welcome to the seventh instalment in the series where we build a
parser for a domain specific language in Rust. I would highly recommend you to
go through the previous articles to make sense of what we’ll talk about today.

## Tying loose ends

Up until the last post, we had covered quite some ground, from building
elementary expressions to the penultimate levels of abstraction for macroscopic
expressions.

Let's begin today's conversation by finishing off where we left off. For us to
be able to parse an entire config file, we must have one main rule. We combine
all of the primitives that we have built so far: comments, modes, bindings,
unbinds and imports into a blanket content expression.

```ebnf
content = _{ comment | mode | unbind | binding | import | NEWLINE }
```

Obviously, a configuration file in the wild might very well have more than
one of the aforementioned primitives. Thus, to top it all off, we build a
final `main` expression that we subsequently use in the code side to match the
contents of a file.

```ebnf
main = {
    SOI ~ content* ~ EOI
} 
```

The expression starts with a `SOI` or a _start of identifier_ which is a fancy
way of saying start of a file in [pest](https://pest.rs). It may contain zero or
more of the blanket `content` expressions that we defined a while ago. Finally,
we have to mark it with an `EOI`, which stands for _end of identifier_.

## Writing tests

Writing tests for this parser proved to be a relatively straightforward task,
as many of them were already available from the previous version of the parser.
This allowed us to both port the basic tests as well as build upon existing test cases
that specifically targeted the changes made in this iteration.

The original crate made use of `std::io::Result` instead of defining its own error type
and while offloading the errors to an already available type might sound like less work,
it often meant that the grammar related errors had to be unwraps, panics, asserts or in
the worst case, just unrelated to `io::Result` itself.

Tell me, how does a missing identifier error make sense as an `io::Error`? It doesn't,
that's why we are using the standard `Result` type with the error generic type to be
our custom error type.

Thus, the tests we're writing have the general signature like so:

```rust
#[test]
fn test_multiple_keybinds() -> Result<(), ParseError> { /* ... */ }
```

A significant portion of these tests involved asserting that keybinds in the
config files matched their internal representations. We do this by defining
a known representation (starting off with a close enough guess) and asserting
whether it matches what has been parsed.

Consider the `test_command_with_many_spaces` test: we define the raw contents
and let the parser ingest it.

```rust
let contents = "
p
    xbacklight -inc 10 -fps 30 -time 200
        ";
let parsed = SwhkdParser::from(&contents)?;
```

Following this, we define what we know is going to be the internal representation.

```rust
let known = vec![Binding {
    definition: Definition {
        modifiers: vec![],
        key: Key::new("p", KeyAttribute::None),
    },
    command: String::from("xbacklight -inc 10 -fps 30 -time 200"),
}];
```

Finally, we assert whether these two bindings actually match.

```rust
assert_eq!(parsed.bindings, known);
```

Furthermore, some error tests became trivially easy thanks to the pest crate's
ability to generate meaningful errors. All we had to do was assert whether a
given result was an error or not, which  greatly simplified the testing process.

Consider the following test where we simply use the `is_err` method to check for errors.

```
#[test]
fn test_invalid_keybinding() {
    let contents = "
p
    xbacklight -inc 10 -fps 30 -time 200

pesto
    xterm
                    ";

    assert!(SwhkdParser::from(&contents).is_err());
}
```

In the future, we can take advantage of the extensibility and check for line and column
numbers to be extra precise.

While porting the tests, I also came across a bug where using a single letter for a binding
would be ignored. Turns out that a multi cartesian product of a vector of vectors
(all the modifier variant groups) works fine with a vector of keys except when all
modifier groups are empty. In such a case, the multi cartesian product has no output.

Mathematically, the cartesian product of {phi, phi, ..., phi} is phi but the cartesian product of
{} yields no value at all. Thus, we had to create a small check as a fix before blinding computing the cartesian products.

```rust
fn compile(self) -> Vec<Definition> {
    if self.modifiers.is_empty() {
        return self
            .keys
            .into_iter()
            .map(|key| Definition {
                modifiers: vec![],
                key,
            })
            .collect();
    }
    self.modifiers
        .into_iter()
        .multi_cartesian_product()
        .cartesian_product(self.keys)
        .map(|(modifiers, key)| Definition { modifiers, key })
        .collect()
}
```

Here, in the case where there are no modifiers variant groups, we instead anchor on the keys and
generate the definitions.

Okay. I know that was a long read. It took me quite some time to write this too but hopefully, you
can learn from my mistakes and embrace testing slightly ahead of time. See you soon.
