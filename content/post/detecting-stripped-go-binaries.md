---
title: "Easy grep to detect stripped Go binaries"
date: 2025-06-13T08:39:58+05:30
tags:
  - Go
  - Reverse Engieering
  - TIL
draft: false
---

A couple of days ago when I was reading the [guide to the Go garbage collector](https://tip.golang.org/doc/gc-guide), I came across the following excerpt:

> When all else fails, the Go GC provides a few different specific traces that provide much deeper insights into GC behavior. These traces are always printed directly to STDERR, one line per GC cycle, and are configured through the GODEBUG environment variable that all Go programs recognize.

An environment variable that all Go programs recognize, you say? I had a sneaking suspicion that I could just perform a string search for this term, given all Go programs would need to look for this environment variable definition. This way, we could guess if a binary was written in Go.

I created a program called `hello` to test this out. To make sure the binary is stripped, I compiled it with `go build -ldflags '-w -s'`.

``` sh
grep GODEBUG hello
```

```
grep: hello: binary file matches
```

Sure enough, looks like this does provide a decent heuristic for Go programs! Of course, there's the caveat that another binary can "pretend" to be a Go binary by simply having this string present in it.

We could try this technique with other environment variables like `GOGC`, available in all binaries and `GOMEMLIMIT`, available for Go 1.19 and up.

So if you have a hunch that a binary is written in Go 1.19 and above, try `grep`ping with all the aforementioned variables.

``` sh
grep -P '(GOGC|GOMEMLIMIT|GODEBUG)' hello
```

Ok bye.
