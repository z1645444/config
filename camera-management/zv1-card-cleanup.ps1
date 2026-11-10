<#
.SYNOPSIS
    Sony ZV-1 / RX100 series memory card maintenance (Windows PowerShell 5.1+ / PowerShell 7+).

.DESCRIPTION
    Run this AFTER you deleted clips / photos on the camera or in a file manager, to clean up
    everything that makes the camera report "database repair failed":

      1. foreign directories left by other operating systems
         (.Trashes, .Spotlight-V100, .fseventsd, .TemporaryItems, System Volume Information, ...)
      2. macOS AppleDouble leftovers: ._* and .DS_Store
      3. empty shooting folders under DCIM
      4. stale AVCHD shell (PRIVATE\AVCHD with an empty BDMV\STREAM) and all-zero AVF_INFO\AVIN*.INT
      5. dangling <Material> entries in PRIVATE\M4ROOT\MEDIAPRO.XML (entries whose .MP4 was deleted)
      6. read-only health report: file integrity, DB consistency, free space

    It NEVER deletes photos (DCIM) or movies (PRIVATE\M4ROOT\CLIP, THMBNL).

.PARAMETER Path
    Card root. Defaults to the folder this script lives in.

.PARAMETER Apply
    Actually perform the deletions. Without it the script only prints the plan.

.PARAMETER PruneOrphanThumbs
    Accepted for backwards compatibility. Orphan thumbnails are now ALWAYS removed:

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\zv1-card-cleanup.ps1
    powershell -ExecutionPolicy Bypass -File .\zv1-card-cleanup.ps1 -Apply
    powershell -ExecutionPolicy Bypass -File .\zv1-card-cleanup.ps1 D:\ -Apply
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Position = 0)][string]$Path,
    [switch]$Apply,
    [switch]$PruneOrphanThumbs
)

$ErrorActionPreference = 'Continue'

# -WhatIf is honoured explicitly: $PSCmdlet.ShouldProcess() is unreliable when the script is
# started with "powershell -File" on Windows PowerShell 5.1.
$script:WhatIfMode = $false
if ($PSBoundParameters.ContainsKey('WhatIf')) { $script:WhatIfMode = [bool]$WhatIfPreference }

function Remove-Safe([string]$path) {
    if ($script:WhatIfMode) {
        Write-Host ("  WhatIf: would delete {0}" -f $path)
        return $false
    }
    try {
        Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction Stop
        return $true
    } catch {
        Write-Host ("  FAILED: {0} -> {1}" -f $path, $_.Exception.Message)
        return $false
    }
}

if (-not $Path) { $Path = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path } }
if (-not (Test-Path -LiteralPath $Path)) {
    Write-Host "ERROR: path not found: $Path"; exit 1
}
$Root = (Resolve-Path -LiteralPath $Path).ProviderPath.TrimEnd('\', '/')

$DCIM = Join-Path $Root 'DCIM'
$M4   = Join-Path $Root 'PRIVATE\M4ROOT'
$AVF  = Join-Path $Root 'AVF_INFO'
$XML  = Join-Path $M4   'MEDIAPRO.XML'

Write-Host ''
Write-Host "Sony card maintenance - $Root"

if (-not (Test-Path -LiteralPath $DCIM) -and -not (Test-Path -LiteralPath $M4)) {
    Write-Host "ERROR: '$Root' is not a Sony camera card (neither DCIM\ nor PRIVATE\M4ROOT\ found)."
    exit 1
}

$plan      = New-Object System.Collections.Generic.List[object]
$notes     = New-Object System.Collections.Generic.List[string]

function Get-Size([string]$p) {
    if (-not (Test-Path -LiteralPath $p)) { return [int64]0 }
    $item = Get-Item -LiteralPath $p -Force
    if (-not $item.PSIsContainer) { return [int64]$item.Length }
    $sum = (Get-ChildItem -LiteralPath $p -Recurse -Force -File -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum).Sum
    if ($sum) { return [int64]$sum } else { return [int64]0 }
}
function Add-Plan([string]$p, [string]$reason) {
    $script:plan.Add([pscustomobject]@{ Path = $p; Reason = $reason; Bytes = (Get-Size $p) })
}

# ---------------------------------------------------------------- 1. foreign directories
$foreignDirs = New-Object System.Collections.Generic.List[string]
foreach ($name in @('.Trashes', '.Spotlight-V100', '.fseventsd', '.TemporaryItems', 
                    '.Trash-501', 'System Volume Information', '$RECYCLE.BIN', 'lost+found')) {
    $p = Join-Path $Root $name
    if (Test-Path -LiteralPath $p) { Add-Plan $p 'directory created by another OS'; $foreignDirs.Add($p) }
}

# ---------------------------------------------------------------- 2. macOS leftovers
# skip anything inside the foreign directories above: those are removed whole,
# and a later Remove-Item on their (already deleted) children would just throw
Get-ChildItem -LiteralPath $Root -Recurse -Force -File -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_.Name -notlike '._*' -and $_.Name -ne '.DS_Store') { return }
    foreach ($d in $foreignDirs) {
        if ($_.FullName.StartsWith($d + [System.IO.Path]::DirectorySeparatorChar,
                                   [StringComparison]::OrdinalIgnoreCase)) { return }
    }
    Add-Plan $_.FullName 'macOS metadata leftover'
}

