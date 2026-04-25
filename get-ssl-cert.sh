#!/usr/bin/env bash
# Output SSL certificate(s) for a given host (and optional port).
# https://github.com/fardaniqbal
self="$(basename "$0")"
verbose=false

show_help() {
  cat >&2 <<EOF
Usage: $self [OPTION...] HOST[:PORT]
Output SSL certificate(s) for the given HOST and optional PORT in PEM
format.  PORT defaults to 443 if unspecified.

OPTIONs are as follows:

  --verbose
    Enable verbose output.
  --help
    Show this message exit.
EOF
}

# Get comand-line options.
while [ $# -gt 0 ]; do
  arg="$2"
  shift_arg='shift'
  if [ $(expr -- "$1" : '^[^=]\+=.*$') -gt 0 ]; then
    arg="${1#*=}"
    shift_arg=''
  fi
  case "$1" in
    -) break
      ;;
    --) shift; break
      ;;
    --verbose)
      verbose=true
      ;;
    --help)
      show_help
      exit 2
      ;;
    -*)
      printf '%s: unknown option %s.\n' "$self" "$1" >&2
      printf 'Run with --help for usage info.\n' >&2
      exit 2
      ;;
    *) break
      ;;
  esac
  shift
done

if [ $# -ne 1 ]; then
  cat >&2 <<EOF
Must specify exactly one HOST[:PORT] argument.
Run \`$self --help\` for more info.
EOF
  exit 2
fi

# Get connection params from command line arg.
connect="$1"
host="${connect%:*}"
port=443
if [ "x$connect" != "x$host" ]; then
  port="${connect##*:}"
fi
if $verbose; then
  printf 'host="%s"\n' "$host" >&2
  printf 'port="%s"\n' "$port" >&2
fi

tmpfile="$(mktemp -t "$(basename "$0").XXXXXX")" || exit 1
trap "rm -f \"$tmpfile\"" 0 1 2 3 15

# Run openssl s_client to get certificate info.
openssl_output="$(
  echo | \
  openssl s_client -showcerts -servername "$host" -connect "$host:$port" 2>"$tmpfile"
)"
status=$?
if [ $status -ne 0 ]; then
  (printf 'ERROR:\n'; sed 's|^|    |' <"$tmpfile"
   printf 'openssl failed with status %d.\n' $status) >&2
  exit $status
fi

# Parse the info we want out of openssl's output.
printf '%s\n' "$openssl_output" | \
  awk 'BEGIN {p=0}
    /BEGIN CERTIFICATE/ {p=1}
    p==1 {print $0}
    /END CERTIFICATE/ {p=0}'
