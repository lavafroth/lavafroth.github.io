---
title: "Pixelated"
tags:
- Cryptography
- CTF
- Image Reconstruction
- PicoCTF
- Rust
- Visual Cryptography
date: 2022-11-22T09:25:20+05:30
draft: false
---

This challenge gives use two images and asks us if we can make a flag out of them.
At first glance, both the images look like noise. Upon a quick web lookup of
[visual cryptography](https://en.wikipedia.org/wiki/Visual_cryptography), it appears
that these separate images, known as shares of the original image, can be overlayed
on each other to reconstruct the original image.

## Exploration

Now, I'm pretty sure that there are online services that will automatically solve these
but I decided to write some code to solve this locally. For the past week, I've been
learning the Rust programming language and this was the perfect excuse to test my knowledge.

First, we will create a cargo project. Let's call it "solve".

```sh
cargo new solve
```

We'll then add the image library (crate) using cargo.

```sh
cargo add image
```

Now let's get some Rust in action. We'll start by editing the `src/main.rs` file.
First, we import the required types with the use statement.

```rust
use image::{GenericImageView, ImageBuffer, Pixel, RgbaImage};
```

We'll now write the main function. Let's open the images and store handles to them
in variables `a` and `b`.

```rust
fn main() {
    let a = image::open("scrambled1.png").unwrap();
    let b = image::open("scrambled2.png").unwrap();
}
```

For sanity check, let's make sure that the dimensions are the same for both the images.

```rust
if a.dimensions() != b.dimensions() {
    panic!("Image dimensions don't match.");
}
```

Next, we'll create an image buffer for reconstructing the composite image.

```rust
let mut imgbuf: RgbaImage = ImageBuffer::new(a.width(), a.height());
```

Looping over the pixels in the shares,

```rust
for ((x, y, p), (_, _, q)) in a.pixels().zip(b.pixels()) {
}
```

we sum the values in each channel ...

```rust
&p.channels()
    .iter()
    .zip(q.channels().iter())
    .map(|(c0, c1)| c0.checked_add(*c1).unwrap_or(*c0))
    .collect::<Vec<u8>>(),
```

... and place the new pixel into the image buffer.

```rust
for ((x, y, p), (_, _, q)) in a.pixels().zip(b.pixels()) {
	imgbuf.put_pixel(x, y, *Pixel::from_slice(
		// --snip--
	    ),
    );
}
```

Finally, we save the image buffer into "flag.png".

```rust
imgbuf.save("flag.png").unwrap();
```

The entire code looks like the following:

```rust
fn main() {
    let a = image::open("scrambled1.png").unwrap();
    let b = image::open("scrambled2.png").unwrap();
    
    // the shares must have the same dimensions
    if a.dimensions() != b.dimensions() {
        panic!("Image dimensions don't match.");
    }
    
    // create an empty buffer for the composite image
    let mut imgbuf: RgbaImage = ImageBuffer::new(a.width(), a.height());
    for ((x, y, p), (_, _, q)) in a.pixels().zip(b.pixels()) {
        imgbuf.put_pixel(
            x,
            y,
            *Pixel::from_slice(
                &p.channels()
                    .iter()
                    .zip(q.channels().iter())
                    .map(|(c0, c1)| c0.checked_add(*c1).unwrap_or(*c0))
                    .collect::<Vec<u8>>(),
            ),
        );
    }
    imgbuf.save("flag.png").unwrap();
}
```

After saving this file, we place the images in the current directory. Let's
compile and run the program.

```sh
cargo run
```

Viewing "flag.png" shows us the flag in pixelated text.

![flag.png](/picoctf-cryptography-challenge-pixelated.png)