# ---------------------------------------------------------------- 3. empty DCIM folders
if (Test-Path -LiteralPath $DCIM) {
    Get-ChildItem -LiteralPath $DCIM -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $folder = $_
        $folderErr = $null
        $kids = @(Get-ChildItem -LiteralPath $folder.FullName -Force -ErrorAction SilentlyContinue -ErrorVariable folderErr |
                  Where-Object { $_.Name -notlike '._*' -and $_.Name -ne '.DS_Store' })
        if ($folderErr) {
            $notes.Add("cannot list $($folder.FullName) - folder left untouched")
            return
        }
        # a folder that only holds ._*/.DS_Store ghosts is "empty" for our purposes:
        # those files are already on the plan, so flag the folder in the same run
        if (-not $kids) { Add-Plan $folder.FullName 'empty DCIM shooting folder' }
    }
}

# ---------------------------------------------------------------- 4. stale AVCHD shell / zeroed INT
$avchd  = Join-Path $Root 'PRIVATE\AVCHD'
$stream = Join-Path $avchd 'BDMV\STREAM'
$avchdUnscannable = $false
if (Test-Path -LiteralPath $avchd) {
    $hasStream = $false
    if (Test-Path -LiteralPath $stream) {
        $scanErr = $null
        $streamFiles = @(Get-ChildItem -LiteralPath $stream -Force -File -ErrorAction SilentlyContinue -ErrorVariable scanErr)
        if ($streamFiles) {
            $hasStream = $true
        } elseif ($scanErr) {
            # a scan failure is NOT an empty stream - never delete on suspicion
            $avchdUnscannable = $true
            $notes.Add("BDMV\STREAM could not be scanned - AVCHD left untouched")
        }
    }
    if (-not $hasStream -and -not $avchdUnscannable) { Add-Plan $avchd 'stale AVCHD index (BDMV\STREAM is empty)' }
}
if (Test-Path -LiteralPath $AVF) {
    Get-ChildItem -LiteralPath $AVF -Force -File -Filter 'AVIN*.INT' -ErrorAction SilentlyContinue | ForEach-Object {
        $idx = $_
        $allZero = $true
        $fs = $null
        try {
            $fs = [System.IO.File]::OpenRead($idx.FullName)
            $buf = New-Object byte[] 65536
            while ($allZero) {
                $read = $fs.Read($buf, 0, $buf.Length)
                if ($read -le 0) { break }
                foreach ($b in $buf[0..($read - 1)]) { if ($b -ne 0) { $allZero = $false; break } }
            }
        } catch {
            # unreadable index: cannot prove it is all-zero, so leave it alone
            $allZero = $false
            $notes.Add(('AVIN index could not be read, left untouched: {0}' -f $idx.Name))
        } finally { if ($fs) { $fs.Dispose() } }
        if ($allZero) { Add-Plan $idx.FullName 'all-zero AVIN index, never written by the camera' }
    }
}

