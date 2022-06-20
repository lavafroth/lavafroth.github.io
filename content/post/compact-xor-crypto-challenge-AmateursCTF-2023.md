---
title: "Compact XOR"
tags:
- AmateursCTF
- CTF
- Cryptography
date: 2023-08-24T18:05:59+05:30
draft: false
---

# Description

I found some hex in a file called fleg, but I’m not sure how it’s encoded. I’m pretty sure it’s some kind of xor…

# Exploration

We begin by creating a new rust project.

```sh
cargo new amateurs
cd amateurs
cargo add hex
cargo add itertools
```

Let's decode the hexadecimal contents of the file using the following Rust code:

```rust
fn main() -> Result<(), Box<dyn std::error::Error>> {
    let bytes = hex::decode("610c6115651072014317463d73127613732c73036102653a6217742b701c61086e1a651d742b69075f2f6c0d69075f2c690e681c5f673604650364023944")?;
    let stream = String::from_utf8_lossy(&bytes);
    println!("{:?}", stream);
    Ok(())
}
```

To execute the code, issue the following.

```sh
cargo run
```

This gives us a string with every other character being non-printable.

```
"a\u{c}a\u{15}e\u{10}r\u{1}C\u{17}F=s\u{12}v\u{13}s,s\u{3}a\u{2}e:b\u{17}t+p\u{1c}a\u{8}n\u{1a}e\u{1d}t+i\u{7}_/l\ri\u{7}_,i\u{e}h\u{1c}_g6\u{4}e\u{3}d\u{2}9D"
```

Notice how each odd numbered character spells out the corresponding character for an "amateursCTF{...}" flag.

```rust
let mut odd_bytes = bytes.iter().step_by(2);
let odd_bytes_vec: Vec<u8> = odd_bytes.clone().copied().collect();
let odd_characters = String::from_utf8_lossy(&odd_bytes_vec);
println!("{:?}", odd_characters);
```

This code gives us the following result:

```
"aaerCFsvssaebtpaneti_li_ih_6ed9"
```

On further inspection, it appears that the first character of the raw bytes, 'a', **xor**ed with the second byte, 0xC results in the character 'm'.
After this transformation, the first 3 bytes spell "ama" like the start of an "amateursCTF{...}" flag.

The above observation implies that every other character is the **xor** of its previous character and its original counterpart. Since **xor** is an involuntary function,
we can now reverse this transformation by **xor**ing them back with their previous characters.

```rust
let even_bytes = bytes.iter().skip(1).step_by(2);

let recovered = odd_bytes.clone().zip(even_bytes).map(|(a, b)| a ^ b);
let solution: Vec<u8> = itertools::interleave(odd_bytes.copied(), recovered).collect();
println!("{}", String::from_utf8_lossy(&solution));
```

The final code looks like the following:

```rust
fn main() -> Result<(), Box<dyn std::error::Error>> {
    let bytes = hex::decode("610c6115651072014317463d73127613732c73036102653a6217742b701c61086e1a651d742b69075f2f6c0d69075f2c690e681c5f673604650364023944")?;
    let stream = String::from_utf8_lossy(&bytes);
    println!("{:?}", stream);
    let odd_bytes = bytes.iter().step_by(2);

    let odd_bytes_vec: Vec<u8> = odd_bytes.clone().copied().collect();
    let odd_characters = String::from_utf8_lossy(&odd_bytes_vec);
    println!("{:?}", odd_characters);

    let even_bytes = bytes.iter().skip(1).step_by(2);

    let recovered = odd_bytes.clone().zip(even_bytes).map(|(a, b)| a ^ b);
    let solution: Vec<u8> = itertools::interleave(odd_bytes.copied(), recovered).collect();
    println!("{}", String::from_utf8_lossy(&solution));
    Ok(())
}
```

Running this code gives us the flag.

```
amateursCTF{saves_space_but_plaintext_in_plain_sight_862efdf9}
```
