<#
.SYNOPSIS
  Reports whether a live practice needs to re-enter the Adoption Loop.

.DESCRIPTION
  The mechanical half of drift-check.md. Reads a practice manifest and reports,
  without judgment:

    DRIFTED        a materialized artifact's hash no longer matches the manifest
    MISSING        an artifact in the manifest is not on disk
    REVIEW DUE     a review_by date has elapsed
    STALE          the blueprint changed since it was read
    PROFILE STALE  the profile changed since it was read - entries tracing to
                   superseded facts need reconciling
    DEFERRED       open deferral triggers, listed for the operator to evaluate

  Blueprint and profile evolve independently, so each is checked separately.
  Staleness of either is only computable when its version_ref is a tree hash.

  It classifies nothing and fixes nothing. Drift is a signal, not a violation:
  a hand-edited artifact usually means the adopter improved it, and the response
  is reconciliation with them, never a silent overwrite.

.PARAMETER Manifest
  Path to practice-manifest.json.

.PARAMETER Root
  Base for resolving relative artifact paths. Defaults to the manifest's directory.

.PARAMETER WithinDays
  Also report reviews falling due within this many days. Default 0 (elapsed only).

.OUTPUTS
  Exit 0 — everything matches and nothing is due.
  Exit 1 — attention needed (drift, missing, review due, or a stale input).
  Exit 2 — the manifest could not be read.

