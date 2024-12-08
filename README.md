`cwd` is a tiny shell script that provides a single Common Working Directory
(CWD) for terminals, text editors, and the like.

It should be simple to integrate into a number of applications (precmd hooks,
shell aliases...).

# Setup

## Installation
Run `make` to install `cwd`.

## Terminals
The following command will start a `foot` terminal in the CWD:
``` sh
foot --working-directory="$(cwd -r)"
```
For maximum convenience, bind this to a keyboard shortcut.

## Bash
Add to your `.bashrc`:
``` bash
PROMPT_COMMAND="${PROMPT_COMMAND};cwd -w "'"$PWD"'
```
This will ensure that the CWD is updated every time the prompt is printed,
which will happen every time you finish a command in a shell. The net
result is that the CWD always matches the directory you're working in.
Any terminals spawned with the command supplied in the previous section will
open in this directory.

## Emacs
`cwd.el` provides Emacs integration. See the package Commentary section and 
function docstrings for details.
