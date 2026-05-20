#!/usr/bin/env bash
# Test SSH logins into each host listed in ~/.ssh/config.
ssh_config_file="$HOME/.ssh/config"

# Parse ssh config from stdin and store each host block H in these globals:
# - ssh_hosts[H]   : hostname to connect to
# - ssh_aliases[H] : space-seperated list of aliases for ssh_hosts[H]
# - ssh_ports[H]   : port for ssh_hosts[H]
# - ssh_users[H]   : username for ssh_hosts[H]
ssh_parse_config() {
  # Global outputs.
  ssh_hosts=()
  ssh_aliases=()
  ssh_ports=()
  ssh_users=()

  # Read ssh config, strip comments, leading/trailing spaces, empty lines.
  local conf="$(sed -E -e 's/#.*$//' -e $'s/^[ \t]*//' -e $'s/[ \t]*$//' |
    grep -v '^$')"

  # Given argument-to-exclude $1, return remaining arguments that _do not_
  # match $1 seperated by spaces.
  ssh_filter_out_() {
    local exclude="$1"; shift
    local res="$(while read i; do
      [ "$i" = "$exclude" ] || printf ' %s' "$i"
    done <<< "$(sed -E $'s#[ \t]+#\\n#g' <<< "$*")")"
    printf '%s\n' "${res## }"
  }
  local host= alias= port= user=

  while read i; do
    cmd="$(  (sed -E $'s/^([^ \t]+).*$/\\1/' | tr [A-Z] [a-z]) <<< "$i" )"
    args="$( (sed -E $'s/^[^ \t]+[ \t]+(.*)$/\\1/') <<< "$i" )"
    case "$cmd" in
      host)
        if [ -n "$host" ]; then
          ssh_hosts+=( "$host" )
          ssh_aliases+=( "$(ssh_filter_out_ "$host" "$alias")" )
          ssh_ports+=( "$port" )
          ssh_users+=( "$user" )
        fi
        host="$args"
        alias=""
        port=""
        user=""
        ;;
      hostname)
        alias="$host"
        host="$args"
        ;;
      port)
        port="$args"
        ;;
      user)
        user="$args"
        ;;
      # Add in other fields as needed.
      *) ;;
    esac
  done <<< "$conf"

  # Finish the final 'host' block.
  if [ -n "$host" ]; then
    ssh_hosts+=( "$host" )
    ssh_aliases+=( "$(ssh_filter_out_ "$host" "$alias")" )
    ssh_ports+=( "$port" )
    ssh_users+=( "$user" )
  fi
}

ssh_parse_config < "$ssh_config_file"
failed_hosts=''
total_count=0
fail_count=0

# SSH into each host and track which ones fail.
for i in $(seq 0 $((${#ssh_hosts[@]} - 1))); do
  [[ "${ssh_hosts[$i]}" == *[*?]* ]] && continue # skip host with wildcards

  total_count=$(($total_count + 1))
  host_ui="${ssh_hosts[$i]}"
  [ -n "${ssh_aliases[$i]}" ] &&
    host_ui="$host_ui ($(sed 's, , / ,g' <<< "${ssh_aliases[$i]}"))"
  printf '%s\n' "------- checking $host_ui -------"
  out="$(ssh -T -oBatchMode=yes -oConnectTimeout=10 -oLogLevel=ERROR \
    "${ssh_hosts[$i]}" 2>&1 <<< "exit 0")"
  if [ $? -eq 0 ]; then
    printf '%s: OK\n' "$host_ui"
  else
    fail_count=$(($fail_count + 1))
    failed_hosts="$(printf '%s\n%s' "$failed_hosts" "$host_ui")"
    printf 'ERROR: connection to %s FAILED:\n' "$host_ui"
    printf '%s\n\n' "$out" | sed 's/^/  /g'
  fi
done

# Show summary of results.
printf '\n------------------------\n'
if [ $fail_count -eq 0 ]; then
  printf 'successfully connected to all %d hosts\n' "$total_count"
else
  printf 'FAILED to connect to %d of %d hosts:\n' "$fail_count" "$total_count"
  printf '%s\n' "$failed_hosts" | sed -E -e '/^ *$/d' -e 's/^/- /'
fi
[ $fail_count -eq 0 ]