.EXAMPLE
  ./Test-PracticeDrift.ps1 -Manifest ./adoption/my-practice/practice-manifest.json -WithinDays 14
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)][string] $Manifest,
    [string] $Root,
    [int]    $WithinDays = 0
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-FileHashOrNull {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

# A blueprint is a directory of documents. Its version_ref, when it is a hash,
# is the hash of every file's relative path plus content, in sorted order.
function Get-TreeHash {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    if (Test-Path -LiteralPath $Path -PathType Leaf) { return Get-FileHashOrNull $Path }

    $base = (Resolve-Path -LiteralPath $Path).Path
    $parts = Get-ChildItem -LiteralPath $base -Recurse -File |
        Sort-Object FullName |
        ForEach-Object {
            $rel = $_.FullName.Substring($base.Length).TrimStart('\', '/') -replace '\\', '/'
            "$rel`:$((Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant())"
        }
    if (-not $parts) { return $null }
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes(($parts -join "`n"))
        return [System.BitConverter]::ToString($sha.ComputeHash($bytes)).Replace('-', '').ToLowerInvariant()
    }
    finally { $sha.Dispose() }
}

if (-not (Test-Path -LiteralPath $Manifest -PathType Leaf)) {
    Write-Error "Manifest not found: $Manifest"
    exit 2
}

try { $m = Get-Content -LiteralPath $Manifest -Raw | ConvertFrom-Json }
catch {
    Write-Error "Manifest is not valid JSON: $($_.Exception.Message)"
    exit 2
}

if (-not $Root) { $Root = Split-Path -Parent (Resolve-Path -LiteralPath $Manifest).Path }

function Resolve-Target {
    param([string] $Path)
    $expanded = [Environment]::ExpandEnvironmentVariables($Path)
    if ($expanded.StartsWith('~')) { $expanded = Join-Path $HOME $expanded.Substring(1).TrimStart('\', '/') }
    if ([System.IO.Path]::IsPathRooted($expanded)) { return $expanded }
    return Join-Path $Root $expanded
}

$today    = [datetime]::Today
$findings = [System.Collections.Generic.List[object]]::new()
$okCount  = 0

$artifacts = @()
if ($m.PSObject.Properties.Name -contains 'artifacts' -and $m.artifacts) { $artifacts = @($m.artifacts) }

foreach ($a in $artifacts) {
    $target = Resolve-Target $a.path
    $actual = Get-FileHashOrNull $target
    $tracked = if ($a.PSObject.Properties.Name -contains 'sha256' -and $a.sha256) { "$($a.sha256)".ToLowerInvariant() } else { $null }

    if ($null -eq $actual) {
        $findings.Add([pscustomobject]@{ Kind = 'MISSING'; Path = $a.path; Detail = 'in manifest, not on disk' })
    }
    elseif ($tracked -and $actual -ne $tracked) {
        $findings.Add([pscustomobject]@{ Kind = 'DRIFTED'; Path = $a.path; Detail = "hash mismatch - reconcile before regenerating (owner $($a.owner))" })
    }
    else {
        $okCount++
    }

    $reviewBy = if ($a.PSObject.Properties.Name -contains 'review_by') { "$($a.review_by)" } else { '' }
    if ($reviewBy -and $reviewBy -notmatch '^(never|<.*>)$') {
        $due = $reviewBy -as [datetime]
        if ($null -ne $due) {
            $days = ($today - $due.Date).Days
            if ($days -ge 0) {
                $findings.Add([pscustomobject]@{ Kind = 'REVIEW DUE'; Path = $a.path; Detail = "review_by $reviewBy, $days day(s) elapsed, owner $($a.owner)" })
            }
            elseif ($WithinDays -gt 0 -and (-$days) -le $WithinDays) {
                $findings.Add([pscustomobject]@{ Kind = 'REVIEW SOON'; Path = $a.path; Detail = "review_by $reviewBy, in $(-$days) day(s), owner $($a.owner)" })
            }
        }
    }
}

# Input staleness: only checkable when version_ref is a tree hash we can recompute.
# Both inputs evolve independently, so each is checked on its own.
$stale = $false
foreach ($src in @(
        @{ Key = 'blueprint'; Kind = 'STALE' },
        @{ Key = 'profile'; Kind = 'PROFILE STALE' })) {

    $key = $src.Key
    if (-not ($m.PSObject.Properties.Name -contains $key) -or -not $m.$key) { continue }
    $node = $m.$key
    $ref = if ($node.PSObject.Properties.Name -contains 'version_ref') { "$($node.version_ref)".ToLowerInvariant() } else { '' }
    if ($ref -notmatch '^[0-9a-f]{64}$') { continue }

    $now = Get-TreeHash (Resolve-Target $node.source)
    if ($null -eq $now) {
        $findings.Add([pscustomobject]@{ Kind = $src.Kind; Path = $node.source; Detail = "$key source not readable" })
        $stale = $true
    }
    elseif ($now -ne $ref) {
        $detail = if ($key -eq 'profile') {
            "profile changed since it was read - check entries tracing to superseded facts ($ref -> $now)"
        }
        else {
            "blueprint changed since it was read ($ref -> $now)"
        }
        $findings.Add([pscustomobject]@{ Kind = $src.Kind; Path = $node.source; Detail = $detail })
        $stale = $true
    }
}

$deferred = @()
if ($m.PSObject.Properties.Name -contains 'deferred' -and $m.deferred) { $deferred = @($m.deferred) }

# --- report ---------------------------------------------------------------
function Get-SourceLabel {
    param($Node)
    if (-not $Node) { return '(none)' }
    $ref = if ($Node.PSObject.Properties.Name -contains 'version_ref') { "$($Node.version_ref)" } else { '' }
    if ($ref -match '^[0-9a-f]{64}$') { $ref = $ref.Substring(0, 12) }
    if ($ref) { return "$($Node.source) @ $ref" }
    return "$($Node.source)"
}

$bpNode = if ($m.PSObject.Properties.Name -contains 'blueprint') { $m.blueprint } else { $null }
$prNode = if ($m.PSObject.Properties.Name -contains 'profile') { $m.profile } else { $null }
Write-Host ""
Write-Host "Practice:  $($m.practice_id)"
Write-Host "Blueprint: $(Get-SourceLabel $bpNode)"
Write-Host "Profile:   $(Get-SourceLabel $prNode)"
Write-Host "Artifacts: $($artifacts.Count)   Phase: $($m.phase)"
Write-Host ""

foreach ($f in $findings) {
    $colour = switch ($f.Kind) {
        'DRIFTED'       { 'Yellow' }
        'MISSING'       { 'Red' }
        'STALE'         { 'Yellow' }
        'PROFILE STALE' { 'Yellow' }
        'REVIEW DUE'    { 'Yellow' }
        default         { 'Gray' }
    }
    Write-Host ("{0,-14} {1}" -f $f.Kind, $f.Path) -ForegroundColor $colour
    Write-Host ("               {0}" -f $f.Detail) -ForegroundColor DarkGray
}

if ($okCount -gt 0) { Write-Host ("{0,-14} {1} artifact(s) match" -f 'OK', $okCount) -ForegroundColor Green }

foreach ($d in $deferred) {
    Write-Host ("{0,-14} {1}" -f 'DEFERRED', $d.element_id) -ForegroundColor Gray
    Write-Host ("               trigger: {0}" -f $d.trigger) -ForegroundColor DarkGray
}

$upcoming = $artifacts |
    Where-Object {
        $_.PSObject.Properties.Name -contains 'review_by' -and
        "$($_.review_by)" -match '^\d{4}-\d{2}-\d{2}$'
    } |
    Sort-Object { [datetime] $_.review_by } |
    Select-Object -First 1

Write-Host ""
if ($upcoming) { Write-Host "Next review: $($upcoming.review_by) ($($upcoming.path))" }
else { Write-Host "Next review: none scheduled" }
Write-Host ""

$needsAttention = $stale -or ($findings | Where-Object { $_.Kind -in @('DRIFTED', 'MISSING', 'REVIEW DUE') })
if ($needsAttention) { exit 1 } else { exit 0 }
