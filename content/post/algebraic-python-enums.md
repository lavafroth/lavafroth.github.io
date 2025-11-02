---
title: "Algebraic Python Enums"
date: 2025-11-02T19:08:46+05:30
draft: true
---

As much as I like rust for its ergonomic features, University has forced me to use Python for the past couple of months, especially because of the hype for machine learning and data science.

One of the biggest things that I missed from the rust experience was enumerable data types whose variants can wrap around different datatypes.

Fortunately, since Python 3.8, creating structs has been a breeze using the dataclass decorator. There's even support for structural match expressions, like in rust, in recent versions of Python. https://peps.python.org/pep-0636/

To that end, creating the equivalent to Rust's enum types involves Python union types.

```python
from dataclasses import dataclass

@dataclass
class Empty:
  pass

@dataclass
class Full:
  drink: str

Glass = Empty | Full
```

This allows us to define functions that ingest the `Glass` datatype.

```python
def report_drink(glass: Glass):
  match glass:
    case Empty:
      return "Whoops, looks like you've finished your drink!"
    case Full(drink):
      return f"Ah a {drink}, what a fine taste!"
```

The only downside to this is that there's no namespaceing of these union types and as such, methods cannot be defined on the `Union` of the different variants.

In the case of our concrete example, we can't add methods to the `Glass` type.

Since there is no namespacing, we also can't instantiate variants under the `Glass` namespace. The following code does not work.

```python
dr_pepper = Glass.Full("Dr. Pepper")
```

This can be partially solved by putting the entire enumerable type inside a module.

So now we can access the variants as `glass_enum.Empty` and `glass_enum.Full`.

Even if we use module level namespacing, it's simply not possible to define any message on a union type in Python.
