#!/usr/bin/env bash
# Wrap the logic in a mkbackup() function so it's usable in other scripts.
# Run with --help for usage info.
#
# Part of https://github.com/fardaniqbal/misc-utils

# Usage: mkbackup [OPTIONS...] [--] FILE-TO-BACKUP
#
# Create a backup of file FILE-TO-BACKUP, and print the backup file's name
# to stdout.  By default, the backup filename will be of the form
# "FILE-TO-BACKUP-<YYYY-MM-DD>-<SEQUENCE>.bak", where <YYYY-MM-DD> is the
# modification timestamp of FILE-TO-BACKUP, and <SEQUENCE> is the first
# number from 0000 to 9999 that's not already taken.  The backup file's
# generated name may be tweaked with the given OPTIONS.
#
# OPTIONS are as follows:
#
# --dir=BACKUP-DIR
#   Use BACKUP-DIR as the directory in which to place the backup.  (By
#   default, the backup file goes in the same directory as FILE-TO-BACKUP.)
# --name-only
#   Only generate the backup file's name.  Don't actually make the backup.
# --timestyle=now|mod
#   If "now", use current time as the timestamp in backup filename.  If
#   "mod" (default), use FILE-TO-BACKUP's modification timestamp as the
#   backup filename's timestamp.
# --version
#   Print version number to stdout and exit.
# -h, -help, --help
#   Print this message to stdout and exit.
#
# BUGS: there is an inherent race condition where, e.g., the generated
# backup filename is "myfile-2025-02-01-0012.bak", but ANOTHER file with
# that same name takes its spot before the backup file gets created.  Keep
# this in mind if you use this in any security-sensitive situations.
mkbackup() {
  local MKBACKUP_VERSION="1.0.0"
  local name_only=false
  local timestyle=mod
  local backup_dir=

  # Get options/arguments.
  while [ $# -gt 0 ]; do
    arg="$2"
    shift_arg='shift'
    if [ $(expr -- "$1" : '^[^=]\+=.*$') -gt 0 ]; then
      arg="${1#*=}"
      shift_arg=''
    fi
    case "$1" in
      -) break;;
      --) shift; break;;
      --name-only) name_only=true;;
      --timestyle|--timestyle=*)
        if [ "$arg" != "now" ] && [ "$arg" != "mod" ]; then
          printf 'mkbackup: --timestyle must be "now" or "mod".\n' >&2
          return 2
        fi
        timestyle="$arg"
        $shift_arg
        ;;
      --dir|--dir=*)
        if [ -z "$arg" ]; then
          printf 'mkbackup: --dir must be a non-empty string.\n' >&2
          return 2
        fi
        backup_dir="$arg"
        [ "$backup_dir" == "~" ] && backup_dir="$HOME"
        $shift_arg
        ;;
      -h|-help|--help)
        scrape_doc 'mkbackup' < "${BASH_SOURCE[0]}"
        return 0
        ;;
      --version)
        printf 'mkbackup %s\n' "$MKBACKUP_VERSION"
        exit 0
        ;;
      -*)
        printf 'mkbackup: unknown option %s.\n' "$1" >&2
        return 2
        ;;
      *) break;;
    esac
    shift
  done

  if [ $# -ne 1 ]; then
    printf 'mkbackup: must specify exactly ONE file to back up.\n' >&2
    return 2
  fi
  local file_to_backup="$1"
  if ! $name_only && ! [ -r "$file_to_backup" ]; then
    printf 'mkbackup: %s is not a readable file.\n' "$file_to_backup" >&2
    return 1
  fi

  # Get timestamp.
  local stamp="$(date '+%Y-%m-%d')" || return 1
  if [ -e "$file_to_backup" ] && [ "$timestyle" == "mod" ]; then
    stamp="$(date -r "$file_to_backup" '+%Y-%m-%d')" || return 1
  fi

  # Get backup directory.
  if [ -z "$backup_dir" ]; then
    backup_dir="$(dirname -- "$file_to_backup")" || return 1
  elif ! $name_only; then
    mkdir -p -- "$backup_dir" || return 1
  fi

  # Generate backup filename.
  local backup='' base="$(basename "$file_to_backup")"
  for i in $(seq 0 999999); do
    backup="$(printf '%s-%04d.bak' "$backup_dir/$base-$stamp" $i)"
    [ -f "$backup" ] || break
  done

  # Just in case...
  if [ -f "$backup" ]; then
    printf 'mkbackup: too many backups of %s.\n' "$file_to_backup" >&2
    rmdir -- "$backup_dir" >/dev/null 2>&1
    return 127
  fi

  # Make the backup unless caller gave --name-only.
  if ! $name_only && ! (cp -ra -- "$file_to_backup" "$backup"); then
    printf 'mkbackup: failed to backup %s.\n' "$file_to_backup" >&2
    rmdir -- "$backup_dir" >/dev/null 2>&1
    return 1
  fi
  printf '%s\n' "$backup"
}

# Return comment preceeding function $1 scraped out of bash script from
# stdin.  Intended use is to auto-generate --help docs from comments.
# Deliberately short-n-sweet so it's easily copy/pastable to other scripts.
scrape_doc() {
  if [ $# -ne 1 ]; then printf 'scrape_doc: bad args\n' >&2; return 1; fi
  awk 'BEGIN {p=0; doc=""; str=""}
    p==0 && /^[ \t]*#/ {p=1; doc=""}
    p==1 && /^[ \t]*([^#].*|)$/ {p=0; doc=str; str=""}
    p==1 {str=str"\n"$0}
    /^[ \t]*'"$1"'[ \t]*\([ \t]*\)[ \t]*{?[ \t]*$/ {print doc; exit}
  ' | sed -E 's/^# ?//' | tail -n+2
}

mkbackup "$@"
