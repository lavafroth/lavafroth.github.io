---
title: "In search of the smallest DNA complement function"
date: 2025-02-14T09:40:11+05:30
draft: true
tags:
- DNA
- Bioinformatics
- Linear Algebra
- Remainder Theorem
---

For the past few weeks, I have been trying to come up with a fast and purely agebraic function to convert DNA bases to their
respective complements.

## Problem statement

Our goal is rather straightforward. We aim to create a mapping of the characters `a`, `t`, `g`, `c` and `n` to their respective complements.
We choose to keep our solution one step behind the classical reverse complement which reverses the string after the mapping.

Lastly, we will stick to lowercase characters and not deal with RNA bases for the sake of simplicity.

Here's what the mapping would look like:

  |  |  |  |  |
--|--|--|--|--|--
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

The crux of this method relies on the existence of a vector \(\vec{\mathbf{v}}\) such that for each input character \(p\)
and the complement \(q\),

$$ \vec{\mathbf{v}} \cdot (p^4, p^3, p^2, p^1, p^0) = q $$


Consider the input character 'a' and the corresponding output 't'.
We substitute p and q in the previous expression with the ASCII values 97 and 116 respectively to get
the following polynomial.

$$ 97^4x_{4} + 97^3x_{3} + 97^2x_{2} + 97^1x_{1} + 97^0x_{0} = 116 $$

We can setup a system of polynomials for the remaining mappings in the same way.
This gives us 5 equations, which is precisely why we chose 5 coefficients in \(\vec{\mathbf{v}}\).

If we had more equations than unknowns, we would have been redundant. Whereas,
more unknowns than equations yields infinitely many solutions.

Here's one more example for `c` at 99, mapping to `g` at 103.

$$ 99^4x_{4} + 99^3x_{3} + 99^2x_{2} + 99^1x_{1} + 99^0x_{0} = 103 $$

In general, we have a matrix representing a linear map from \( \mathbf{R}^5 \) to  \( \mathbf{R}^5 \).

$$
\begin{bmatrix}
97^4 & 97^3 & 97^2 & 97^1 & 97^0\\
116^4 & 116^3 & 116^2 & 116^1 & 116^0\\
99^4 & 99^3 & 99^2 & 99^1 & 99^0\\
103^4 & 103^3 & 103^2 & 103^1 & 103^0\\
110^4 & 110^3 & 110^2 & 110^1 & 110^0\\
\end{bmatrix}
\begin{bmatrix}
x_4 \\
x_3 \\
x_2 \\
x_1 \\
x_0
\end{bmatrix} =
\begin{bmatrix}
116 \\
97 \\
103 \\
99 \\
110
\end{bmatrix}
$$

Also observe that a linear map would allow us to shift the inputs by some offset and guarantee that the output is also shifted by the same offset.

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

    if 0 in coeffs:
        print(f'{n} -> {coeffs}')
```

We prioritize coefficients that contain zeros since they allow us to ignore a term in the resulting polynomial.

Running the experiment yields a single polynomial where one of the coefficients is 0.

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

In this approach, a given base \(u\) maps to its complement \(v\) as

$$
v = K \pmod{u}
$$

where \(K\) is some known constant.

We are essentially trying to mend our problem into a Chinese remainder theorem problem. However, all moduli in a CRT problem
must be coprime. The numerical representations of our bases \(\vec{u} = (97, 116, 99, 103, 110)\) aren't quite coprime.

To deal with this, we double all the entries and add an odd number.
More abstractly, for every \(u\), \(2u\) must be even. Adding an odd number \(h\), then, must make \(2u+h\) odd.

Varying this \(h\) can potentially yield some \(2\vec{u} + h\) whose elements are coprime.

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


u = np.array(tuple(b"atgcn"))
compl = np.array(tuple(b"tacgn"))

# smallest target, i.e., a
min_of_seq = np.min(compl)
compl -= min_of_seq

# the largest value of the complement must be a principal value in (mod N)
ring_enclose = np.max(compl)
ring_enclose += 1 - ring_enclose & 1
print(f"{u} maps to {compl}")

min_answer = float('Infinity')
min_ih = None

for i in range(1, 32):
    # -2 * i * min_of_seq so that `vs` is as small as possible
    # + field_should_enclose so that `vs` is atleast positive and
    # greater than the largest element of `seq`
    for h in range(-2 * i * min_of_seq + ring_enclose, 0, 2):

        # The linear transform 2iu + h
        vs = 2 * i * u + h

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
            min_ih = (i, h)
            print(f"progress: {min_ih} -> {int(min_answer)}")

min_answer = int(min_answer)
print(f"{min_ih} -> {min_answer}")
```

We set the upper limit of our experiment as 32 to avoid waiting too long
for a reasonable answer.

```
[ 97 116 103  99 110] maps to [19  0  2  6 13]
progress: (1, -159) -> 47922894
progress: (3, -559) -> 33253051
(3, -559) -> 33253051
```

With the final solution, we can cook up the following function. Note how we add 97 since we had shifted \(\vec{v}\)
such that its smallest element was 0.

```python
for base in 'atgcn':
    compl = chr(97 + 33253051 % (6*ord(base)-559))
    print(f'{base} -> {compl}')
```

## Wrapping up

Those were two ways I could think of mapping DNA nucleobases to their complements. Although this is a contrived example,
it was a fun exercise and the modular arithmetic approach is my personal favorite. Let me know how you would have solved
this differently by shooting me an email!

Bye now.
