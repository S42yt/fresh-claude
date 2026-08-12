---
name: fresh-shell
description: How to write shell commands for FreSH, the zsh flavoured shell for Windows. Use when FreSH routing is on (the /fresh command switched it on, or a command was rewritten to run through FreSH.exe), or when the user asks for FreSH or .frsh scripts rather than PowerShell.
---

# Writing commands for FreSH

FreSH is a POSIX style shell for Windows. When routing is on, shell commands
are executed by `FreSH.exe -c` rather than PowerShell, so write POSIX syntax,
not cmdlets.

## Use these, not PowerShell

| Instead of | Write |
| --- | --- |
| `Get-ChildItem` | `ls`, `ls -l`, `ls -a` |
| `Get-Content file` | `cat file` |
| `Select-String pat` | `grep pat` |
| `Remove-Item -Recurse -Force x` | `rm -r x` |
| `Copy-Item a b` | `cp a b`, `cp -r a b` |
| `Move-Item a b` | `mv a b` |
| `New-Item -ItemType Directory -Force x` | `mkdir -p x` |
| `Test-Path x` | `test -e x`, `test -d x`, `test -f x` |
| `$env:NAME` | `$NAME` |
| `$env:NAME = "v"` | `export NAME=v` |
| `Write-Output x` | `echo x` |
| `Measure-Object -Line` | `wc -l` |
| `Sort-Object` / `Get-Unique` | `sort` / `uniq` |
| `Select-Object -First 5` | `head -n 5` |
| `Get-Process` | `ps` |
| `Stop-Process -Id n` | `kill n` |
| `Get-Command x` | `which x` |
| `Resolve-Path x` | `realpath x` |
| `Get-FileHash x` | `sha256sum x` |

Paths take forward slashes. `~` is the home directory.

## Shell syntax

Pipelines, `&&`, `||`, `;`, and background `&` all work. Redirection is
`>`, `>>`, `<`, `2>`, `2>&1`. Note that `/dev/null` does not exist, use `nul`.

```sh
grep -rn TODO src | head -n 20
test -d build || mkdir -p build
cargo build 2> errors.txt
noisy-thing > nul 2>&1
```

Expansion is POSIX: `$VAR`, `${VAR:-default}`, `${#VAR}`, `$(command)`,
`$((1 + 2))`, `$?`, `$@`. Globs are `*` and `?`.

Control flow is `if/elif/else/fi`, `while`, `until`, `for x in ...`,
`case ... esac`, and functions with `name() { ...; }`.

## FreSH extensions

These are not in bash and make scripts shorter:

```sh
set -e                      # stop on the first failure, conditions exempt
set -x                      # trace commands to stderr
have gcc || die "no gcc"    # have tests for a command, die aborts with a message
say "building"              # dim bullet
ok "done"                   # green tick
warn "skipped tests"        # yellow bang
```

## Scripts

FreSH scripts use the `.frsh` extension and run without bash, WSL or MSYS2.
Write them with the syntax above. A shebang is optional and ignored.

## Also available

Arrays (`arr=(a b c)`, `${arr[@]}`, `${#arr[@]}`, `declare -A`), `local` in
functions, here documents, `[[ ... ]]` including `=~`, brace expansion,
process substitution `<(...)`, `set -e`, `set -u`, `set -x`, `trap`, `jobs`,
`wait`, and `select`. `grep` and `sed` take real regular expressions, basic by
default and extended with `-E`.

FreSH adds `die`, `have`, `say`, `ok` and `warn`, which shorten scripts:

```sh
set -e
have gcc || die "no compiler"
say "building"
```

## Not available

No `fg` or `bg`, and only EXIT, INT and ERR in `trap`. No
`${var/pattern/replacement}`. `awk`, `tar` and `curl` are not bundled; if they
are on PATH FreSH will run them.

## When something needs PowerShell

Windows specific work, such as the registry, COM, or Windows Terminal
settings, is still easier in PowerShell. The hook leaves commands containing
cmdlets or `$env:` alone, so writing PowerShell for those cases keeps working.
Say which shell you are using when it matters.
