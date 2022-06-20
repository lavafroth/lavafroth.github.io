---
title: "Java Script Kiddie 2"
tags:
- CTF
- Image Reconstruction
- Javascript
- Reverse Engineering
- PicoCTF
- Web
date: 2023-03-03T09:47:54+05:30
draft: false
---

## The challenge

This is a web challenge involving javascript, meaning most of the solution is
going to be client side. We are asked to visit the [challenge
page](http://jupiter.challenges.picoctf.org:42899/).

From here, we can view the source code of the page.

```html
<html>
	<head>    
		<script src="jquery-3.3.1.min.js"></script>
		<script>
			var bytes = [];
			$.get("bytes", function(resp) {
				bytes = Array.from(resp.split(" "), x => Number(x));
			});

			function assemble_png(u_in){
				var LEN = 16;
				var key = "00000000000000000000000000000000";
				var shifter;
				if(u_in.length == key.length){
					key = u_in;
				}
				var result = [];
				for(var i = 0; i < LEN; i++){
					shifter = Number(key.slice((i*2),(i*2)+1));
					for(var j = 0; j < (bytes.length / LEN); j ++){
						result[(j * LEN) + i] = bytes[(((j + shifter) * LEN) % bytes.length) + i]
					}
				}
				while(result[result.length-1] == 0){
					result = result.slice(0,result.length-1);
				}
				document.getElementById("Area").src = "data:image/png;base64," + btoa(String.fromCharCode.apply(null, new Uint8Array(result)));
				return false;
			}
		</script>
	</head>
	<body>

		<center>
			<form action="#" onsubmit="assemble_png(document.getElementById('user_in').value)">
				<input type="text" id="user_in">
				<input type="submit" value="Submit">
			</form>
			<img id="Area" src=""/>
		</center>

	</body>
</html>
```

Let's break it down. We are going to begin with the contents in the script
tags. First, the script fetches a blob of whitespace separated numbers into the
variable `bytes`.

```js
var bytes = [];
$.get("bytes", function(resp) {
	bytes = Array.from(resp.split(" "), x => Number(x));
});
```

It will be a good idea to download a copy of these bytes for ourselves.

```sh
wget http://jupiter.challenges.picoctf.org:42899/bytes
```

The function `assemble_png` takes a 32 characters long key as an input, as is evident from the length of the variable key and the assignment of `u_in` to key only when their lengths match.

```js
	var LEN = 16;
	var key = "00000000000000000000000000000000";
	var shifter;
	if(u_in.length == key.length){
		key = u_in;
	}
```

The function then iterates over the key to store every other byte into the `shifter`.

```js
shifter = Number(key.slice((i*2),(i*2)+1));
```

The inner loop then fills up 16 contiguous bytes of the `result` array from the index `j * LEN` by a table lookup into the `bytes` array initialized earlier.

```js
for(var j = 0; j < (bytes.length / LEN); j ++) {
	result[(j * LEN) + i] = bytes[(((j + shifter) * LEN) % bytes.length) + i]
}
```

## Solution

Let's write a python script to automate searching for the key. We can narrow down our key space since a PNG file has its header (first set of bytes) as `\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR`.
We will use numpy to broadcast arithmetic operations over all elements of a tensor (rank 1 here, meaning an array). Since the key has one byte from the PNG header and another unknown byte
alternatively, we can begin by using a dummy byte like 'A' for all those spaces.

We then try to generate an image from the resultant byte array and validate it with the python image library (PIL). If the validation succeeds, we can end the search and save the image.

```py
import itertools
from itsdangerous import base64_encode
from PIL import Image, UnidentifiedImageError
import numpy as np
import io

LEN = 16
with open('bytes') as handle:
    blob = np.array([int(x.strip()) for x in handle.read().split(',')])

BLEN = len(blob)
J = BLEN // LEN
crib = b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR"
charset = [set()] * LEN


def is_png(key) -> bool:
    result = bytearray(BLEN)
    for i in range(LEN):
        shifter = ord(key[i * 2])
        for j in range(J):
            result[(j * LEN) + i] = blob[(((j + shifter) * LEN) % BLEN) + i]

    result.rstrip(b'\x00')

    try:
        image = Image.open(io.BytesIO(result))
        image.save(base64_encode(key).decode() + ".png")
    except UnidentifiedImageError:
        return False
    return True


def main():
    # 255 is the maximum value for a u8
    shifter = np.arange(256)
    for i in range(LEN):
        for j in range(J):
            crib_index = (j * LEN) + i
            if crib_index >= len(crib):
                continue
            interp = (((shifter + j) * LEN) % BLEN) + i
            p = shifter[np.in1d(interp, np.where(blob == crib[crib_index])[0])]
            charset[i] = charset[i].union(p)

    for char in itertools.product(*charset):
        key = "A".join(map(chr, char))
        if is_png(key):
            print(key)
            return


if __name__ == "__main__":
    main()
```

Running this script, we get the following image in `B0EGQQFBBkEAQQdBw6BBAUEFQQBBAEEAQQJBAEEIQQU.png`.
![B0EGQQFBBkEAQQdBw6BBAUEFQQBBAEEAQQJBAEEIQQU.png](/B0EGQQFBBkEAQQdBw6BBAUEFQQBBAEEAQQJBAEEIQQU.png)

Since this appears to be a QR code, the only thing left to do is scan the image with a tool like `zbarimg`.

```sh
zbarimg B0EGQQFBBkEAQQdBw6BBAUEFQQBBAEEAQQJBAEEIQQU.png 
```

This yields us the flag.

```
QR-Code:picoCTF{227c2d3465a6a4bcc8a1bc599e34f074}
scanned 1 barcode symbols from 1 images in 0.03 seconds
```
