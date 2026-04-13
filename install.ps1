$ErrorActionPreference = 'Stop'

$RepoUrl = "https://github.com/daemonicai/teambuilder.git"
$RepoApi = "https://api.github.com/repos/daemonicai/teambuilder/releases/latest"
$InstallDir = Join-Path $HOME ".claude\teambuilder"
$CommandsSrc = Join-Path $InstallDir "commands\teambuild"
$CommandsDst = Join-Path $HOME ".claude\commands\teambuild"
$SkillsSrcDir = Join-Path $InstallDir "skills"
$SkillsDstDir = Join-Path $HOME ".claude\skills"

# Resolve the target ref. Priority: $env:VERSION > latest GitHub release > main (bootstrap).
function Resolve-Target {
    if ($env:VERSION) {
        return $env:VERSION
    }
    try {
        $release = Invoke-RestMethod -Uri $RepoApi -UseBasicParsing -ErrorAction Stop
        if ($release.tag_name) {
            return $release.tag_name
        }
    } catch {
        # Fall through to bootstrap fallback.
    }
    return "main"
}

$Target = Resolve-Target

if ($Target -eq "main") {
    Write-Host "No release tag found (or VERSION=main). Installing from main - this is an unreleased build."
} else {
    Write-Host "Target: $Target"
}

# Determine the current ref of an existing install.
function Get-CurrentRef {
    if (-not (Test-Path (Join-Path $InstallDir ".git"))) {
        return $null
    }
    # Detached HEAD on a tag?
    $tag = git -C $InstallDir describe --tags --exact-match 2>$null
    if ($LASTEXITCODE -eq 0 -and $tag) {
        return $tag.Trim()
    }
    # On a branch?
    $branch = git -C $InstallDir symbolic-ref --short HEAD 2>$null
    if ($LASTEXITCODE -eq 0 -and $branch) {
        return $branch.Trim()
    }
    return "unknown"
}

$Current = Get-CurrentRef

# Install or update.
if (-not $Current) {
    Write-Host "Installing teambuilder at $Target..."
    git clone --depth 1 --branch $Target $RepoUrl $InstallDir
} elseif ($Current -eq $Target) {
    Write-Host "teambuilder is already at $Target. Refreshing symlinks only."
} else {
    Write-Host "Migrating teambuilder from $Current to $Target..."
    Remove-Item -Recurse -Force $InstallDir
    git clone --depth 1 --branch $Target $RepoUrl $InstallDir
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

# Ensure ~/.claude/skills exists, then symlink each teambuilder skill into it
if (-not (Test-Path $SkillsDstDir)) {
    New-Item -ItemType Directory -Path $SkillsDstDir | Out-Null
}

if (Test-Path $SkillsSrcDir) {
    Get-ChildItem -Path $SkillsSrcDir -Directory | ForEach-Object {
        $skillSrc = $_.FullName
        $skillDst = Join-Path $SkillsDstDir $_.Name
        $existingSkill = Get-Item $skillDst -ErrorAction SilentlyContinue
        if ($existingSkill) {
            if ($existingSkill.LinkType -eq "SymbolicLink") {
                if ($existingSkill.Target -ne $skillSrc) {
                    Write-Host "Updating skill symlink: $($_.Name)"
                    Remove-Item $skillDst
                    New-Item -ItemType SymbolicLink -Path $skillDst -Target $skillSrc | Out-Null
                }
            } else {
                Write-Error "${skillDst} exists and is not a symlink. Remove it and re-run."
                exit 1
            }
        } else {
            New-Item -ItemType SymbolicLink -Path $skillDst -Target $skillSrc | Out-Null
        }
    }
}

Write-Host "Done. teambuilder commands are available as /teambuild:* in Claude Code."
