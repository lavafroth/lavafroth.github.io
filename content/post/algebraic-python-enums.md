---
title: "Algebraic Python Enums"
date: 2025-11-02T19:08:46+05:30
draft: false
tags:
- Python
- Decorators
- Rust
- Algebraic Data Types
---

As much as I like rust for its ergonomic features, University has forced me to use Python for the past couple of months, especially because of the hype for machine learning and data science.

One of the biggest things that I missed from the rust experience was enumerable data types whose variants can wrap around different datatypes.

Fortunately, since Python 3.8, creating structs has been a breeze using the dataclass decorator. There's even support for structural match expressions, like in rust, in recent versions of [Python](https://peps.python.org/pep-0636/).

To that end, creating the equivalent to Rust's enum types involves Python union types.

## First draft

```python
# glass_enum.py

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
def report_drink(glass: Glass) -> str:
  match glass:
    case Empty():
      return "Whoops, looks like you've finished your drink!"
    case Full(drink):
      return f"Ah a {drink}, what a fine taste!"
```

## Pitfalls

### No direct variant access

Since there is no namespacing, we also can't instantiate variants under the `Glass` namespace. The following code does not work.

```python
dr_pepper = Glass.Full("Dr. Pepper")
```

This can be partially solved by putting the entire enumerable type inside a module.
Here we have saved the file as `glass_enum.py`. From a different module we can
access the variants as `glass_enum.Empty` and `glass_enum.Full`.

```py
# main.py
import glass_enum

fanta = glass_enum.Full('Fanta')
empty = glass_enum.Empty()
```

Now any function outside the module has to ingest a rather confusing argument of type `glass_enum.Glass`.

```python
def refill(glass: glass_enum.Glass) -> glass_enum.Glass:
  # ...
  return glass
```

Since using a module namespace only causes more confusion, we will discard this idea.

### No methods on the enum itself

With no namespaceing, methods cannot be defined on the `Union` of the different variants.

In the case of our concrete example, we can't add methods to the `Glass` type.

```python
def refill(glass: Glass) -> Glass:
  if glass.is_empty(): # can't implement on type `Glass` directly
    return Full('water')
  return glass
```

Even if we use module level namespacing, it's simply not possible to define any method on a `Union` type in Python.

To define a method like `is_empty()`, it must be implemented on both the classes `Full` and `Empty`. This can get
tedious if there are 3 or more variants.

## Python is a sneaky language

Last week I discovered that Python allows creating nested classes to keep things organized.

```python
from dataclasses import dataclass

class Glass:
  @dataclass
  class Empty:
    pass

  @dataclass
  class Full:
    drink: str
```

Python will happily run the above code and we can access the "variants" under the `Glass` namespace.

```python
lemonade = Glass.Full('lemonade')
```

If only we could register the variants as the `Glass` type itself and inherit all its methods.

### Redecorate

We can define a decorator that takes all of the nested dataclasses and makes them inherit the outer class.

```python
import inspect

def AlgebraicEnum(cls):
    for subclass_name, subclass in inspect.getmembers(cls, predicate=inspect.isclass):
        if subclass_name != "__class__":
            setattr(cls, subclass_name, type(subclass_name, (cls, subclass), {}))

    return cls
```

That's all there is to the magic! Now we can simply add this decorator above the previous class declaration
and the variants like `Glass.Empty` and `Glass.Full` would be of the type `Glass`.

```python
from dataclasses import dataclass

@AlgebraicEnum
class Glass:
  @dataclass
  class Empty:
    pass

  @dataclass
  class Full:
    drink: str

  def report_drink(self) -> str:
    match self:
      case Glass.Empty():
        return "Whoops, looks like you've finished your drink!"
      case Glass.Full(drink):
        return f"Ah a {drink}, what a fine taste!"

  def is_empty(self) -> str:
    match self:
      case Glass.Empty():
        return True
    return False
```

As a bonus, the variants will also inherit any methods defined on the `Glass` type.

Note how the `report_drink` method accepts a `self` of type `Glass` and the match arms
compare it with `Glass.Empty` and `Glass.Full`.

These methods get automatically called via the method resolution order chain due to the inheritance.

## Closing thoughts

Those 6 lines are the bare minimum of what you can do right now to have well organized and namespaced algebraic enums in Python
which are somewhat comparable to those in Rust. These enums also play nicely with static type checkers
and _goto-definitions_ will also lead you to the correct class defining a variant or the enum itself.

I have packaged this decorator with a couple more typing restrictions into a library at [github:lavafroth/ape](https://github.com/lavafroth/ape).

I hope you enjoyed this foray into contorting Python.
