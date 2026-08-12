---
description: Turn FreSH command routing on or off, or show its status
argument-hint: "[on|off|status]"
---

The user typed `/fresh $ARGUMENTS`.

Routing is controlled by a marker file at `$env:USERPROFILE\.fresh-claude`.
When it exists, the plugin's PreToolUse hook rewrites shell commands to run
through `FreSH.exe -c`. When it does not, commands run in PowerShell as usual.

Do exactly one of the following, based on the argument (treat an empty
argument as `status`):

- **on**: create the marker file, then confirm in one line that shell commands
  now run through FreSH. From this point in the session, write shell commands
  in POSIX and FreSH syntax rather than PowerShell syntax: `ls`, `cat`, `grep`,
  `rm -r`, `$VAR`, `$(...)`, `&&`, `|`. Read the `fresh-shell` skill for the
  details if you have not already.
- **off**: delete the marker file if it exists, then confirm in one line that
  commands run in PowerShell again, and go back to PowerShell syntax.
- **status**: report whether the marker file exists, where `FreSH.exe` was
  found (or that it was not found), and the current FreSH version. Keep it to
  a few lines.

If `FreSH.exe` cannot be found on PATH or at
`%LOCALAPPDATA%\FreSH\FreSH.exe`, say so and point at
https://github.com/S42yt/FreSH/releases rather than switching routing on,
since the hook falls back to PowerShell when the binary is missing anyway.
