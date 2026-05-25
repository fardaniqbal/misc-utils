#!/usr/bin/env bash
. "$(cd "$(dirname -- "$0")"; pwd)/run-in-git-bash" "$0" "$@"

printf 'this is a test.\n'
printf 'self                : "%s"\n' "$0"
printf 'which bash          : "%s"\n' "$(which bash)"
printf 'cygpath -wl bash    : "%s"\n' "$(cygpath -wl "$(which bash)")"
