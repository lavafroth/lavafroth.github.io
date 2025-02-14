---
title: "In Search of the Smallest DNA Complement Function"
date: 2025-02-14T09:40:11+05:30
draft: true
---

For the past few weeks, I have been trying to come up with a fast and purely agebraic function to convert DNA bases to their
respective complements.

## Problem statement

Our goal is rather straightforward. We aim to create a mapping of the characters `a`, `t`, `g`, `c` and `n` to their respective complements.
We choose to keep our solution one step behind the classical reverse complement which reverses the string after the mapping.

Lastly, we will stick to lowercase characters and not deal with RNA bases for the sake of simplicity.

Here's what the mapping would look like:

 |
--|-|-|-|-|-
Input | a | t | c | g | n
Output | t | a | g | c | n

## Kicking the tires

Let us first note that we can't just use the value `a`, `t`, `c`, etc. as inputs to a function. We must convert them
to a numerical representation.

Although we might be tempted to use a given character's position in the alphabet,
we should prefer using the ASCII character representations since a computer will be used to churn this magic function eventually.

We can easily get the ASCII representations in python as the following:
```python
print(tuple(b'atcgn'))
```

which gives us `(97, 116, 99, 103, 110)`

Now, let's examine the different ways we can approach the problem.

## Matrices and polynomials

```python
from sympy import Matrix

mappings = {
    'a': 't',
    't': 'a',
    'g': 'c',
    'c': 'g',
    'n': 'n',
}

bases = tuple(mappings.keys())

for n in range(-1000, 1000):
    mat = []
    for dna_base in bases:

        dna_base_n = ord(dna_base) - n
        dna_compl = mappings[dna_base]
        dna_compl_n = ord(dna_compl) - n

        row = [dna_base_n ** i for i in range(len(bases))]

        row.append(dna_compl_n)
        mat.append(row)

    coeffs = Matrix(mat).rref()[0][:, -1]
    # prioritize zeros
    # if a coefficient is 0, we can skip raising x to some power
    if 0 in coeffs:
        print(f'{n} -> {coeffs}')
```

Running the above experiment yields us just one polynomial where one of the coefficients is 0.

```
110 -> Matrix([[0], [16075/51051], [-72265/204204], [-1721/102102], [235/204204]])
```

```python
def compl(x: str) -> str:
    x = ord(x) - 110
    c = (64300 * x -72265 * x**2 -3442 * x**3 + 235 * x**4)//204204 + 110
    return chr(c)
```

## Modular arithmetic

```py
from itertools import starmap, permutations
import numpy as np


def egcd(a, b):
    old_r, r = a, b
    old_s, s = 1, 0

    while r != 0:
        quo = old_r // r
        old_r, r = r, old_r % r
        old_s, s = s, old_s - quo * s

    # if b != 0:
    #     t = (old_r - old_s * a) // b
    # else:
    #     t = 0

    # return (old_r, old_s, t)
    return (old_r, old_s)


def gcd(a, b):
    return egcd(a, b)[0]


def are_coprime(a, b):
    return gcd(a, b) == 1


def modinv(a, b):
    old_r, old_s = egcd(a, b)
    if old_r != 1:
        raise ValueError("modular multiplicative inverse is not possible")
    return old_s % b


def are_pairwise_coprime(vs):
    return all(starmap(are_coprime, permutations(vs, 2)))


seq = np.array([ord(x) for x in "atgcn"])
compl = np.array([ord(x) for x in "tacgn"])

# smaller numbers
min_of_seq = np.min(compl)
compl -= min_of_seq

# the largest value of the complement must be a principal value in (mod N)
field_should_enclose = np.max(compl)
# but it must also be odd because even number + odd number = odd number
# inside the loop body below ensures that we have some chance of getting
# a set of pairwise coprime numbers after the linear transform on `vs`
field_should_enclose += 1 - field_should_enclose & 1
print(f"{seq} maps to {compl}")

min_answer = float('Infinity')
min_ij = None

for i in range(1, 32):
    # -2 * i * min_of_seq so that `vs` is as small as possible
    # + field_should_enclose so that `vs` is atleast positive and
    # greater than the largest element of `seq`
    for j in range(-2 * i * min_of_seq + field_should_enclose, 0, 2):

        # The linear transform
        vs = 2 * i * seq + j

        if not are_pairwise_coprime(vs):
            continue

        # apply chinese remainder theorem
        pi_n = np.prod(vs)
        pi_all_but_ni = pi_n / vs
        try:
            modinv_ni = np.array(tuple(starmap(modinv, zip(pi_all_but_ni, vs))))
        except ValueError:
            continue

        pieces = pi_all_but_ni * compl * modinv_ni
        answer = np.sum(pieces) % pi_n

        if answer < min_answer:
            min_answer = answer
            min_ij = (i, j)
            print(f"progress: {min_ij} -> {int(min_answer)}")

        # print(f"{i}, {j} -> {vs} -> {answer}")

min_answer = int(min_answer)
print(f"{min_ij} -> {min_answer}")
```

We set the upper limit of our experiment as 32 to avoid waiting too long
for a reasonably decent answer.

```
[ 97 116 103  99 110] maps to [19  0  2  6 13]
progress: (1, -159) -> 47922894
progress: (3, -559) -> 33253051
(3, -559) -> 33253051
```

With the last solution, we can cook up the following function. Note how we add `97` (ASCII `a`) because it was the minimum of the complements
```
(97, 116, 99, 103, 110)
```
and we intentionally subtracted it, shifting all the values closes to 0. Thus, the complements become
`[19  0  2  6 13]` instead of `b"tacgn"`.

```python
for base in 'atgcn':
    compl = chr(97 + 33253051 % (6*ord(base)-559))
    print(f'{base} -> {compl}')
```
