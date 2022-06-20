---
title: "Abstracting Structured Patterns in Concurrent Programming"
date: 2023-12-06T10:58:10+05:30
tags:
- Meta
- Concurrency
- Rust
---

> I hope this article provides a solid blueprint for building a concurrency management API.
If you have questions or feel that I have missed something, feel free to talk about it in this repository's [issue tracker](https://github.com/lavafroth/lavafroth.github.io/issues) or the [discussion board](https://github.com/lavafroth/lavafroth.github.io/discussions).

In recent months, I have come across multiple articles talking about the need
of structured concurrency in modern programming languages as a built-in. Notably, in the article [Notes on structured concurrency, or: Go statement considered harmful](https://vorpus.org/blog/notes-on-structured-concurrency-or-go-statement-considered-harmful/),
the author compares the `go` statement used to spawn coroutines to `goto` statements used
for jumping to other parts of code in early languages like COBOL.

With time we are introduced to structured pardigms like `if-else`, `loop` and `match`
(your language might call it `switch`) blocks, abstracting over the basic idea of `goto`
to make it understandable and less dangerous to work with.

The article ends with the author introducing nurseries, a controlled API to spawn,
observe, await or cancel coroutines. My idea is to extend this further to generalize over
patterns observed in a large number of projects.

All of this begins with the simple concept of reusable components.

I will talk mostly about abstract concepts but at the end of each section, I will also try to provide concrete
analogies in terms of the Rust programming language. I choose Rust because it is memory safe with lesser footguns
and has tagged enums which we will utilize in a component. Implementing this should nevertheless remain straightforward
for other languages.

The accompanying diagrams will follow these notations:
- Coroutines are represented as nodes.
- The solid lines connecting nodes that don't have arrowheads (called *spawn lines*) represent a coroutine spawned from the parent.
- Coroutines will always be spawned from left to right.
- Spawn lines colored in green along with emerging nodes represent coroutines managed by the API.
- Solid lines with arrowheads represent some resource being sent from the tail end to the head end.

## Collector

The collector is arguably the simplest of the components. It consumes results
from the coroutines spawned by the user and relays them back into the main
routine. This component can be part of the main routine, such as in the case of
a loop receiving results from a channel. It may also be spawned as a separate
coroutine in case the main routine has other important computing to do and is
performing long polling with loops.

In case of long polling, the task of polling every user-spawned coroutine is deferred to the collector.

In the following diagram, the rectangle on the extreme right is the collector, spawned separately from the main function.

{{< math Collector.svg >}}

A program with structured concurrency will always end with a collector. Even if the user-spawned coroutines have no result to send back to `main`,
it should at the bare minimum indicate any errors or lack thereof with a unit type. This allows the main function to be fully aware of whether the
the spawned functions are driven to completion or not.

In a language like Rust, one can expect the bare minimum for a user-spawned coroutine's return type
to be `Result<()>`. More specifically, the return type of the `async` function would be `Future<Output = Result<()>>` that can be `await`ed.

## Functors

A functor pattern consists of a user-defined function spawned in a separate
coroutine. The API wrapper around the function takes input through a channel
and passes it through the function.

The following diagram depicts the functor pattern where a user defined function
_f_ is spawned within a coroutine controlled by the API. The results from the purely user spawned coroutines are processed as they arrive, which might be out of order depending on network or other I/O latency.

{{< math Functor.svg >}}

Notice how the user spawned coroutines can only interact with the functor
through the API abstraction wrapping around the function. This provides for a
consistent function definitions while accounting for error propagation.

## Tagged Functors

A tagged functor pattern, in essence, is a group of functions, each consuming a
different variant of the previous layer's result and producing different outputs
sharing a trait. The API wraps these functions with a multiplexer that reads
*tags* on the inputs and passes them to the appropriate function. This
gives branching concurrent code first-class citizenship.

{{< math TaggedFunctor.svg >}}
 
The tags mapping inputs to corresponding functions can be implemented in two
ways. The first way is available in pretty much all programming languages. The
input structure (or object) has an enum field, the variants of which allow the
multiplexer to pass them to the respective functions. However, this route is
less ergonomic since the programmer has to define a field in their class or
struct whose name is decided by the API.

The second route takes advantage of Rust's type system.
In Rust, enums can have different structures inside each variant. This allows
defining a macro that matches an enum variant to its respective function.

Here's how the use of the API might look like:

```rust
let m = multiplexer!(MyEnum {
    Left(StructA) => function_a,
    Right(StructB) => function_b,
});
```

The macro expands to generate a function that does the following:
- Wraps around the function in each arm so that they accept input through
a channel.
- Spawns these wrapped functions in their own coroutines, joining handles with
them.
- Optionally take a context as an input for cancellation of itself and
coroutines spawned by it.
- Uses a `match` block to dispatch the inner value of a struct to the respective
channel.

The macro would use the `quote!` macro to generate the match arm for each
variant like the following:

```rust
quote!(
    match #enum_ident {
        // loop over the arms in the macro call
        #variant(#inner) => #inner_chan_tx.send(#inner);
        // ...
    }
)
```

Using the match statement inside the generated code allows the default exhaustive
checking of the variants. Programmers have the choice to explicitly opt out of
the exhaustive check using a catch-all branch like `_ => {}`.

In the above example, `m` generated by the macro is the handle to the function
that kickstarts the management of the routines.

## Partially Open Loop

A partially open loop is a function, spawned off as a coroutine, that takes a
collection of inputs and processes them to either produce outputs that it cannot
further process or more inputs which are fed back into itself. This process
continues until the collection of inputs gets completely exhausted.

{{< math PartiallyOpenLoop.svg >}}

This design can be implemented in multiple ways. The first
is to return an object with an enum attribute inside it or having a 2 element tuple with
the enum variant and the struct akin to function return types in *Go*.

Another way is to wrap the structures inside enum variants and explicitly tell the API
which variant implies further processing and which one implies a finalized output.

I advocate for defining a trait on an enum that wraps the output type of the
function which allows the API to call the associated method on the object to
know whether it is a input or a final output.

Consider the following trait:

```rust
pub trait PartiallyOpenLoop {
  fn is_final(&self) -> bool;
}
```

This allows the API to call the `is_final` method of the object after each pass
and determine when it is ready to be sent off to the next layer.

# Conclusion

All of the above patterns are intentionally isolated, reusable components. This allows us to layer them one after the other in any order, any number of times (except for the collector).
Hopefully, this makes the application code easier to understand and debug by making (even the concurrent) code flow in a more linear fashion.

That's all for now. Bye!
