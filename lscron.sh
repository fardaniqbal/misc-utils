#!/bin/sh
# List all cron jobs on the system.
users="$(cat /etc/passwd; getent passwd 2>/dev/null)"
users="$(printf '%s\n' "$users" | cut -f1 -d: | sort | uniq)"
found_jobs=false
status=0

for u in $(printf '%s\n' "$users"); do
  jobs="$(sudo crontab -u "$u" -l 2>/dev/null)"
  s=$?
  [ -z "$jobs" ] && continue
  found_jobs=true
  printf '%s:\n' "$u"
  printf '%s\n' "$jobs" | sed 's/^/    /'
  [ $status -eq 0 ] && status=$s
done

$found_jobs || printf 'no cron jobs found\n' >&2
exit $status
