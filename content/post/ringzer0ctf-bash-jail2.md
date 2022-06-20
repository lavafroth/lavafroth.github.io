---
title: "Bash Jail 2"
date: 2022-07-24T12:28:56+05:30
tags:
- Bash
- CTF
- RingZer0
- Sandbox Escape
draft: false
---

# The challenge
Logging into the box we are told that the flag is located at `/home/level2/flag.txt`

### Challenge bash code
```bash
function check_space {
        if [[ $1 == *[bdks';''&'' ']* ]]
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
         output="echo Your command is: $input"
         eval $output
        fi
done 
```

# Inference
This time, the `check_space` function returns a `1` if there are any characters in the input
string among `b`,`d`,`k`,`s`, a semicolon, an ampersand and a whitespace. If the function does
return 1, we get a "restricted characters" message and no further processing happens.

However, if our input passes the check, the program echoes `"Your command is: $input"`.
We can use a simple command like `cat flag.txt` in backticks (command substitution) to execute
it in the `eval` statement. However, whitespaces are not allowed. To bypass this, we can use a
tab in place of the whitespace.

# Solution
We give the script the following input:
```
`cat	flag.txt`
```

Which gets evaluated and prints the flag.
```
Your command is: FLAG-a78i8TFD60z3825292rJ9JK12gIyVI5P
```