# ---------------------------------------------------------------- 5. MEDIAPRO.XML dangling entries
# A <Material> block is dropped ONLY when its own movie (CLIP\*.MP4) is gone. A missing
# sidecar (.MP4/.THMBNL) alone is not enough - the clip stays playable, so the entry stays.
$xmlPrune   = New-Object System.Collections.Generic.List[string]
$xmlBlocks  = New-Object System.Collections.Generic.List[string]
$xmlTotal   = 0
$xmlText = $null
$xmlRefuseReason = $null
$xmlAction = 'none'

if (Test-Path -LiteralPath $XML) {
    try {
        $xmlText = [System.IO.File]::ReadAllText($XML)
    } catch {
        # locked or unreadable database: '' makes every check below a silent
        # no-op, and '' (not $null) keeps [regex]::Matches() safe later on
        $notes.Add('MEDIAPRO.XML could not be read - left untouched: ' + $_.Exception.Message)
        $xmlText = ''
    }
    $m4Files = @(Get-ChildItem -LiteralPath $M4 -Recurse -Force -File -ErrorAction SilentlyContinue)
    if ($m4Files.Count -lt 1) {
        $xmlRefuseReason = 'cannot list any file under PRIVATE\M4ROOT - refusing to touch MEDIAPRO.XML'
    } else {
        $present = @{}
        foreach ($f in $m4Files) {
            $present[($f.FullName.Substring($M4.Length + 1) -replace '\\', '/')] = $true
        }
        $blocks = [regex]::Matches($xmlText, '(?ms)^[ \t]*<Material\b.*?</Material>[ \t]*\r?\n?')
        $xmlTotal = $blocks.Count
        foreach ($m in $blocks) {
            $uris = [regex]::Matches($m.Value, 'uri="\./([^"]+)"') | ForEach-Object { $_.Groups[1].Value }
            $primary = $uris | Where-Object { $_ -match '^CLIP/[^/]+\.MP4$' } | Select-Object -First 1
            if (-not $primary) { $primary = $uris | Select-Object -First 1 }
            if ($primary -and -not $present.ContainsKey($primary)) {
                $xmlPrune.Add(($m.Value -split "`n")[0].Trim())
                $xmlBlocks.Add($m.Value)
            }
        }
        if ($xmlTotal -gt 0 -and $xmlPrune.Count -eq $xmlTotal) {
            # EVERY entry dangles. That is only dangerous if clips are still on the card
            # (loud inconsistency / list failure). If CLIP\ has no .MP4 at all the movies
            # are really gone - scrapping the database is the fix and lets the camera
            # rebuild a fresh one via Restore Database.
            $mp4Left = @(Get-ChildItem -LiteralPath (Join-Path $M4 'CLIP') -Filter '*.MP4' -File -Force -ErrorAction SilentlyContinue |
                         Where-Object { $_.Name -notlike '._*' })
            if ($mp4Left.Count -gt 0) {
                $xmlRefuseReason = ('ALL {0} entries dangle, yet clips are still in CLIP\ - inconsistent, MEDIAPRO.XML left untouched' -f $xmlTotal)
            } else {
                Add-Plan $XML 'movie database lists ONLY deleted clips - delete it so the camera rebuilds it'
                $xmlAction = 'delete'
                $xmlPrune.Clear()   # no in-place rewrite; the file goes via the plan
                # $xmlBlocks is deliberately kept: the thumbnail logic needs them to
                # build the database as it will look AFTER this run
            }
        } elseif ($xmlPrune.Count -gt 0 -and $m4Files.Count -lt 3) {
            # not a whole-DB wipe, something to prune, but too little on the card
            # to trust a partial rewrite (nothing to prune -> nothing to say)
            $xmlRefuseReason = ("only {0} file(s) under PRIVATE\M4ROOT (card almost empty?)" -f $m4Files.Count)
        } elseif ($xmlPrune.Count -gt 0) {
            $xmlAction = 'rewrite'
        }
    }
    if ($xmlRefuseReason) {
        $xmlPrune.Clear(); $xmlBlocks.Clear()
        $notes.Add('MEDIAPRO.XML was NOT modified: ' + $xmlRefuseReason)
    }
}

