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

University has compelled me to utilize Python despite my fondness for Rust,
primarily due to the  prevalence of machine learning and data science. One
aspect of Rust that I dearly miss is the  availability of enumerable data types
that can encapsulate various data types.

Although Python has the answer to creating structs as
[dataclasses](https://peps.python.org/pep-0557/), including support for
[structural match expressions](https://peps.python.org/pep-0636/) in recent
versions, most tutorials will suggest `Union` types as the equivalent to Rust's
enums.

> I highly encourage you to try out the code snippets and follow along with this article.
Use the collapse explanation button to copy multiple code blocks in one go.

## Naive draft

{{< collapsable-explanation >}}

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

For example

```python
dr_pepper = Full('Dr. Pepper')
print(report_drink(dr_pepper))
```

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

def report_drink(glass: Glass) -> str:
  match glass:
    case Empty():
      return "Whoops, looks like you've finished your drink!"
    case Full(drink):
      return f"Ah a {drink}, what a fine taste!"

dr_pepper = Full('Dr. Pepper')
print(report_drink(dr_pepper))
```

{{< /collapsable-explanation >}}

Will output

```
Ah a Dr. Pepper, what a fine taste!
```

## Pitfalls

### No direct variant access

{{< collapsable-explanation >}}

What if we had another `Union` with same variant names in the same file?

```python
@dataclass
class Full:
  gold: int
  gems: int

@dataclass
class Empty:
  pass

Inventory = Full | Empty
player_inventory = Full(500, 50)
```

Now we try to instantiate a `Glass` `Full` of `lemonade`.

```python
lemonade = Full("lemonade")
```

```python
@dataclass
class Full:
  gold: int
  gems: int

@dataclass
class Empty:
  pass

Inventory = Full | Empty
player_inventory = Full(500, 50)
lemonade = Full("lemonade")
```

{{< /collapsable-explanation >}}


Python will error out since `Full` now refers to the new variant of the
union type `Inventory`.

```
Traceback (most recent call last):
  File "<python-input-11>", line 1, in <module>
    lemonade = Full("lemonade")
TypeError: Full.__init__() missing 1 required positional argument: 'gems'
```

We can't instantiate variants as members of the `Glass` namespace. The following code does not work.

```python
dr_pepper = Glass.Full("Dr. Pepper")
```

This can be partially solved by keeping just the `Glass` type inside a module.
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

Since module namespacing only causes more confusion, we will discard this idea.

### No methods on the enum itself

Python also disallows methods from being defined on `Union` types.
In the case of our concrete example, we can't add methods to the `Glass` type.

The following code uses a hypothetical `is_empty()` method on the `Glass` union
type which is not allowed. Hence the code won't run.

```python
def refill(glass: Glass) -> Glass:
  if glass.is_empty(): # can't implement on type `Glass` directly
    return Full('water')
  return glass
```

To define a method like `is_empty()`, it must be implemented on both the classes
`Full` and `Empty`. This gets tedious for 3 or more variants.

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

{{< collapsable-explanation >}}

```python
def AlgebraicEnum(cls):
    for name, nested in cls.__dict__.items():
        if isinstance(nested, type):
            setattr(cls, name, type(name, (cls, nested), {}))

    return cls
```

The inheritance means all methods of the outer class are available on the nested
classes via the method resolution order chain _and_ any object of a nested class
`isinstance` of the outer class.

That's all there is to the magic! Simply adding this decorator above the
previous class declaration make variants like `Glass.Empty` and `Glass.Full`
inherit `Glass`.

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

  def report_drink(self: 'Glass') -> str:
    match self:
      case Glass.Empty():
        return "Whoops, looks like you've finished your drink!"
      case Glass.Full(drink):
        return f"Ah a {drink}, what a fine taste!"

  def is_empty(self: 'Glass') -> bool:
    match self:
      case Glass.Empty():
        return True
    return False
```

Note how the `report_drink` method accepts a `self` of type `Glass` and the match arms
compare it with `Glass.Empty` and `Glass.Full`.

The following code runs just fine.

```python
diet_coke = Glass.Full('diet coke')
empty = Glass.Empty()

print(diet_coke.report_drink())
print(empty.is_empty())
```

```python
from dataclasses import dataclass


def AlgebraicEnum(cls):
    for name, nested in cls.__dict__.items():
        if isinstance(nested, type):
            setattr(cls, name, type(name, (cls, nested), {}))

    return cls


@AlgebraicEnum
class Glass:
  @dataclass
  class Empty:
    pass

  @dataclass
  class Full:
    drink: str

  def report_drink(self: 'Glass') -> str:
    match self:
      case Glass.Empty():
        return "Whoops, looks like you've finished your drink!"
      case Glass.Full(drink):
        return f"Ah a {drink}, what a fine taste!"

  def is_empty(self: 'Glass') -> bool:
    match self:
      case Glass.Empty():
        return True
    return False


diet_coke = Glass.Full('diet coke')
empty = Glass.Empty()

print(diet_coke.report_drink())
print(empty.is_empty())
```

{{< /collapsable-explanation >}}

```
Ah a diet coke, what a fine taste!
True
```

## Closing thoughts

Those 6 lines are the bare minimum to get well organized and namespaced
algebraic enums in Python that are somewhat comparable to the ones in Rust. These
enums also play nicely with static type checkers, _goto-definitions_ will
lead you to the correct class definition.

I have packaged this decorator with a couple more typing restrictions into a library at [github:lavafroth/ape](https://github.com/lavafroth/ape).

I hope you enjoyed this foray into contorting Python.
