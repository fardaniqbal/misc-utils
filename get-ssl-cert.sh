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
  if [ $(expr "$1" : '^[^=]\+=.*$') -gt 0 ]; then
    arg="${1#*=}"
    shift_arg=''
  fi
  case "$1" in
    --) shift; break
      ;;
    --verbose)
      verbose=true
      ;;
    --help)
      show_help
      exit 2
      ;;
    *) break
      ;;
  esac
  shift
done

if [ $# -eq 0 ]; then
  cat >&2 <<EOF
Missing HOST[:PORT] argument.
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

# Run openssl s_client to get certificate info.
openssl_output="$(
  echo | \
  openssl s_client -showcerts -servername "$host" -connect "$host:$port" 2>/dev/null
)"
status=$?
if [ $status -ne 0 ]; then
  printf 'openssl failed with status %d.\n' $status
  exit $status
fi

# Parse the info we want out of openssl's output.
printf '%s\n' "$openssl_output" | \
  awk 'BEGIN {p=0}
    /BEGIN CERTIFICATE/ {p=1}
    p==1 {print $0}
    /END CERTIFICATE/ {p=0}'
