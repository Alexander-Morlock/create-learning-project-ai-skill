# Purpose: safely retrieve the current shared learning rules from the skill repository.
# The script downloads and verifies the source, then saves it to
# .learning-rules\incoming\<git-hash>.md; it does not modify AGENTS.md or course files.
#
# Why the checks matter: updating shared rules must not silently overwrite learner
# edits or accept a tampered file from GitHub.
#
# Usage: run .\update-learning-rules.ps1 from the learning project root, then ask
# Copilot to compare the staged source with the LEARNING-RULES block, translate
# changes into the course language, and show a diff before applying them.
# For older projects without the block, the script reports that a one-time migration is needed.

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Anchor all file operations to the directory containing this script.
$projectRoot = [System.IO.Path]::GetFullPath($PSScriptRoot)
$agentsPath = Join-Path $projectRoot 'AGENTS.md'
$stageDirectory = Join-Path $projectRoot '.learning-rules\incoming'
$sourcePath = '.github/skills/create-learning-project/assets/learning-rules.md'
$sourceUri = 'https://api.github.com/repos/Alexander-Morlock/create-learning-project-ai-skill/contents/{0}?ref=main' -f $sourcePath

# Check target paths before requesting or writing data: links could redirect writes
# outside the learning project.
if (-not (Test-Path -LiteralPath $agentsPath -PathType Leaf)) {
    throw "AGENTS.md was not found in project root: $projectRoot"
}

