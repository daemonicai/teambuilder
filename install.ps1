$ErrorActionPreference = 'Stop'

$RepoUrl = "https://github.com/daemonicai/teambuild.git"
$InstallDir = Join-Path $HOME ".claude\teambuilder"
$CommandsSrc = Join-Path $InstallDir "commands\teambuild"
$CommandsDst = Join-Path $HOME ".claude\commands\teambuild"

# Install or update
if (Test-Path (Join-Path $InstallDir ".git")) {
    Write-Host "Updating teambuilder..."
    git -C $InstallDir pull --ff-only
} else {
    Write-Host "Installing teambuilder..."
    git clone --depth 1 --branch release $RepoUrl $InstallDir
}

# Ensure ~/.claude/commands exists
$CommandsDir = Join-Path $HOME ".claude\commands"
if (-not (Test-Path $CommandsDir)) {
    New-Item -ItemType Directory -Path $CommandsDir | Out-Null
}

# Symlink commands/teambuild into ~/.claude/commands/teambuild
$existing = Get-Item $CommandsDst -ErrorAction SilentlyContinue
if ($existing) {
    if ($existing.LinkType -eq "SymbolicLink") {
        if ($existing.Target -ne $CommandsSrc) {
            Write-Host "Updating symlink..."
            Remove-Item $CommandsDst
            New-Item -ItemType SymbolicLink -Path $CommandsDst -Target $CommandsSrc | Out-Null
        }
    } else {
        Write-Error "${CommandsDst} exists and is not a symlink. Remove it and re-run."
        exit 1
    }
} else {
    New-Item -ItemType SymbolicLink -Path $CommandsDst -Target $CommandsSrc | Out-Null
}

Write-Host "Done. teambuilder commands are available as /teambuild:* in Claude Code."
