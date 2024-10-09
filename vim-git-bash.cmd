@echo off
setlocal EnableExtensions
rem Run Git Bash's Vim.  If running this from the GUI shell, run Vim in a
rem new terminal using Windows's default terminal app.  Otherwise run Vim
rem in the current terminal.
rem
rem The intended use is to set this script as the GUI shell's default
rem handler when double-clicking text files (or xml, markdown, etc).  In
rem Windows Explorer, right-click on a file -> Open with -> Choose another
rem app, then select this script.  Select "Always use this app to open .XXX
rem files" if you want.
rem
rem NOTE: you probably want to set Windows's default terminal to "Windows
rem Terminal": go to Windows Settings, search for "terminal host", click
rem "Choose a terminal host app for interactive command-line tools", scroll
rem down to "Terminal", and select "Windows Terminal" from the drop-down.

rem Find Git Bash's install dir.  Prefer user-local install over sys-wide.
if exist "%LOCALAPPDATA%\Programs\Git\bin\sh.exe" (
  set gitbashdir="%LOCALAPPDATA%\Programs\Git"
) else (
  rem Search PATH for Git Bash.  See https://stackoverflow.com/a/21972348
  for %%a in ("%PATH:;=";"%") do (
    if exist "%%~a\..\..\Git\bin\sh.exe" (
      set gitbashdir=%%~a\..\..\Git
      goto :foundgitbash
    )
  )
  echo Can't find Git Bash's install dir.  Make sure it's in your PATH.
  pause
  exit /b 1
)

:foundgitbash
rem Based on https://superuser.com/a/1702987 and
rem https://superuser.com/a/1702441, but modified to use %~1 rather than
rem just %1.
rem
rem Using %~1 is crucial to make this work as a handler for double-clicking
rem files in Windows Explorer, because unlike %1, %~1 removes quotes that
rem interfere with sh and cygpath's path resolution.  See link for details:
rem https://stackoverflow.com/a/29822761
"%gitbashdir%\bin\sh.exe" -c "vim \"$(cygpath '%~1')\""
