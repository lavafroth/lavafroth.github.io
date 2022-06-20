---
title: "Volcano"
tags:
- AmateursCTF
- CTF
- Remainder Theorem
- Reverse Engineering
date: 2023-07-21T18:29:59+05:30
draft: false
---

This reversing challenge is very mathematical, focusing mainly on modulo congruences.
Like all challenges, there is some scary looking obfuscation for the fun which I'll try my best to
explain. The challenge description says that it was *inspired by recent "traumatic" events* but I'm oblivious to what that
reference meant.

## Decompilation

We start off with downloading the binary and opening it in Ghidra.

In the list of functions under the Symbol Tree, we can navigate to the `entry` function which looks like:

```C
void processEntry entry(undefined8 param_1,undefined8 param_2)
{
  undefined auStack_8 [8];
  
  __libc_start_main(FUN_001014a7,param_2,&stack0x00000008,FUN_00101760,FUN_001017d0,param_1,auStack_8);
  do {
  /* WARNING: Do nothing block with infinite loop */
  } while( true );
}
```

Notice the call to `__libc_start_main`, the first argument supplied is a function pointer which points to the main function.

I have a habit of renaming variables in Ghidra so that they make some sense. I will rename this function to `main`.

```C
__libc_start_main(main,param_2,&stack0x00000008,FUN_00101760,FUN_001017d0,param_1,auStack_8);
```

### `main`

If we double click on the newly renamed `main` function, we will see a function that has a massive cyclomatic complexity in the decompiler view.
I will try to make this more sensible by selecting the generated identifiers, then renaming (pressing `L`) and retyping (`Ctrl` `L`).

```C
int main(void)

{
  bool ok;
  bool _ok;
  int ret;
  long n_volcano;
  long n_bear;
  ulong m_v;
  ulong m_b;
  long fs_register;
  ulong bear;
  ulong volcano;
  ulong proof;
  ulong leet;
  FILE *flag;
  char buf [136];
  long canary;
  
  canary = *(long *)(fs_register + 0x28);
  setbuf(stdin,(char *)0x0);
  setbuf(stdout,(char *)0x0);
  setbuf(stderr,(char *)0x0);
  printf("Give me a bear: ");
  bear = 0;
  scanf("%llu",&bear);
  ok = process_bear(bear);
  if (ok) {
    printf("Give me a volcano: ");
    volcano = 0;
    scanf("%llu",&volcano);
    _ok = process_volcano(volcano);
    if (_ok) {
      printf("Prove to me they are the same: ");
      proof = 0;
      leet = 0x1337;
      scanf("%llu",&proof);
      if (((proof & 1) == 0) || (proof == 1)) {
        puts("That\'s not a valid proof!");
        ret = 1;
      }
      else {
        n_volcano = n_digits(volcano);
        n_bear = n_digits(bear);
        if (n_volcano == n_bear) {
          n_volcano = sum_of_digits(volcano);
          n_bear = sum_of_digits(bear);
          if (n_volcano == n_bear) {
            m_v = check_proof(leet,volcano,proof);
            m_b = check_proof(leet,bear,proof);
            if (m_v == m_b) {
              puts("That looks right to me!");
              flag = fopen("flag.txt","r");
              fgets(buf,0x80,flag);
              puts(buf);
              ret = 0;
              goto LAB_00101740;
            }
          }
        }
        puts("Nope that\'s not right!");
        ret = 1;
      }
    }
    else {
      puts("That doesn\'t look like a volcano!");
      ret = 1;
    }
  }
  else {
    puts("That doesn\'t look like a bear!");
    ret = 1;
  }
LAB_00101740:
  if (canary != *(long *)(fs_register + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return ret;
}
```

The program asks for an unsigned long integer as a bear. It calls a subroutine to process the integer
and stores the result in the `ok` variable.

```C
printf("Give me a bear: ");
bear = 0;
scanf("%llu",&bear);
ok = process_bear(bear);
```

The next block only executes when `ok` is true.

```C
if (ok) {
  // ...
}
```

Inside this block, the program for another unsigned long integer as before but calls it a volcano, running
a check specific to this input.

```C
printf("Give me a volcano: ");
volcano = 0;
scanf("%llu",&volcano);
_ok = process_volcano(volcano);
```

