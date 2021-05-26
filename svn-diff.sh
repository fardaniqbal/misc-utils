#!/bin/sh
PROGCMD="$(basename "$0")"
PROGNAME="$(echo $PROGCMD | sed 's/\.[^\.]*$//')"
die_() { echo "$PROGCMD: $(echo "$@" | sed 's/^[^:]*:\s*//')" 1>&2; exit 1; }
die() { rm -f "$outfile"; die_ "$@"; }

if (for i in "$@"; do
    echo "$i" | grep -E '^(-h|-help|--help)$' && exit 0
    done; exit 1) >/dev/null; then
  cat <<EOF
Usage: $PROGCMD [ARGS...]
Run \`svn diff ARGS' and view its output using the program indicated
by environment variable \$SVN_VIEWER.  Default to \`vim' or \`vi' if
\$SVN_VIEWER is not set.
EOF
  exit 0
fi

# If stdout isn't a terminal then just run `svn diff' raw.
tty -s <&1 || exec svn diff "$@"

# Set default viewer if none was specified.
for i in "$SVN_VIEWER" vim vi; do
  if (which "$(echo "$i" | sed 's,[ \t].*,,')" >/dev/null 2>&1); then
    viewer="$i"
    break
  fi
done
[ -n "$viewer" ] || die_ ":\$SVN_VIEWER not found; try \`$PROGCMD --help'"

# Run `svn diff', write its output to a temp file, then run the viewer.
outfile="$(mktemp "/tmp/${PROGNAME}-XXXXXX" 2>&1)"
[ $? -eq 0 ] || die_ ":could not create temporary file: $outfile"
svnout="$(svn diff "$@" 2>&1)" || die "$svnout"
echo "$svnout" > "$outfile" || die ":i/o error"
chmod 400 "$outfile"
$viewer "$outfile"
rm -f "$outfile"
