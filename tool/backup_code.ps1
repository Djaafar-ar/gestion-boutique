# Makes a .zip backup of the project's CODE and copies it to a folder you
# choose (USB stick, or your Google Drive folder on the PC).
#
# Run from the project folder:   .\tool\backup_code.ps1
# Choose another folder:         .\tool\backup_code.ps1 -Choose
#
# What is inside: every project file, plus the git history (.git folder),
# so every version can be brought back.
# What is NEVER inside: the build folders, the keys folder
# (C:\Users\Medvich\keys), android\key.properties, keystores and
# passwords. The script checks the .zip before copying it and stops if
# anything secret got in.
#
# The signing keys are backed up separately (see "Release signing" in
# PLAN.md): keep them on their own USB stick.

param([switch]$Choose)

$ErrorActionPreference = 'Stop'
$project = Split-Path $PSScriptRoot -Parent
Set-Location $project
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Where the backups go: asked once, then remembered on this PC (the file
# is not part of the project, see .gitignore).
$remember = Join-Path $project 'tool\backup_destination.txt'
$destination = $null
if (-not $Choose -and (Test-Path $remember)) {
    $destination = (Get-Content $remember -Raw).Trim()
}
if (-not $destination -or -not (Test-Path $destination)) {
    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = 'Choose where to copy the code backup (USB stick or Google Drive folder)'
    if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
        throw 'No folder chosen: nothing was copied.'
    }
    $destination = $dialog.SelectedPath
    Set-Content -Path $remember -Value $destination -Encoding UTF8
}

# Files that must never leave the PC in a code backup.
$forbidden = @(
    '(^|/)key\.properties$', '\.jks$', '\.keystore$', '\.p12$', '\.pem$',
    'lineage', 'password', '(^|/)\.env$', '(^|/)keys/', 'backup_destination\.txt$'
)
function Test-Secret([string]$path) {
    $p = $path.Replace('\', '/').ToLower()
    foreach ($rule in $forbidden) { if ($p -match $rule) { return $true } }
    return $false
}

# The project files: what git tracks, plus new files not ignored by
# .gitignore (so build folders and keys are left out).
$files = @(git -c core.quotepath=off ls-files --cached --others --exclude-standard)
if ($LASTEXITCODE -ne 0) { throw 'git is needed to list the project files.' }
$files = $files | Where-Object { (Test-Path -LiteralPath $_ -PathType Leaf) -and -not (Test-Secret $_) }
# The git history (no secret was ever committed: checked below anyway).
$history = Get-ChildItem -Recurse -File -Force .git | ForEach-Object {
    $_.FullName.Substring($project.Length + 1).Replace('\', '/')
}

$stamp = Get-Date -Format 'yyyy-MM-dd_HHmm'
$name = "gestion-boutique-code_$stamp.zip"
$zipPath = Join-Path $env:TEMP $name
if (Test-Path $zipPath) { Remove-Item $zipPath }

Write-Host "1/3 Making $name ..."
$zip = [System.IO.Compression.ZipFile]::Open($zipPath, 'Create')
try {
    foreach ($file in @($files) + @($history)) {
        $entry = $file.Replace('\', '/')
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip, (Join-Path $project $file), $entry, 'Optimal') | Out-Null
    }
} finally {
    $zip.Dispose()
}

Write-Host '2/3 Checking that no key or password is inside...'
# The real passwords, to search for them in the files.
$secrets = @()
$props = 'android\key.properties'
if (Test-Path $props) {
    foreach ($line in Get-Content $props) {
        if ($line -match '^\s*\w*[Pp]assword\s*=\s*(.+)$') { $secrets += $Matches[1].Trim() }
    }
}
$problems = @()
$zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
try {
    foreach ($entry in $zip.Entries) {
        if ((Test-Secret $entry.FullName) -and -not $entry.FullName.StartsWith(".git/")) {
            $problems += $entry.FullName
            continue
        }
        if ($secrets.Count -eq 0 -or $entry.FullName.StartsWith('.git/') -or $entry.Length -gt 5MB) { continue }
        $reader = New-Object System.IO.StreamReader($entry.Open())
        try { $text = $reader.ReadToEnd() } finally { $reader.Dispose() }
        foreach ($secret in $secrets) {
            if ($text.Contains($secret)) { $problems += "$($entry.FullName) (contains a password)" }
        }
    }
} finally {
    $zip.Dispose()
}
if ($problems.Count -gt 0) {
    Remove-Item $zipPath
    throw "STOPPED, nothing copied. Secret found in: $(($problems | Select-Object -Unique) -join ', ')"
}

Write-Host "3/3 Copying to $destination ..."
Copy-Item $zipPath (Join-Path $destination $name)
Remove-Item $zipPath
$size = [math]::Round((Get-Item (Join-Path $destination $name)).Length / 1MB, 1)
Write-Host ''
Write-Host "Done: $(Join-Path $destination $name) ($size MB, $(@($files).Count) project files + git history)"
