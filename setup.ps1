param(
    [switch]$NoPause,
    [switch]$DefaultsNo
)

$ErrorActionPreference = 'Stop'

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Restart-Elevated {
    $scriptPath = $PSCommandPath
    $arguments = @(
        '-ExecutionPolicy', 'Bypass',
        '-File', ('"{0}"' -f $scriptPath)
    )

    if ($NoPause) {
        $arguments += '-NoPause'
    }

    if ($DefaultsNo) {
        $arguments += '-DefaultsNo'
    }

    Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList $arguments | Out-Null
}

function Confirm-Yes {
    param([string]$Prompt)

    if ($DefaultsNo) {
        Write-Host "$Prompt N"
        return $false
    }

    while ($true) {
        $answer = Read-Host $Prompt
        switch ($answer.Trim().ToUpperInvariant()) {
            'Y' { return $true }
            'N' { return $false }
            default { Write-Host 'Please answer Y or N.' }
        }
    }
}

function Confirm-Backup {
    param([string]$Prompt)

    if ($DefaultsNo) {
        Write-Host "$Prompt S"
        return $false
    }

    while ($true) {
        $answer = Read-Host $Prompt
        switch ($answer.Trim().ToUpperInvariant()) {
            'B' { return $true }
            'S' { return $false }
            default { Write-Host 'Please answer B or S.' }
        }
    }
}

function Get-BackupPath {
    param([string]$TargetPath)

    $backupPath = "$TargetPath.bak"
    $index = 1

    while (Test-Path -LiteralPath $backupPath) {
        $backupPath = "$TargetPath.bak$index"
        $index += 1
    }

    return $backupPath
}

function Create-Link {
    param(
        [string]$Label,
        [string]$Source,
        [string]$Target
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Host "[ERROR] $Label source not found: $Source"
        return
    }

    $parent = Split-Path -Path $Target -Parent
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if (Test-Path -LiteralPath $Target) {
        Write-Host "Existing target found for $Label: $Target"
        if (-not (Confirm-Backup 'Backup and replace, or skip? [B/S]')) {
            Write-Host "Skipped $Label."
            return
        }

        $backupPath = Get-BackupPath -TargetPath $Target
        Move-Item -LiteralPath $Target -Destination $backupPath
        Write-Host "Backed up existing file to $backupPath"
    }

    New-Item -ItemType SymbolicLink -Path $Target -Target $Source | Out-Null
    Write-Host "[OK] $Target -> $Source"
}

if (-not (Test-IsAdmin)) {
    Write-Host 'Restarting with administrator rights...'
    Restart-Elevated
    exit 0
}

$repoRoot = Split-Path -Path $PSCommandPath -Parent

Write-Host '==============================================='
Write-Host 'Nericema config symlink setup'
Write-Host ("Repo root: {0}" -f $repoRoot)
Write-Host '==============================================='
Write-Host ''
Write-Host 'This script creates symbolic links from this repo to your local config files.'
Write-Host 'Administrator rights are required to create the symbolic links.'
Write-Host ''

if (Confirm-Yes 'Create GlazeWM link? [Y/N]') {
    Create-Link -Label 'GlazeWM config' -Source (Join-Path $repoRoot 'glazewm\config.yaml') -Target (Join-Path $env:USERPROFILE '.glzr\glazewm\config.yaml')
}

Write-Host ''
if (Confirm-Yes 'Create YASB links? [Y/N]') {
    Create-Link -Label 'YASB config' -Source (Join-Path $repoRoot 'yasb\config.yaml') -Target (Join-Path $env:USERPROFILE '.config\yasb\config.yaml')
    Create-Link -Label 'YASB stylesheet' -Source (Join-Path $repoRoot 'yasb\styles.css') -Target (Join-Path $env:USERPROFILE '.config\yasb\styles.css')
}

Write-Host ''
if (Confirm-Yes 'Create Rainmeter link? [Y/N]') {
    $rainmeterDir = Join-Path $env:USERPROFILE 'Documents\Rainmeter\Skins\Nericema'
    if (-not (Test-Path -LiteralPath $rainmeterDir)) {
        New-Item -ItemType Directory -Path $rainmeterDir -Force | Out-Null
    }

    Create-Link -Label 'Rainmeter clock skin' -Source (Join-Path $repoRoot 'rainmeter\clock.ini') -Target (Join-Path $rainmeterDir 'clock.ini')
}

Write-Host ''
if (Confirm-Yes 'Create AutoHotkey link? [Y/N]') {
    $defaultAutoHotkeyTarget = Join-Path $env:USERPROFILE 'Documents\AutoHotkey\rapidkeys.ahk'

    if ($DefaultsNo) {
        $autoHotkeyTarget = $defaultAutoHotkeyTarget
        Write-Host ("AutoHotkey target path [{0}]" -f $defaultAutoHotkeyTarget)
    }
    else {
        $autoHotkeyTarget = Read-Host "AutoHotkey target path [$defaultAutoHotkeyTarget]"
        if ([string]::IsNullOrWhiteSpace($autoHotkeyTarget)) {
            $autoHotkeyTarget = $defaultAutoHotkeyTarget
        }
    }

    Create-Link -Label 'AutoHotkey script' -Source (Join-Path $repoRoot 'autohotkeys\rapidkeys.ahk') -Target $autoHotkeyTarget
}

Write-Host ''
Write-Host 'Windhawk is intentionally skipped.'
Write-Host ''
Write-Host 'Setup finished.'

if (-not $NoPause) {
    Read-Host 'Press Enter to exit'
}