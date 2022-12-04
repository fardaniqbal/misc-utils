#!/bin/sh
# Latest version of this is on https://github.com/fardaniqbal/misc-utils
#
# Print a table of terminal color codes.  Inspired by the script on [TLDP's
# Bash Prompt HOWTO](https://tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html),
# but this one also distinguishes between brights and bolds.  (The original
# script assumed bold text would use its color's bright variant, which (1)
# isn't always true depending on your terminal's settings, and (2) doesn't
# show you bright-colored backgrounds.)
printf '\033[0m'

# Print table header.
printf '%8s' ''
for bg in $(seq 0 7); do    # for each background color
  printf '  %-3s' "$(($bg + 40))"   # normal background
  printf  ' %-3s' "$(($bg + 100))"  # bright background
done
echo

printrow() {
  printf '%4s\033[%sm Aa \033[0m' "$1" "$1"
  for bg in $(seq 0 7); do  # for each background color
    printf ' \033[%sm Aa'         "$1;$(($bg + 40))"  # normal background
    printf ' \033[%sm Aa \033[0m' "$1;$(($bg + 100))" # bright background
  done
  echo
}

# Handle first two rows specially for default foreground color.
printrow 0  # normal weight
printrow 1  # bold weight

# Don't need special treatment for all other colors.
for fg in $(seq 0 7); do    # for each foreground color
  for brt in 30 90; do      # for normal and bright color variant
    for bld in '' '1;'; do  # for normal and bold weights
      printrow "$bld$(($fg + $brt))"
    done
  done
done
