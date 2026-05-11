@rem Script to run a command with elevated privileges on Windows.
@rem Usage: wsudo COMMAND [ARGS...]
@rem Based loosely on https://stackoverflow.com/a/55643173

@echo off
setlocal

@rem Do `set keep_window_open=/k` to keep the admin command prompt open,
@rem or `set keep_window_open=/c` to let the window close automatically.
set keep_window_open=/c

@rem powershell -Command "Start-Process cmd -Verb RunAs -ArgumentList '%keep_window_open% cd /d %CD% && %*'"
powershell -ExecutionPolicy Bypass -NoProfile -NoLogo -Command "Start-Process cmd -Verb RunAs -ArgumentList '%keep_window_open% cd /d %CD% && %*'"
exit /b %ERRORLEVEL%
