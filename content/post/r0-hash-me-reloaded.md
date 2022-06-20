---
title: "RingZer0 CTF Hash Me Reloaded"
date: 2022-08-19T09:57:15+05:30
tags:
- Cryptography
- CTF
- RingZer0
- Web Parsing
draft: false
---

In this RingZer0 challenge, we are to visit the challenge url where we are
given 2 seconds to SHA512 hash the message represented by the binary provided
string. We must send the response with the request parameter `r`. Let's write
a go program to do that.

First let's declare the url as a constant.

```go
const uri = "http://challenges.ringzer0team.com:10014/"
```

We fetch the challenge page and defer closing its body once the program ends.

```go
resp, err := http.Get(uri)
if err != nil {
	log.Fatalln(err)
}
defer resp.Body.Close()
```

We will use the `goquery` library to parse the response HTML.

```go
doc, err := goquery.NewDocumentFromReader(resp.Body)
if err != nil {
	log.Fatalln(err)
}
```

We find the single (`goquery.Single`) element with the "message" class and get
the text contents of the element.

```go
text := doc.FindMatcher(goquery.Single(".message")).Text()
```

To grab the line which has the actual binary string, we split the lines and
take the third (which is index 2, remember computers begin indexing from 0).

```go
binary := strings.Split(text, "\n")[2]
```

Let's also trim any spaces and tabs as a precaution.

```go
binary = strings.Trim(binary, " \t")
```

We declare a buffer where we can store the decoded contents.

```go
var buf []byte
```

Since each character in the string represents a bit, 8 of them represent a byte.
We will loop with a sliding window of 8 characters, parse them as an integer into a byte
and append them to the buffer.

```go
for i := 0; i < len(binary)/8; i++ {
	// decode sequence of 8 bits with base 2
	if b, err := strconv.ParseInt(binary[i*8:8+i*8], 2, 8); err != nil {
		log.Fatal(err)
	} else {
		buf = append(buf, byte(b))
	}
}
```

Let's find the SHA512 hash of the decoded string using the `Sum512` function
from the standard `crypto/sha512` library.

```go
hash := sha512.Sum512(buf)
```

We use format strings to construct the new URI, we can use format strings. Here
`%s` is a placeholder for the constant URI, `?r=` is the parameter we are
supply the answer to and `%x` represents the hex digest of the hash.

```go
flagUri := fmt.Sprintf("%s?r=%x", uri, hash)
```

Once we have this URI, we can send this through to get a response. As done
previously, we defer closing the response body once the program ends.

```go
flagPage, err := http.Get(flagUri)
if err != nil {
	log.Fatalln(err)
}
defer flagPage.Body.Close()
```

---

Pause and ponder to make sure you have understood the code so far.

Now you could print the response body as I did the first time solving this.
However, as with any other writeup, I will write the rest of the program so
that it only prints the flag when run.

---

Let’s parse the response body using `goquery` again.

```go
doc, err = goquery.NewDocumentFromReader(flagPage.Body)
if err != nil {
	log.Fatalln(err)
}
```

The flag is located in the _div_ element with the class “alert-info”.

```go
flag := doc.FindMatcher(goquery.Single(".alert-info")).Text()
```

Finally, we print out the flag.

```go
fmt.Println(flag)
```

The final code becomes the following:

```go
package main

import (
	"crypto/sha512"
	"fmt"
	"github.com/PuerkitoBio/goquery"
	"log"
	"net/http"
	"strconv"
	"strings"
)

const uri = "http://challenges.ringzer0team.com:10014/"

func main() {
	resp, err := http.Get(uri)
	if err != nil {
		log.Fatalln(err)
	}
	defer resp.Body.Close()
	doc, err := goquery.NewDocumentFromReader(resp.Body)
	if err != nil {
		log.Fatalln(err)
	}
	text := doc.FindMatcher(goquery.Single(".message")).Text()
	binary := strings.Split(text, "\n")[2]
	binary = strings.Trim(binary, " \t")
	var buf []byte
	for i := 0; i < len(binary)/8; i++ {
		// decode sequence of 8 bits with base 2
		if b, err := strconv.ParseInt(binary[i*8:8+i*8], 2, 8); err != nil {
			log.Fatal(err)
		} else {
			buf = append(buf, byte(b))
		}
	}
	hash := sha512.Sum512(buf)
	flagUri := fmt.Sprintf("%s?r=%x", uri, hash)
	flagPage, err := http.Get(flagUri)
	if err != nil {
		log.Fatalln(err)
	}
	defer flagPage.Body.Close()
	doc, err = goquery.NewDocumentFromReader(flagPage.Body)
	if err != nil {
		log.Fatalln(err)
	}
	flag := doc.FindMatcher(goquery.Single(".alert-info")).Text()
	fmt.Println(flag)
}
```
