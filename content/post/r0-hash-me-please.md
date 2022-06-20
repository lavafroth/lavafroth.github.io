---
title: "Hash Me Please"
tags:
- Cryptography
- CTF
- RingZer0
- Web Parsing
date: 2022-08-19T09:57:00+05:30
draft: false
---

In this RingZer0 challenge, we are asked to visit
http://challenges.ringzer0team.com:10013/ and are given 2 seconds to hash the
provided message using the SHA512 algorithm. We must send the response as
[http://challenges.ringzer0team.com:10013/?r=_response_](http://challenges.ringzer0team.com:10013/?r=response)
and to do that, we'll be using some Golang.

Let's declare the URI as a constant.

```go
const uri = "http://challenges.ringzer0team.com:10013/"
```

We fetch the challenge page using the `Get` function from the `http` standard
library, checking for errors along the way.

```go
resp, err := http.Get(uri)
if err != nil {
	log.Fatalln(err)
}
```

We defer closing the response body when the program ends.

```go
defer resp.Body.Close()
```

Next, we are going to use a library called `goquery` to parse the HTML in the body of the response.

```go
doc, err := goquery.NewDocumentFromReader(resp.Body)
if err != nil {
	log.Fatalln(err)
}
```

We will now match a single (`goquery.Single`) _div_ element with the class
"message" and read the text inside it.

```go
message := doc.FindMatcher(goquery.Single(".message")).Text()
```

To grab the line which has the actual message, we split the lines and take the
line at index 2 (which is line 3, remember computers begin indexing from 0).

```go
line := strings.Split(message, "\n")[2]
```

Just to be on the safe side, let's also trim out any leading or trailing tabs and whitespaces.

```go
line = strings.Trim(line, " \t")
```

We can now find the SHA512 hash of the line using the standard `crypto/sha512`
library. For this we pass a byte slice representation of the string to the `Sum512` function.

```go
hash := sha512.Sum512([]byte(line))
```

To construct the new URI, we can use format strings. Here `%s` represents the
original URI, `?r=` is the parameter we are asked to supply and `%x` represents
the hex digest of the hash.

```go
flagUri := fmt.Sprintf("%s?r=%x", uri, hash)
```

Assuming that our program is quick enough to compute the hash withing 2 seconds
😅, we will fetch the `flagUri`. As usual, we defer closing the response body
when the program ends.

```go
flagPage, err := http.Get(flagUri)
if err != nil {
	log.Fatalln(err)
}
defer flagPage.Body.Close()
```

---

At this point, you could print the response body text which is what I did for
the first time.

This might be a time to pause and ponder, perhaps try out the aforementioned
technique.

For the sake of completeness, I will write the rest of the program so that
it only prints the flag when run.

---

Let's parse the response body using `goquery` again.

```go
doc, err = goquery.NewDocumentFromReader(flagPage.Body)
if err != nil {
	log.Fatalln(err)
}
```

The flag is located in the _div_ with the class "alert-info".

```go
flag := doc.FindMatcher(goquery.Single(".alert-info")).Text()
```

Finally, we print out the flag.

```go
fmt.Println(flag)
```

Here's the code in all it's glory.

```go
package main

import (
	"crypto/sha512"
	"fmt"
	"github.com/PuerkitoBio/goquery"
	"log"
	"net/http"
	"strings"
)

const uri = "http://challenges.ringzer0team.com:10013/"

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

	message := doc.FindMatcher(goquery.Single(".message")).Text()
	line := strings.Split(message, "\n")[2]
	line = strings.Trim(line, " \t")
	hash := sha512.Sum512([]byte(line))

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