The next conditional block executes when this `process_volcano` subroutine return true.

```C
if (_ok) {
  // ...
}
```

The program then asks for another unsigned long integer as a proof for the *"volcano"* and the *"bear"* being the same.

```C
printf("Prove to me they are the same: ");
proof = 0;
leet = 0x1337;
scanf("%llu",&proof);
```

If the proof value's last bit (`proof & 1`) is 0, meaning if the proof is even or it is 1, we get the bad ending
that says, "That's not a valid proof!"

```C
if (((proof & 1) == 0) || (proof == 1)) {
  puts("That\'s not a valid proof!");
  ret = 1;
}
```

For the good ending, we check what's in the `else` block.

Here, I have renamed two functions to `n_digits` and `sum_of_digits` because that is exactly what they do.
There's nothing worth explaining about them in particular but you may check them if you are following along.

First we need the number of digits in the volcano and bear digits to be equal.

```C
n_volcano = n_digits(volcano);
n_bear = n_digits(bear);
if (n_volcano == n_bear) {
  // ...
 }
```

Our second constraint is that the sum of the digits must equal for the volcano and the bear.

```C
n_volcano = sum_of_digits(volcano);
n_bear = sum_of_digits(bear);
if (n_volcano == n_bear) {
  // ...
}
```

Finally the happy ending happens when the result of a proof checking function is the same for both the numbers.

```C
m_v = check_proof(leet,volcano,proof);
m_b = check_proof(leet,bear,proof);
if (m_v == m_b) {
  puts("That looks right to me!");
  flag = fopen("flag.txt","r");
  fgets(buf,0x80,flag);
  puts(buf);
  ret = 0;
  goto LAB_00101740;
}
```

Now, I will visit the functions that I had glossed over earlier.

### `process_bear`

The decompilation looks like the following after some renaming and cleanup.

```C
bool process_bear(ulong b) {
  if ((b & 1) == 0) {
    if (b % 3 == 2) {
      if (b % 5 == 1) {
        if (b + ((b - b / 7 >> 1) + b / 7 >> 2) * -7 == 3) {
          if (b % 0x6d == 0x37) {
            return true;
          }
        }
      }
    }
  }
  return false;
}
```

This function gives us the constraints for the unsigned long integer represented by "bear".
The function only returns true when all of the following conditions are met by the number:

- The last bit is zero (`b & 1 == 0`), meaning, it is even.
- When divided by 3, yields the remainder of 2.
- When divided by 5, yields the remainder of 1.
- When divided by 0x6d, yields the remainder of 0x37.
- The madness that is `b + ((b - b / 7 >> 1) + b / 7 >> 2) * -7 == 3`

Okay, calm down, the last part is not very hard to decipher. Let's work it out piece by piece.

The right shift operation (`>>`) implies division by 2 to the power of something. So the innermost parenthetic expression
`b - b / 7 >> 1` means to divide `b - b / 7` by 2 to the power of 1.

When considered as a purely mathematical expression, we can perform the following simplification.

{{< math volcano-expression-0.svg >}}

{{< math "volcano-expression-1.svg" >}}

{{< math "volcano-expression-0.svg" >}}

{{< math "volcano-expression-1.svg" >}}

{{< math "volcano-expression-2.svg" >}}

{{< math "volcano-expression-3.svg" >}}

{{< math "volcano-expression-4.svg" >}}

{{< math "volcano-expression-5.svg" >}}

We can cancel the 4s in the numerator since they were results of the shift operations.

{{< math "volcano-expression-6.svg" >}}

However, we cannot cancel out the 7s since they were part of the C division.
Remember, the divison operation in C results in the truncated integer quotient, not a floating point number.
This means 

{{< math "volcano-expression-7.svg" >}}

here gives us the largest multiple of 7 below `b`.

Another way to think of it is the part of `b` that is divisible by 7, leaving out the remainder.

When we subtract this from the original number, we get what was left out, the remainder itself!

The entire condition simplifies to:

```C
b % 7 == 3
```

This will be another constraint for the `bear` number.

### `process_volcano`

The decompilation after renames and cleanups looks like the following:

