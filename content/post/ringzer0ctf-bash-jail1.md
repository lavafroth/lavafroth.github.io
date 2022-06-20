---
title: "Bash Jail 1"
tags:
- Bash
- CTF
- RingZer0
- Sandbox Escape
date: 2022-07-24T12:27:56+05:30
draft: false
---

# The challenge

Upon SSHing into the box, we are told that the flag is located at `/home/level1/flag.txt`

Challenge bash code:
```bash
while :
do
        echo "Your input:"
        read input
        output=`$input`
done 
```

# Inference and experimenation

The script is reading an input, executes it and then stores it in the
`output` variable without ever displaying the output to the console.

I tried a dummy command to see if I could see its `stderr` since command
substitution (backticks) only capture the `stdout`.

```
echo hi 1>&2
```

Unfortunately that did not work, we did not have the "hi" blurted out in
the stderr. So, I resorted to another route.

# Solution

Remember how, if we ever tweak our bashrc file, we need to source it
to bring it to effect? Well, we can also, source the flag.txt file
and the script should error out with the contents of the file.

```bash
source flag.txt
flag.txt: line 1: FLAG-U96l4k6m72a051GgE5EN0rA85499172K: command not found
```

There we have our flag.
