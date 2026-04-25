#!/usr/bin/env bash
# Replace spaces with dashes in all filenames under the directories given
# on the command line, recursing into each directory.
#
# TODO:
# - Add `--help` documentation.
# - Update symlinks that point to filenames with spaces.
# - MAYBE: add sed-style `-e s/REGEX/REPLACEMENT/` option to make this a
#   generic mass recursive file-renaming tool.
# - Add `--verbose` option to print every `mv` command before executing it.
# - Add `--dry-run` option.

for topdir in "$@"; do
  # Be careful about the order in which we rename things.  Must rename the
  # contents of a directory before renaming the directory itself.
  find "$topdir" | sort -r | uniq | while read i; do
    [ -e "$i" ] || continue
    dir="$(dirname "$i")"
    orig="$(basename "$i")"
    new="$(printf '%s' "$orig" | sed -E -e 's| +|-|g' -e 's|---+|--|g')"
    [ "$orig" == "$new" ] && continue
    printf 'mv "%s" "%s"\n' "$dir/$orig" "$dir/$new"
    mv "$dir/$orig" "$dir/$new"
  done
done
