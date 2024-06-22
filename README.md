`cwd` is a tiny shell script that provides a single Common Working Directory
for terminals, text editors, and the like.

It should be simple to integrate into a number of applications (precmd hooks,
shell aliases...).

# Setup

## Installation
Run `make` to install `cwd`.

## Emacs
`cwd.el` provides Emacs integration.

## Bash
Add to your `.bashrc`:
``` bash
PROMPT_COMMAND="${PROMPT_COMMAND};cwd -w "'$PWD'
```
