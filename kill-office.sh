#!/bin/sh
cmdname="$(basename "$0")"
regex='LibreOffice'
psout="$(ps -x | grep -v grep | grep -i "$regex")"
if [ $? -ne 0 ]; then
  echo "$cmdname: can't find any running LibreOffice processes." >&2
  exit 1
fi

# For each LibreOffice process: send a few kills, then kill -9 if needed.
set -e
for pid in $(echo "$psout" | awk '{print $1}'); do
  echo "pid = '$pid'"
  for i in $(seq 1 10); do
    kill "$pid"
    sleep .1
    ps -p "$pid" | grep -i "$regex" >/dev/null || break
  done
  ps -p "$pid" | grep -i "$regex" >/dev/null && kill -9 "$pid"
done
