---
title: "Headache"
date: 2023-09-07T07:03:27+05:30
tags:
- AmateursCTF
- CTF
- Reverse Engineering
draft: false
---

This challenge involves reverse engineering a polymorphic binary, one that modifies its own instructions during runtime.

Essentially, the binary checks if the current character equals a known value and *xor* decrypts the next section where the
code jumps to. If the characters don't match, the logic short-circuits and the program exits.

This process of checking the character and decrypting the next branch continues like opening up a Matryoshka doll until
the last branch which returns instead of calling the decryption subroutine.

To begin, we need to have radare2 installed. Next, we will create a Python virtual environment and install the r2pipe package.

```sh
python -m venv env
source env/bin/activate # or activate.fish in my case
pip install r2pipe
```

We download the `headache` binary and place the following script in our working directory:

```python
import sys
import shutil
import binascii
import r2pipe
from dataclasses import dataclass
import struct
from typing import Optional
import os

if os.path.exists('headache_patched'):
    os.unlink("headache_patched")
shutil.copy('headache', 'headache_patched')
r2 = r2pipe.open("headache_patched", flags=['-w'])

@dataclass
class Formula:
    a: int
    b: int
    xor: int

    def apply(self, flag):
        a_exists = flag[self.a] is not None
        b_exists = flag[self.b] is not None

        if a_exists and not b_exists:
            result = flag[self.a] ^ self.xor
            if not valid_character(result):
                return
            flag[self.b] = result

        elif b_exists and not a_exists:
            result = flag[self.b] ^ self.xor
            if not valid_character(result):
                return
            flag[self.a] = result


def unravel(base: int) -> (int, Optional[Formula]):
    r2.cmd("af-")
    r2.cmd("s {}".format(hex(base)))
    r2.cmd("af")

    pdr = r2.cmd("pi 10")
    try:
        r2.cmd("s +3")
        exec(r2.cmd("pcp 1"), globals())
        a = ord(buf)

        r2.cmd("s +3")
        b = 0
        exec(r2.cmd("pcp 1"), globals())
        if buf == b'\x7f':
            r2.cmd("s +1")
            exec(r2.cmd("pcp 1"), globals())
            b = ord(buf)

        r2.cmd("s +4")
        exec(r2.cmd("pcp 1"), globals()) 
        x = ord(buf)
        f = Formula(a, b, x)
    except:
        base, None

    jump_index = pdr.find("je ")
    
    pdr = pdr[jump_index + 3:]
    other_block = pdr[:8]
    r2.cmd("s 0x" + other_block)
    r2.cmd("af-")
    r2.cmd("af")

    # mov eax == b8 (one byte)
    r2.cmd("s +1")

    exec(r2.cmd("pcp 4"), globals())
    xor_key = buf

    r2.cmd("s +8")
    # lea address is now in buf
    exec(r2.cmd("pcp 4"), globals())
    mutating_fn = struct.unpack("<I", buf)[0]
    if mutating_fn == 0xffffffff:
        return base, None
    
    r2.cmd("s " + hex(mutating_fn))
    while True:
        exec(r2.cmd("pcp 4"), globals())
        recovered = bytearray(x ^ y for x, y in zip(buf, xor_key))
        unpacked = struct.unpack("<I", recovered)[0]
        r2.cmd('wv {}'.format(unpacked))
        r2.cmd("s +4")
        if recovered == xor_key:
            break

    return mutating_fn, f

formulas = []

next_addr = 0x401290
while next_addr != 0x40261c:
    next_addr, formula = unravel(next_addr)
    if formula is None:
        r2.quit()
        r2 = r2pipe.open("headache_patched", flags=['-w'])
        continue
    print(hex(next_addr))
    formulas.append(formula)

    
charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"

def valid_character(c: int):
    return c < 256 and chr(c) in charset


flag = [None] * 61
for i, c in enumerate(map(ord, "amateursCTF{")):
    flag[i] = c

flag[-1] = ord('}')

while not all(flag):
    for formula in formulas:
        formula.apply(flag)

print(''.join(map(chr, flag)))

```

Note that we begin our binary parsing from the address `0x401290` since that is where the first condition and subsequent decryptions begin.
We also allocate a list of 61 `None` singletons since the program exits if the input has a length other than 61.

Finally, we can run our script.

```sh
python main.py
```

Since Python is quite slow and my solution is not elegant, it will take anywhere between 2 to 4 minutes to decrypt all the sections. After this, we get the flag.

```
amateursCTF{i_h4v3_a_spli77ing_headache_1_r3qu1re_m04r_sl33p}
```