$agentsItem = Get-Item -LiteralPath $agentsPath -Force
if (($agentsItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
    throw 'AGENTS.md is a symlink or reparse point. Refusing to continue.'
}

if (Test-Path -LiteralPath (Join-Path $projectRoot '.learning-rules') -PathType Leaf) {
    throw '.learning-rules exists as a file; refusing to replace it.'
}

if (Test-Path -LiteralPath (Join-Path $projectRoot '.learning-rules') -PathType Container) {
    $rulesDirectory = Get-Item -LiteralPath (Join-Path $projectRoot '.learning-rules') -Force
    if (($rulesDirectory.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw '.learning-rules is a symlink or reparse point. Refusing to write outside the project.'
    }
}

# The GitHub Contents API returns base64-encoded content and its Git blob SHA.
# Verify both the response format and the integrity of the downloaded bytes.
$headers = @{
    Accept = 'application/vnd.github+json'
    'X-GitHub-Api-Version' = '2022-11-28'
    'User-Agent' = 'create-learning-project-rules-updater'
}
$response = Invoke-RestMethod -Uri $sourceUri -Headers $headers -Method Get

if ($response.encoding -ne 'base64' -or $response.sha -notmatch '^[0-9a-f]{40}$') {
    throw 'GitHub returned an unexpected source format or blob hash.'
}

$base64 = ($response.content -replace '\s', '')
$sourceBytes = [System.Convert]::FromBase64String($base64)
if ($sourceBytes.Length -eq 0 -or $sourceBytes.Length -gt 262144) {
    throw 'The learning-rules source is empty or larger than the 256 KB safety limit.'
}

$blobHeader = [System.Text.Encoding]::ASCII.GetBytes("blob $($sourceBytes.Length)`0")
$blobBytes = New-Object byte[] ($blobHeader.Length + $sourceBytes.Length)
[System.Array]::Copy($blobHeader, 0, $blobBytes, 0, $blobHeader.Length)
[System.Array]::Copy($sourceBytes, 0, $blobBytes, $blobHeader.Length, $sourceBytes.Length)
$sha1 = [System.Security.Cryptography.SHA1]::Create()
try {
    $actualSha = ([System.BitConverter]::ToString($sha1.ComputeHash($blobBytes))).Replace('-', '').ToLowerInvariant()
}
finally {
    $sha1.Dispose()
}

if ($actualSha -ne $response.sha) {
    throw 'The downloaded source failed its Git blob hash check.'
}

# Validate UTF-8 and the expected heading so an empty or unexpected response is not
# staged, even if the API response itself is well-formed.
$utf8 = New-Object System.Text.UTF8Encoding($false, $true)
$sourceText = $utf8.GetString($sourceBytes)
if (-not $sourceText.StartsWith("# Shared Learning Rules", [System.StringComparison]::Ordinal)) {
    throw 'The downloaded file does not look like the expected learning-rules source.'
}

$agentsText = [System.IO.File]::ReadAllText($agentsPath, $utf8)
$startMatches = [regex]::Matches($agentsText, '<!-- LEARNING-RULES:START\b')
$endMatches = [regex]::Matches($agentsText, '<!-- LEARNING-RULES:END -->')

# Validate the managed-block markers and checksum before creating the staging
# directory. If the learner edited the block manually, stop so those changes can
# be reviewed and preserved first.
if ($startMatches.Count -ne $endMatches.Count -or $startMatches.Count -gt 1) {
    throw 'AGENTS.md has missing or duplicate learning-rules markers. No files were changed.'
}

$currentVersion = $null
if ($startMatches.Count -eq 1) {
    $startIndex = $startMatches[0].Index
    $endIndex = $endMatches[0].Index
    if ($endIndex -lt $startIndex) {
        throw 'AGENTS.md learning-rules markers are out of order. No files were changed.'
    }
    $lineStart = $agentsText.LastIndexOf("`n", $startIndex)
    if ($lineStart + 1 -ne $startIndex) {
        throw 'The learning-rules start marker must be on its own line. No files were changed.'
    }
    $lineEnd = $agentsText.IndexOf("`n", $startIndex)
    if ($lineEnd -lt 0 -or $lineEnd -ge $endIndex) {
        throw 'The learning-rules start marker must be followed by a separate block body. No files were changed.'
    }
    $markerLine = $agentsText.Substring($startIndex, $lineEnd - $startIndex).TrimEnd("`r")
    if ($markerLine -notmatch 'version=([^\s>]+)') {
        throw 'The learning-rules start marker has no version value. No files were changed.'
    }
    $currentVersion = $Matches[1]

    $checksumMatch = [regex]::Match($markerLine, 'sha256=([0-9a-fA-F]{64})(?:\s|$)')
    if (-not $checksumMatch.Success) {
        throw 'The learning-rules start marker has no valid sha256 value. Add a checksum after reviewing the managed block.'
    }
    if ($endIndex -eq 0 -or $agentsText[$endIndex - 1] -ne "`n") {
        throw 'The learning-rules end marker must be on its own line. No files were changed.'
    }

    $managedBody = $agentsText.Substring($lineEnd + 1, $endIndex - $lineEnd - 1)
    $normalizedBody = $managedBody.Replace("`r`n", "`n").Replace("`r", "`n")
    $managedBytes = [System.Text.Encoding]::UTF8.GetBytes($normalizedBody)
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $actualChecksum = ([System.BitConverter]::ToString($sha256.ComputeHash($managedBytes))).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $sha256.Dispose()
    }
    if ($actualChecksum -cne $checksumMatch.Groups[1].Value.ToLowerInvariant()) {
        throw "AGENTS.md has local edits in the managed learning-rules block (expected $($checksumMatch.Groups[1].Value), found $actualChecksum). Reconcile them before updating; no files were changed."
    }
}

# Validate the destination and refuse to write through a symlink or junction.
if (-not (Test-Path -LiteralPath $stageDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $stageDirectory | Out-Null
}

$stageDirectoryItem = Get-Item -LiteralPath $stageDirectory -Force
if (($stageDirectoryItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
    throw '.learning-rules\incoming is a symlink or reparse point. Refusing to write outside the project.'
}

$stagedFileName = "$($response.sha).md"
$stagedPath = Join-Path $stageDirectory $stagedFileName
if (Test-Path -LiteralPath $stagedPath) {
    # A file with the same Git hash must contain the same bytes; never replace a mismatch.
    $stagedItem = Get-Item -LiteralPath $stagedPath -Force
    if (($stagedItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw 'The staged source path is a symlink or reparse point. Refusing to continue.'
    }
    $existingBytes = [System.IO.File]::ReadAllBytes($stagedPath)
    if ([System.Convert]::ToBase64String($existingBytes) -cne [System.Convert]::ToBase64String($sourceBytes)) {
        throw "The existing staged file differs from the verified source: $stagedPath"
    }
}
else {
    # CreateNew prevents overwriting a file created between the check and the write.
    $stream = [System.IO.File]::Open(
        $stagedPath,
        [System.IO.FileMode]::CreateNew,
        [System.IO.FileAccess]::Write,
        [System.IO.FileShare]::None
    )
    try {
        $stream.Write($sourceBytes, 0, $sourceBytes.Length)
    }
    finally {
        $stream.Dispose()
    }
}

# Report where the verified source was staged and that a manual review is required.
# AGENTS.md remains untouched.
Write-Output "Verified learning-rules source: $($response.sha)"
Write-Output "Staged without changing AGENTS.md: $stagedPath"
if ($startMatches.Count -eq 0) {
    Write-Output 'Legacy project detected: AGENTS.md has no managed block.'
}
else {
    Write-Output "Current managed-block version: $currentVersion"
}

Write-Output ''
Write-Output 'Review the staged file in Copilot and ask it to localize the changes into the managed block in the course language.'
Write-Output 'Require a proposed AGENTS.md diff first. Preserve learner-specific content and do not apply changes until approved.'
