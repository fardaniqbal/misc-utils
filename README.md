Miscellaneous command line utilities I find myself using frequently.  Mostly
just convenience wrappers around common Unix utilities.

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
