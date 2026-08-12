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
| `Invoke-WebRequest -OutFile` | `wget -O file url` |
| `ForEach-Object { $_.Split(...) }` | `awk '{ print $2 }'` |

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

## Finding out what a command takes

`help <command>` prints a description and the argument shape, in the
`<required> [optional] ...` style:

```sh
help grep
help trap
```

Use it rather than guessing at flags; only the ones listed are implemented.

## Also available

Arrays (`arr=(a b c)`, `${arr[@]}`, `${#arr[@]}`, `declare -A`), `local` in
functions, here documents, `[[ ... ]]` including `=~`, brace expansion,
process substitution `<(...)` and `>(...)`, `set -e`, `set -u`, `set -x`,
and `select`.

Parameter expansion is complete: `${v#pat}` `${v##pat}` `${v%pat}` `${v%%pat}`,
`${v/a/b}` `${v//a/b}` `${v/#a/b}` `${v/%a/b}`, `${v:off:len}`, `${v^^}`
`${v,,}`.

Job control: `jobs`, `fg`, `bg`, `wait`, and `stop` (the FreSH stand in for
Ctrl+Z, which Windows has no key for). `trap` takes EXIT, HUP, INT, QUIT,
TERM, ERR, DEBUG and RETURN.

`grep` and `sed` take real regular expressions, basic by default and extended
with `-E`. `awk` is bundled and real: `BEGIN`/`END`, patterns, `$1`, `NR`,
`NF`, `-F`, `-v`, control flow, `printf`, `length`/`substr`/`index`/`toupper`/
`tolower`/`int`, plus arrays with `in` and `delete`, `for (k in a)`, `split`,
user defined functions with `return`, and `getline`.

```sh
awk -F: '{ print $2, $1 }' pairs.txt
awk '$2 > 30 { print $1 }' people.txt
awk '/error/ { n++ } END { print n " errors" }' build.log
```

`curl` and `tar` are not bundled because Windows already ships both, and they
resolve on PATH.

FreSH adds `die`, `have`, `say`, `ok` and `warn`, which shorten scripts:

```sh
set -e
have gcc || die "no compiler"
say "building"
```

`fresh update` upgrades the shell in place. `rehash` rescans PATH and reloads
themes and plugins after you edit them.

## Not available

Backgrounding a bundled command with `&` runs it in the foreground, since it
runs inside the shell. No `coproc`, `shopt` or `$'...'`. In awk, no
`cmd | getline` and no `ENVIRON`. Anything else you need, install it, put it
on PATH and run `rehash`; a real executable always beats a bundled one.

## When something needs PowerShell

Windows specific work, such as the registry, COM, or Windows Terminal
settings, is still easier in PowerShell. The hook leaves commands containing
cmdlets or `$env:` alone, so writing PowerShell for those cases keeps working.
Say which shell you are using when it matters.
