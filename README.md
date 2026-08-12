# fresh-claude

A Claude Code plugin that runs shell commands through
[FreSH](https://github.com/S42yt/FreSH) instead of PowerShell on Windows.

Claude Code on Windows shells out to PowerShell, so it writes `Get-ChildItem`
where you would write `ls`. With this plugin switched on, the commands it runs
go through FreSH, and it writes POSIX syntax instead.

## Install

FreSH must be installed first, either on `PATH` or at
`%LOCALAPPDATA%\FreSH\FreSH.exe`. Grab it from
[the releases page](https://github.com/S42yt/FreSH/releases).

Then, in Claude Code:

```
/plugin marketplace add S42yt/fresh-claude
/plugin install fresh-claude
```

Or clone it somewhere and point Claude Code at the directory.

## Use

Routing is off until you ask for it:

```
/fresh on        # shell commands now run through FreSH
/fresh off       # back to PowerShell
/fresh status    # where FreSH was found, and whether routing is on
```

`on` writes a marker file at `%USERPROFILE%\.fresh-claude`, which is what the
hook checks. It survives restarts, so switch it off when you are done.

## How it works

A `PreToolUse` hook watches the `Bash` and `PowerShell` tools. When routing is
on it rewrites the command to `& 'FreSH.exe' -c '<your command>'` using the
hook's `updatedInput`, so Claude Code runs the rewritten version. Nothing is
auto approved: the usual permission prompt still applies to the rewritten
command, and you see exactly what will run.

The bundled `fresh-shell` skill teaches Claude the syntax to write, so it
stops reaching for cmdlets.

## What it leaves alone

The hook passes the command straight through, unchanged, when:

- routing is off, or `FRESH_CLAUDE_DISABLE` is set
- `FreSH.exe` cannot be found
- the command is already routed through FreSH
- the command contains PowerShell only syntax: a cmdlet such as
  `Get-ChildItem`, `$env:`, `$PSVersionTable`, `| %`, `| ?`, or a backtick

That last rule matters. Registry edits, COM, and Windows Terminal settings are
still easier in PowerShell, and those commands keep working while everything
else goes through FreSH.

## Caveats

- Windows only. FreSH is a Windows shell.
- `/dev/null` does not exist. Use `nul`.
- FreSH is not bash. No arrays, no `local`, no here documents, `grep` matches
  substrings rather than regular expressions, and `sed` only does `s///` and
  `d`. The skill spells out the full list.

## License

GNU General Public License v3.0, see [LICENSE](LICENSE).