```C
bool process_volcano(uint64_t v) {
  uint64_t total_bits = 0;
  for (uint64_t i = v; i != 0; i = i >> 1) {
    total_bits = total_bits + (i & 1);
  }
  if (total_bits > 0x11) && (total_bits < 0x1b) {
    return true;
  }
  return false;
}
```

Here the program loops over the bits in the number supplied and counts the ones that are high.
The function only returns a true value when the total number of high bits is between 17 (0x11, inclusive) and 27 (0x1b, exclusive).

This is a constraint for the `volcano` number.

### `check_proof`

As usual, I have cleaned some of the code, renamed a bunch of variables for them to make sense.

```C
uint64_t check_proof(uint64_t leet, uint64_t v, uint64_t proof) {
  uint64_t ret = 1, mod = leet % proof;
  for (uint64_t i = v; i != 0; i = i >> 1) {
    if (i & 1) {
      ret = (ret * mod) % proof;
    }
    mod = (mod * mod) % proof;
  }
  return ret;
}
```

This function begins by defining a return variable as 1 and another variable `mod` as result of the `leet` modulo the proof value. I have renamed this
variable leet since 0x1337 is the only number supplied as the argument throughout the program.

It then loops over the bits of the argument `v`. If a given bit is high, the return value gets assigned itself multiplied by the `mod`, modulo the proof value.
Otherwise, the `mod` variable gets assigned itself squared, modulo the proof.

Recall that the result of this function must be equal for both the `volcano` and the `bear` number.

How do we make sure that the results are equal if there is so much of pseudo-randomness involved?

Our best option is to somehow have the `mod` variable as 1 since anything times 1 is itself.
The return value in such a case is bound to its initial value of 1 for any non-zero proof value.

For this to happen, `leet % proof` must be equal to 1. Noting that 0x1337 (4919) is the only value passed as leet,
we have the constraint

{{< math "volcano-expression-8.svg" >}}

The congruence can be rewritten as:

{{< math "volcano-expression-9.svg" >}}

{{< math "volcano-expression-10.svg" >}}

{{< math "volcano-expression-11.svg" >}}

Earlier, we noted that the proof value cannot be 1 and it cannot be even.
Thus, we need an odd proof value that divides 4918 without leaving any remainder.

The number 2 divides 4918 to give 2459, a prime number.

This implies, 2 and 2459 are the prime factors of 4918. Since 2 is even, we will choose **2459** as the proof value.

## Solving for the `volcano` and the `bear`

I will be writing a little Rust program to solve for the remaining constraints.

We know that the `volcano` number must have at least 17 high bits and at most 27 high bits. Hence, we will begin by
generating numbers that have 17 high bits and 1 low bit.

```rust
let ones = 17;
let bits = ones + 1;
let volcanos = (0..bits)
    .map(|position| (1 << position) ^ ((1 << bits) - 1))
    .collect::<Vec<i32>>();
```

This gives us numbers that have a binary representation like:

```rust
111111111111111110
111111111111111101
111111111111111011
111111111111110111
// and so on
```

For any of these numbers we wish to find a `bear` number that:

- is even
- yields the remainder of 2 when divided by 3
- yields the remainder of 1 when divided by 5
- yields the remainder of 3 when divided by 7
- yields the remainder of 55 when divided by 109
- has the same number of digits as the `volcano`
- has the same sum of digits as the `volcano`

The naive, inefficient solution would be to loop from 1 to infinity and check for each condition manually.
The code would look like the following:

```rust
for bear in 1.. {
  if bear % 2 == 0
  && bear % 3 == 2
  && bear % 5 == 1
  && bear % 7 == 3
  && bear % 109 == 55
  && sum_and_number_of_digits(bear) == sum_and_number_of_digits(volcano)
  {
    // do something
  }
}
```

Since most of the conditions are modulo congruence checks, we can use the Chinese Remainder Theorem
to solve for the smallest number that leaves the respective remainders and begin from there.

Let `a` be the array of all the moduli 2, 3, 5, 7 and 109.

{{< math "volcano-expression-12.svg" >}}

Let `r` represent the array of the respective remainders.

{{< math "volcano-expression-13.svg" >}}

We begin by calculating `n` as the product of all the moduli.

{{< math "volcano-expression-14.svg" >}}

We construct `m` containing the modulus of each equation by diving `n` by each element of `a`.

