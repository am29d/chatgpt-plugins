[CmdletBinding()]
param([string] $CodexPath)

$ErrorActionPreference = 'Stop'
$marketplace = 'am29d-plugins'
$plugin = 'spielraum-chatgpt'
$sourceUrl = 'https://github.com/am29d/chatgpt-plugins.git'

if (-not $CodexPath) {
    $CodexPath = $env:CODEX_CLI_PATH
    if (-not $CodexPath -or -not (Test-Path -LiteralPath $CodexPath -PathType Leaf)) {
        $command = Get-Command codex -CommandType Application -ErrorAction SilentlyContinue |
            Select-Object -First 1
        $CodexPath = $command.Source
    }
    if (-not $CodexPath) {
        $CodexPath = Get-Process -Name ChatGPT -ErrorAction SilentlyContinue |
            Where-Object { $_.Path } |
            ForEach-Object {
                Join-Path (Split-Path -Parent $_.Path) 'resources\codex-cli\bin\codex.exe'
            } |
            Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
            Select-Object -First 1
    }
}
if (-not $CodexPath -or -not (Test-Path -LiteralPath $CodexPath -PathType Leaf)) {
    throw 'Codex CLI was not found. Use a local Codex session with a CLI or pass -CodexPath.'
}

function Invoke-CodexJson([string[]] $Command) {
    $output = & $CodexPath @Command --json
    if ($LASTEXITCODE -ne 0) {
        throw "Codex failed while running $($Command -join ' ') (exit $LASTEXITCODE). $output"
    }
    return ($output -join "`n") | ConvertFrom-Json
}

$registration = Invoke-CodexJson @('plugin', 'marketplace', 'add', $sourceUrl, '--ref', 'main')
if ($registration.marketplaceName -ne $marketplace -or
    -not ($registration.alreadyAdded -is [bool])) {
    throw 'Codex returned an unexpected marketplace registration.'
}
if ($registration.alreadyAdded) {
    $refresh = Invoke-CodexJson @('plugin', 'marketplace', 'upgrade', $marketplace)
    if ($refresh.PSObject.Properties['errors'] -eq $null -or $refresh.errors.Count -ne 0) {
        throw "Codex could not refresh the marketplace. $($refresh | ConvertTo-Json -Depth 8 -Compress)"
    }
}

if (-not $registration.installedRoot) {
    throw 'Codex did not return a marketplace path.'
}
$manifest = Join-Path $registration.installedRoot "plugins/$plugin/plugin.json"
$expectedVersion = (Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json).version
if (-not $expectedVersion) {
    throw 'The marketplace plugin manifest has no version.'
}
$result = Invoke-CodexJson @('plugin', 'add', "$plugin@$marketplace")
if ($result.pluginId -ne "$plugin@$marketplace" -or $result.version -ne $expectedVersion) {
    throw 'Codex did not report the expected plugin and version.'
}

$status = Invoke-CodexJson @('plugin', 'list', '--marketplace', $marketplace)
$enabled = $status.installed | Where-Object {
    $_.pluginId -eq "$plugin@$marketplace" -and
        $_.version -eq $result.version -and $_.enabled -eq $true
}
if (-not $enabled) {
    throw "Codex did not confirm that Spielraum $($result.version) is enabled."
}
Write-Output "Installed and enabled Spielraum $($result.version). Start a new local Codex chat to load it."
