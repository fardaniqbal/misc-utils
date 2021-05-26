#!/bin/sh
PROGCMD="$(basename "$0")"
die() { echo "$PROGCMD: $(echo "$@" | sed 's/^[^:]*:\s*//')" 1>&2; exit 1; }

if (for i in "$@"; do
    echo "$i" | grep -E '^(-h|-help|--help)$' && exit 0
    done; exit 1) >/dev/null; then
  cat <<EOF
Usage: $PROGCMD [PATH]
Write PATH's svn information to standard output.  This command is
equivalent to passing PATH's repository URL as the argument to
\`svn info'.  PATH defaults to \`.' if unspecified.
EOF
  exit 0
fi

[ "$1" = '' ] && path='.' || path="$1"

svnout="$(svn info "$path" 2>&1)" || die "$svnout"
url="$(echo "$svnout" | grep '^URL:' | sed 's/^URL:\s*//')"
svnout="$(svn info "$url" 2>&1)" || die "$svnout"
echo "$svnout"