{{< math "volcano-expression-15.svg" >}}

We then calculate the multiplicative modular inverse of the aforementioned moduli with respect to the original moduli.

{{< math "volcano-expression-16.svg" >}}

> The modular inverse of a number `x` modulo `m` is the number `x_inv` such that its product with `x` mod `m` is 1.
>
> {{< math "volcano-expression-17.svg" >}}

We now multiply the calculated moduli and their inverses to find out the constants that leave the remainder 1.
Let's name this array of constants as `c`.

{{< math "volcano-expression-18.svg" >}}

We multiply the remainder with each constant and add them up. The final unique solution is this number modulo `n`.

{{< math "volcano-expression-19.svg" >}}

The code implementation looks like the following:

```rust
let moduli = [2, 3, 5, 7, 109];
let remainders = [0, 2, 1, 3, 55];

let n: i32 = moduli.iter().product();
let generated: Vec<i32> = moduli.iter().map(|m| n / m).collect();
let inverses: Vec<i32> = generated
    .iter()
    .zip(moduli.iter())
    .filter_map(|(a, m)| modinverse::modinverse(*a, *m))
    .collect();
let s: i32 = inverses
    .iter()
    .zip(generated.iter())
    .zip(remainders.iter())
    .map(|((m, m_inv), r)| m * m_inv * r)
    .sum();
let solution = s % n;
```

Here, I'm using the [modinverse](https://docs.rs/modinverse/latest/modinverse/) crate so that I don't have to implement it manually. If you are following along,
run the following to add it to your Rust project:

```sh
cargo add modinverse
```

For all the `volcano` numbers generated we search for a `bear` number starting from the unique `solution` and stepping by the product of all the moduli, `n`.
Again, if any of the `bear` values has the same number of digits and the same sum of digits as the volcano number, it is valid.

```rust
for volcano in volcanos {
    let v_digits = digits(volcano);
    for bear in (solution..volcano).step_by(n as usize) {
        if digits(bear) == v_digits {
            println!("volcano: {volcano}, bear: {bear}");
        }
    }
}
```

Here `digits` is a function that returns a tuple of the number of digits and sum of digits for an argument.

The complete program source code becomes the following:

```rust
fn digits(mut n: i32) -> (i32, i32) {
    let mut c = 0;
    let mut r = 0;
    while n != 0 {
        r += n % 10;
        n /= 10;
        c += 1;
    }
    (c, r)
}

fn main() {
    let ones = 17;
    let bits = ones + 1;
    let volcanos = (0..bits)
        .map(|position| (1 << position) ^ ((1 << bits) - 1))
        .collect::<Vec<i32>>();

    let moduli = [2, 3, 5, 7, 109];
    let remainders = [0, 2, 1, 3, 55];

    let n: i32 = moduli.iter().product();
    let generated: Vec<i32> = moduli.iter().map(|m| n / m).collect();
    let inverses: Vec<i32> = generated
        .iter()
        .zip(moduli.iter())
        .filter_map(|(a, m)| modinverse::modinverse(*a, *m))
        .collect();
    let constants_sum: i32 = inverses
        .iter()
        .zip(generated.iter())
        .zip(remainders.iter())
        .map(|((m, m_inv), r)| m * m_inv * r)
        .sum();
    let solution = constants_sum % n;
    for volcano in volcanos {
        let v_digits = digits(volcano);
        for bear in (solution..volcano).step_by(n as usize) {
            if digits(bear) == v_digits {
                println!("volcano: {volcano}, bear: {bear}");
            }
        }
    }
}
```

If we run the program using `cargo run`, we get multiple unqiue solutions to the problem:

```
volcano: 262139, bear: 132926
volcano: 262139, bear: 201596
volcano: 262079, bear: 155816
volcano: 262079, bear: 224486
volcano: 258047, bear: 155816
volcano: 258047, bear: 224486
volcano: 196607, bear: 178706
```

Now we can connect to the challenge server, supply any of the solutions and get the flag.

```sh
nc amt.rs 31010
```

```
Give me a bear: 132926
Give me a volcano: 262139
Prove to me they are the same: 2459
That looks right to me!
amateursCTF{yep_th0se_l00k_th3_s4me_to_m3!_:clueless:}
```
