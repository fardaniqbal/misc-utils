Miscellaneous command line utilities I find myself using frequently.
Mostly just convenience wrappers around common Unix utilities.

* `get-ssl-cert.sh` - get a given server's SSL certificates.
* `kill-office.sh` - kill all currently-running LibreOffice processes (yes,
  I wrote this _specifically_ for LibreOffice because it freezes _that_
  frequently on Mac OS.)
* `lscron.sh` - list all cron jobs for all users on the system.
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
* `sync-dotfiles.sh` - keep your local dotfile repos up-to-date with their
  remotes on GitHub.
* `termcolors.sh` - print a table of terminal color codes.
* `vim-git-bash.cmd` - double-click files in Windows's GUI to open them in
  Git Bash's Vim.  Trivially modifiable to run any other Git Bash program
  (nvim, etc) as a handler for double-clicked files.