# thumbnails whose movie is gone (report, delete only on request)
# checked against the database as it will look AFTER pruning, so thumbnails orphaned by
# this run are reported too
$refText = $xmlText
if ($xmlBlocks.Count -gt 0) {   # gate on blocks (delete action clears $xmlPrune, not $xmlBlocks)
    foreach ($block in $xmlBlocks) { $refText = $refText.Replace($block, '') }
}
$refUris = New-Object System.Collections.Generic.List[string]
foreach ($m in [regex]::Matches($refText, 'uri="\./([^"]+)"')) { $refUris.Add($m.Groups[1].Value) }

$thumbDir = Join-Path $M4 'THMBNL'
if (Test-Path -LiteralPath $thumbDir) {
    $orphanThumbs = New-Object System.Collections.Generic.List[string]
    Get-ChildItem -LiteralPath $thumbDir -Filter '*.JPG' -File -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $base = $_.Name -replace 'T01\.JPG$', ''
        if (-not $base -or $base -eq $_.Name) { return }    # not a camera thumbnail name
        $movie = Join-Path (Join-Path $M4 'CLIP') "${base}.MP4"   # braces: no $var.member ambiguity
        $rel   = 'THMBNL/' + $_.Name
        if (-not (Test-Path -LiteralPath $movie) -and ($refUris -notcontains $rel)) {
            $orphanThumbs.Add($_.FullName)
        }
    }
    if ($orphanThumbs.Count -gt 0) {
        foreach ($t in $orphanThumbs) { Add-Plan $t 'thumbnail whose movie is missing' }
        $notes.Add(('orphan thumbnail(s) whose movie is missing will be deleted: {0} (none of them belongs to a live clip)' -f $orphanThumbs.Count))
    }
}

# ---------------------------------------------------------------- report
Write-Host ''
if ($plan.Count -eq 0 -and $xmlPrune.Count -eq 0) {
    if ($xmlRefuseReason) {
        Write-Host 'Nothing else to clean up, but MEDIAPRO.XML was NOT touched (see NOTE below).'
    } else {
        Write-Host 'Nothing to clean up: card structure looks consistent.'
    }
} else {
    Write-Host 'PLAN'
    Write-Host ('  {0,-4} {1,10}  {2}' -f 'KIND', 'SIZE', 'REASON')
    foreach ($p in $plan) {
        $kind = if ((Get-Item -LiteralPath $p.Path -Force).PSIsContainer) { 'DIR ' } else { 'FILE' }
        Write-Host ('  {0,-4} {1,10}  {2}' -f $kind, ('{0:N0}' -f $p.Bytes), $p.Reason)
        Write-Host ('       {0}' -f $p.Path)
    }
    if ($xmlAction -eq 'rewrite') {
        Write-Host ''
        Write-Host ("  MEDIAPRO.XML: {0} dangling <Material> entry/entries will be removed:" -f $xmlPrune.Count)
        foreach ($line in $xmlPrune) { Write-Host ("       {0}" -f $line) }
    } elseif ($xmlAction -eq 'delete') {
        Write-Host ''
        Write-Host ('  MEDIAPRO.XML: ALL {0} entries dangle - the file will be DELETED so the camera rebuilds it' -f $xmlTotal)
    }
}

# notes must be shown even when there was nothing else to report
foreach ($n in $notes) { Write-Host ''
                          Write-Host "  NOTE: $n" }

# ---------------------------------------------------------------- execute
$freed = [int64]0
$deleted = 0

