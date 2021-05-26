#!/bin/sh
valid_cmds="status stat st update up proplist plist pl"

if  (expr x"$1" : x'-') >/dev/null ||
  ! (expr "$1" : "$(echo $valid_cmds | sed 's, ,$\\|,g')\$") >/dev/null; then
  echo "Usage: $(basename "$0") SVN-COMMAND [SVN-ARG...]" >&2
  echo "Valid SVN-COMMANDs are: $valid_cmds" >&2
  exit 1
fi

# Move up until we're outside of any versioned directories.
while [ -d .svn ]; do cd ..; done

# Find all top-level versioned directories contained in current directory.
find . -maxdepth 8 -name '.svn' | sed 's,/\.svn$,,' | sort |
while read dir; do
  prefix="$(expr substr + "$dir" 1 \( length + "$prev_dir" \))"
  [ -z "$prev_dir" ] || [ "$prev_dir" != "$prefix" ] || continue
  prev_dir="$dir"
  echo "$dir" # $dir is versioned _and_ top-level
done |

# Go into each of the top-level directories we just found and run svn.
while read dir; do
  saved_pwd="$(pwd)"
  cd "$dir"
  output="$(svn "$@" 2>&1)"
  if [ -n "$output" ]; then
    echo "$dir:" | sed 's,^\./,,'
    echo "$output" | sed 's,^\(.*\)$,  \1,'
  fi
  cd "$saved_pwd"
done
