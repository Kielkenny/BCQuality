# Installs the bc-quality-review Claude Code skill, using THIS BCQuality checkout as the
# knowledge corpus. Run from a clone of the fork:
#   powershell -ExecutionPolicy Bypass -File .\consumers\claude-code\install.ps1
[CmdletBinding()]
param(
    [string]$ClaudeDir = $(if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE '.claude' })
)
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# The corpus is the BCQuality checkout this script lives in (consumers/claude-code -> repo root).
$corpus = (Resolve-Path (Join-Path $here '..\..')).Path

# 1. Install the skill into the Claude skills folder.
$skillDest = Join-Path $ClaudeDir 'skills\bc-quality-review'
New-Item -ItemType Directory -Force -Path $skillDest | Out-Null
Copy-Item (Join-Path $here 'SKILL.md') (Join-Path $skillDest 'SKILL.md') -Force
Write-Host "[1/2] Skill installed -> $skillDest"

# 2. Point the skill at this checkout, regardless of where it lives.
setx BCQUALITY_HOME $corpus | Out-Null
Write-Host "[2/2] BCQUALITY_HOME = $corpus  (restart the terminal / Claude to pick it up)"
Write-Host ""
Write-Host "Done. This clone IS the corpus -- 'git pull' here to update knowledge."
Write-Host "In any BC/AL repo, ask Claude to 'run a BCQuality review'."
