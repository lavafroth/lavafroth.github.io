---
title: "Bash Jail 3"
date: 2022-07-24T12:29:56+05:30
tags:
- Bash
- CTF
- RingZer0
- Sandbox Escape
draft: false
---

# The challenge

Logging into the box we are told that the flag is located at `/home/level3/flag.txt`.

```bash
function check_space {                                                                      
        if [[ $1 == *[bdksc]* ]]                                                            
        then                                                                                
                return 0                                                                    
        fi                                                                                  
                                                                                            
        return 1                                                                            
}                                                                                           
                                                                                            
while :                                                                                     
do                                                                                          
        echo "Your input:"                                                                  
        read input                                                                          
        if check_space "$input"                                                             
        then                                                                                
                echo -e '\033[0;31mRestricted characters has been used\033[0m'              
        else                                                                                
                output=`$input` &>/dev/null                                                 
                echo "Command executed"                                                     
        fi                                                                                  
done 
```

We are also told that this prompt is launched using `./prompt.sh 2>/dev/null`
which means we cannot exfiltrate the flag from `stderr` since it is blocked.

# Inference

This time, the `check_space` function returns a `1` if there are any characters in the input
string among `b`,`d`,`k`,`s` and `c`. If the function returns 1, we get a "restricted characters"
message and no further processing happens.

Once our input passess through the `check_space` function, it is passed in a command
substitution with the `stdout` and `stderr` being redirected yet again to `/dev/null`

```bash
output=`$input` &>/dev/null
```

If we cannot read the flag through `stderr` (file descriptor 2) or through `stdout` (file descriptor 1),
we can resort to redirecting the output to `stdin` (file descriptor 0).

# Solution

We can pass a command that reads and displays the contents of `flag.txt` in an `eval` statement and
redirect the output to `stdin`. However, we need a command that does not have the restricted
characters. One such command would be `tail` which, by default, reads the last 10 lines of a file.

```
eval tail flag.txt >&0 # Redirect to stdin
```

This gives us the flag `FLAG-s9wXyc9WKx1X6N9G68fCR0M78sx09D3j`.
