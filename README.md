Miscellaneous command line utilities I find myself using frequently.
Mostly just convenience wrappers around common Unix utilities.

* `check-logins.sh` - test SSH logins into hosts listed in ~/.ssh/config.
* `get-ssl-cert.sh` - get a given server's SSL certificates.
* `get-zscaler-root-ca.ps1` - get Zscaler Root CA from Windows' trusted
  root store.  No Administrator privileges required.
* `get-zscaler-root-ca.sh` - same as above, but for Git Bash/WSL.
* `kill-office.sh` - kill all currently-running LibreOffice processes (yes,
  I wrote this _specifically_ for LibreOffice because it freezes _that_
  frequently on Mac OS.)
* `lscron.sh` - list all cron jobs for all users on the system.
* `mkbackup.sh` - backup files with automatic timestamp in backup filename.
* `svn-diff.sh` - like `svn diff`, but opens its output in a user-specified
  viewer (vim by default.)
* `svn-info.sh` - like `svn info`, but you can specify a path on the local
  filesystem instead of its repository URL.
* `svn-shotgun.sh` - run an svn command on multiple auto-detected
  directories.
* `qdiff` - like `diff -u`, but with colors.  Works by running diff,
  writing its output to a temporary file, then opening that file with vim
  for colored syntax hilighting.
* `qdu` - like recursive `du`, but lists just the immediate children of the
  given directory next to their respective sizes.
* `rmspc.sh` - replace spaces with dashes in all filenames under the
  directories given on the command line, recursing into each directory.
* `run-in-bit-bash.sh` - automatically run scripts in Git Bash, even if
  invoking from WSL or another Windows Bash setup (MSYS2, Cygwin, etc.)
* `sync-dotfiles.sh` - keep your local dotfile repos up-to-date with their
  remotes on GitHub.
* `termcolors.sh` - print a table of terminal color codes.
* `vim-git-bash.cmd` - double-click files in Windows's GUI to open them in
  Git Bash's Vim.  Trivially modifiable to run any other Git Bash program
  (nvim, etc) as a handler for double-clicked files.
* `wsudo.cmd` - run Windows programs with elevated privileges.  A bit janky
  at the moment.  (TODO: make this run the given program/command in the
  same terminal window rather than opening a new one, like UNIX `sudo`.)