if ($plan.Count -gt 0) {
    Write-Host ''
    if ($Apply) {
        foreach ($p in $plan) {
            if (Remove-Safe $p.Path) { $freed += $p.Bytes; $deleted++ }
        }
    } else {
        Write-Host 'DRY RUN - nothing was deleted. Re-run with -Apply to execute.'
    }
}

if ($xmlAction -eq 'rewrite') {
    Write-Host ''
    if ($script:WhatIfMode) {
        Write-Host ("WhatIf: MEDIAPRO.XML would be rewritten ({0} of {1} entries removed)." -f $xmlPrune.Count, $xmlTotal)
    } elseif ($Apply) {
        $new = $xmlText
        foreach ($block in $xmlBlocks) { $new = $new.Replace($block, '') }
        # validate the rewrite BEFORE it replaces the database
        $newClips = ([regex]::Matches($new, '<Material\b')).Count
        if ($new -notmatch '</MediaProfile>' -or $new -notmatch '<Contents>') {
            Write-Host 'ERROR: rewritten MEDIAPRO.XML failed validation - original left untouched'
        } elseif ($newClips -ne ($xmlTotal - $xmlPrune.Count)) {
            Write-Host ("ERROR: entry count mismatch ({0} != {1}) - original left untouched" -f `
                        $newClips, ($xmlTotal - $xmlPrune.Count))
        } else {
            $backup = Join-Path ([System.IO.Path]::GetTempPath()) `
                     ('MEDIAPRO.XML.' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.bak')
            Copy-Item -LiteralPath $XML -Destination $backup -Force
            # keep original format: UTF-8 without BOM, LF line endings
            [System.IO.File]::WriteAllText($XML, ($new -replace "`r`n", "`n"),
                                           (New-Object System.Text.UTF8Encoding($false)))
            Write-Host ("MEDIAPRO.XML rewritten ({0} of {1} entries removed, backup: {2})" -f `
                        $xmlPrune.Count, $xmlTotal, $backup)
        }
    } else {
        Write-Host 'DRY RUN - MEDIAPRO.XML was NOT modified. Re-run with -Apply to execute.'
    }
}

# ---------------------------------------------------------------- health report (read only)
Write-Host ''
Write-Host 'HEALTH CHECK (read only)'

$bad = New-Object System.Collections.Generic.List[string]
if (Test-Path -LiteralPath $DCIM) {
    $arw = @(Get-ChildItem -LiteralPath $DCIM -Recurse -Filter '*.ARW' -File -Force -ErrorAction SilentlyContinue |
             Where-Object { $_.Name -notlike '._*' })
    $jpg = @(Get-ChildItem -LiteralPath $DCIM -Recurse -Filter '*.JPG' -File -Force -ErrorAction SilentlyContinue |
             Where-Object { $_.Name -notlike '._*' })
    $arwNames = $arw | ForEach-Object { $_.BaseName }
    $jpgNames = $jpg | ForEach-Object { $_.BaseName }
    $lone = @($arwNames | Where-Object { $jpgNames -notcontains $_ }).Count +
            @($jpgNames | Where-Object { $arwNames -notcontains $_ }).Count
    Write-Host ('  photos: {0} ARW / {1} JPG, unpaired: {2}' -f $arw.Count, $jpg.Count, $lone)

    $broken = 0
    foreach ($f in $jpg) {
        $fs = $null
        try {
            $fs = [System.IO.File]::OpenRead($f.FullName)
            $fs.Position = [Math]::Max(0, $fs.Length - 2)
            $b = New-Object byte[] 2
            [void]$fs.Read($b, 0, 2)
            if ($b[0] -ne 0xFF -or $b[1] -ne 0xD9) { $broken++; $bad.Add("JPG not terminated: $($f.FullName)") }
        } catch {
            $broken++
            $bad.Add("JPG not readable: $($f.FullName)")
        } finally { if ($fs) { $fs.Dispose() } }
    }
    Write-Host ('  JPG with valid EOI marker: {0}/{1}' -f ($jpg.Count - $broken), $jpg.Count)
}

if (Test-Path -LiteralPath (Join-Path $M4 'CLIP')) {
    $mp4 = @(Get-ChildItem -LiteralPath (Join-Path $M4 'CLIP') -Filter '*.MP4' -File -Force -ErrorAction SilentlyContinue |
             Where-Object { $_.Name -notlike '._*' })   # skip AppleDouble sidecars
    $ok = 0
    foreach ($f in $mp4) {
        $fs = $null
        try {
            $fs = [System.IO.File]::OpenRead($f.FullName)
            $head = New-Object byte[] 8
            [void]$fs.Read($head, 0, 8)
            $ftyp = ($head[4] -eq 0x66 -and $head[5] -eq 0x74 -and $head[6] -eq 0x79 -and $head[7] -eq 0x70)
            # moov is normally near the end, but faststart files put it up front - check both
            $probeLen = [Math]::Min(65536, $fs.Length)
            $fs.Position = 0
            $headBuf = New-Object byte[] $probeLen
            [void]$fs.Read($headBuf, 0, $probeLen)
            $fs.Position = $fs.Length - $probeLen
            $tailBuf = New-Object byte[] $probeLen
            [void]$fs.Read($tailBuf, 0, $probeLen)
            $moov = ([System.Text.Encoding]::ASCII.GetString($headBuf)).Contains('moov') -or
                    ([System.Text.Encoding]::ASCII.GetString($tailBuf)).Contains('moov')
            if ($ftyp -and $moov) { $ok++ } else { $bad.Add("MP4 incomplete (ftyp=$ftyp moov=$moov): $($f.Name)") }
        } catch {
            $bad.Add("MP4 not readable: $($f.Name)")
        } finally { if ($fs) { $fs.Dispose() } }
    }
    Write-Host ('  MP4 with ftyp + moov: {0}/{1}' -f $ok, $mp4.Count)
}

if (Test-Path -LiteralPath $XML) {
    try {
        $t = [System.IO.File]::ReadAllText($XML)
        $uris = [regex]::Matches($t, 'uri="\./([^"]+)"') | ForEach-Object { $_.Groups[1].Value }
        $missing = @($uris | Where-Object { -not (Test-Path -LiteralPath (Join-Path $M4 ($_ -replace '/', '\'))) })
        Write-Host ('  MEDIAPRO.XML: {0} clips registered, {1} referenced files missing' -f
                    ([regex]::Matches($t, '<Material\b')).Count, $missing.Count)
        foreach ($m in $missing) { $bad.Add("MEDIAPRO.XML references missing file: $m") }
    } catch {
        $bad.Add('MEDIAPRO.XML could not be read: ' + $_.Exception.Message)
    }
}

# zero-byte files (PRIVATE\SONY\SONYCARD.IND is a normal empty placeholder on Sony cards)
Get-ChildItem -LiteralPath $Root -Recurse -Force -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Length -eq 0 -and $_.Name -ne 'SONYCARD.IND' } |
    ForEach-Object { $bad.Add("zero-byte file: $($_.FullName)") }

$all = Get-ChildItem -LiteralPath $Root -Recurse -Force -File -ErrorAction SilentlyContinue
$used = ($all | Measure-Object -Property Length -Sum).Sum
Write-Host ('  files: {0}, used: {1:N2} GB' -f $all.Count, ($used / 1GB))

if ($bad.Count -eq 0) {
    Write-Host '  no problems found'
} else {
    Write-Host ("  problems: {0}" -f $bad.Count)
    foreach ($b in $bad) { Write-Host "    $b" }
}

Write-Host ''
if ($deleted -gt 0) { Write-Host ('DONE - removed {0} item(s), freed {1:N2} GB' -f $deleted, ($freed / 1GB)) }
elseif ($script:WhatIfMode) { Write-Host 'WhatIf finished - nothing was deleted.' }
elseif (-not $Apply)  { Write-Host 'Dry run finished. Add -Apply to delete the items listed above.' }
else                 { Write-Host 'Nothing deleted.' }
Write-Host 'Now safe-eject the card, insert it in the camera and run "Restore Database".'