#!/bin/sh
# Usage: copy (or symlink) this file into the dir containing your dotfile
# repos.  E.g., if you have ~/dotfiles/dotbashrc/, ~/dotfiles/dotvimrc/,
# etc, then symlink this file to ~/dotfiles/sync-dotfiles.sh.  Run with
# command line argument "--help" for more info.
cd "$(dirname "$0")"
self=$(basename "$0")

# Colorize output if stdout/stderr is a terminal.
[ -t 1 ] && [ -t 2 ] && stdout_is_tty=true || stdout_is_tty=false
$stdout_is_tty && txtred=$(tput setaf 1)    || txtred=
$stdout_is_tty && txtgrn=$(tput setaf 2)    || txtgrn=
$stdout_is_tty && txtemph=$(tput setaf 13)  || txtemph=
$stdout_is_tty && txtrst=$(tput sgr0)       || txtrst=
$stdout_is_tty && gitcolor='-c color.ui=always' || gitcolor=
die() { printf "\n$txtred%s: %s$txtrst\n" "$self" "$*"; exit 1; }

# Try to be helpful if we find bad command line args.
if [ $# -gt 0 ]; then
  echo "Sync the following local repos with their remotes on GitHub:" 1>&2
  for repo in *; do
    [ -d "$repo/.git" ] && echo "  $PWD/$repo" 1>&2
  done
  exit 1
fi

# Update the repo in $(pwd) and return 0 if successful.
sync_repo() {
  repo=$(basename "$(pwd)")
  printf "${txtemph}%-60s${txtrst}" "$repo: updating..."

  # Error out if this repo has uncommitted changes or is ahead of remote.
  repo_status=$(git status --porcelain -b 2>&1)
  if [ "$(echo "$repo_status" | wc -l)" -ne 1 ] ||
     [ -n "$(echo "$repo_status" | grep '\[ahead[ \t][ \t]*[0-9][0-9]*\]')" ]
     # used to be just `grep -E '\[ahead\s+\d+\]'` but that breaks on SunOS
  then
    printf "[${txtred}FAIL${txtrst}]\n"
    printf "  ${txtred}%s has local changes${txtrst}\n" "$repo"
    return 1
  fi
  # Otherwise attempt to update.
  git_output=$(git $gitcolor pull --recurse-submodules=on-demand 2>&1 &&
               git $gitcolor submodule sync --recursive 2>&1 >/dev/null &&
               git $gitcolor submodule update --init --recursive 2>&1 &&
               git $gitcolor submodule foreach 'git pull' 2>&1)
  return_code=$?
  if [ $return_code -ne 0 ]; then
    printf "[${txtred}FAIL${txtrst}]${txtred}\n"
  else
    printf "  [${txtgrn}OK${txtrst}]\n"
  fi
  printf "%s${txtrst}\n" "$git_output" | sed 's/^/  /' # indent output
  return $return_code
}

# Go through each repo and try to update.
repo_cnt=0
success_cnt=0
for repo in *; do
  [ -d "$repo/.git" ] || continue
  saved_dir=$PWD  # many shells don't have pushd/popd, so save current dir
  cd "$repo" || die "couldn't enter $repo"
  repo_cnt=$(($repo_cnt + 1))
  sync_repo && success_cnt=$(($success_cnt + 1))
  cd "$saved_dir" || die "couldn't leave $repo"
done

# Make it obvious if anything failed.
if [ $success_cnt -eq $repo_cnt ]; then
  printf "${txtgrn}All %d repos are up to date!$txtrst\n" $repo_cnt
else
  printf "${txtred}%d of %d repos failed to update!$txtrst\n" \
    $(($repo_cnt - $success_cnt)) $repo_cnt
fi
exit $(($success_cnt != $repo_cnt))
