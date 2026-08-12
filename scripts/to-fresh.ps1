#Requires -Version 5.1
# PreToolUse hook. Rewrites a shell command so it runs under FreSH.
# Stays out of the way unless routing is switched on with /fresh on.

$ErrorActionPreference = 'Stop'

function Passthrough { exit 0 }

$raw = [Console]::In.ReadToEnd()
if (-not $raw) { Passthrough }

try { $payload = $raw | ConvertFrom-Json } catch { Passthrough }

$command = $payload.tool_input.command
if (-not $command) { Passthrough }

if ($env:FRESH_CLAUDE_DISABLE) { Passthrough }

$marker = Join-Path $env:USERPROFILE '.fresh-claude'
if (-not (Test-Path $marker)) { Passthrough }

$fresh = (Get-Command FreSH.exe -ErrorAction SilentlyContinue).Source
if (-not $fresh) {
    $candidate = Join-Path $env:LOCALAPPDATA 'FreSH\FreSH.exe'
    if (Test-Path $candidate) { $fresh = $candidate }
}
if (-not $fresh) { Passthrough }

# already routed
if ($command -like "*FreSH.exe*") { Passthrough }

# PowerShell only syntax stays with PowerShell
$powershellOnly = '(\$env:|\$PSVersionTable|\b(Get|Set|New|Remove|Test|Join|Select|Where|ForEach|Write|Out|Start|Stop|Invoke|Import|Export|ConvertTo|ConvertFrom|Measure|Copy|Move|Resolve)-\w+|\|\s*%|\|\s*\?|`)'
if ($command -match $powershellOnly) { Passthrough }

$escaped = $command -replace "'", "''"
$rewritten = "& '$fresh' -c '$escaped'"

$updated = @{}
foreach ($property in $payload.tool_input.PSObject.Properties) {
    $updated[$property.Name] = $property.Value
}
$updated['command'] = $rewritten

@{
    hookSpecificOutput = @{
        hookEventName = 'PreToolUse'
        updatedInput  = $updated
    }
} | ConvertTo-Json -Depth 8 -Compress
