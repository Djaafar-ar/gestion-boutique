# Builds the release APK and signs it so it can UPDATE the apps already
# installed on the phones (adb install -r keeps their data).
#
# The phones got their first versions signed with the old key (the
# Android debug key). The new release key is "rotated in": the APK carries
# the signed proof (lineage) that the old key handed over to the new one.
#
# Run from the project folder:   .\tool\build_release.ps1
# Result: build\app\outputs\flutter-apk\app-release.apk

$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

$propsFile = 'android\key.properties'
if (-not (Test-Path $propsFile)) {
    throw "android\key.properties is missing: the release key is not set up on this PC."
}
$props = @{}
foreach ($line in Get-Content $propsFile) {
    if ($line -match '^\s*([^#=]+?)\s*=\s*(.*)$') { $props[$Matches[1]] = $Matches[2] }
}
foreach ($file in @($props.storeFile, $props.oldStoreFile, $props.lineageFile)) {
    if (-not (Test-Path $file)) { throw "Missing signing file: $file (restore it from the USB backup)." }
}

$buildTools = Get-ChildItem "$env:LOCALAPPDATA\Android\Sdk\build-tools" -Directory |
    Sort-Object { [version]$_.Name } -Descending | Select-Object -First 1
$apksigner = Join-Path $buildTools.FullName 'apksigner.bat'

Write-Host '1/3 Building the release APK...'
flutter build apk --release
if ($LASTEXITCODE -ne 0) { throw 'flutter build failed.' }

$apk = 'build\app\outputs\flutter-apk\app-release.apk'
$signed = 'build\app\outputs\flutter-apk\app-release-rotated.apk'

Write-Host '2/3 Signing with the old key -> release key rotation...'
& $apksigner sign `
    --ks $props.oldStoreFile --ks-key-alias $props.oldKeyAlias `
    --ks-pass "pass:$($props.oldPassword)" --key-pass "pass:$($props.oldPassword)" `
    --next-signer `
    --ks $props.storeFile --ks-key-alias $props.keyAlias `
    --ks-pass "pass:$($props.storePassword)" --key-pass "pass:$($props.keyPassword)" `
    --lineage $props.lineageFile `
    --rotation-min-sdk-version 28 `
    --out $signed $apk
if ($LASTEXITCODE -ne 0) { throw 'apksigner sign failed.' }

Write-Host '3/3 Checking the signature...'
& $apksigner verify --verbose $signed | Select-String 'Verified using|Number of signers'
if ($LASTEXITCODE -ne 0) { throw 'apksigner verify failed.' }

Move-Item -Force $signed $apk
Remove-Item -ErrorAction SilentlyContinue "$apk.sha1"
Write-Host ''
Write-Host "Done: $apk"
Write-Host 'Install on a phone (keeps its data):'
Write-Host "  & `"`$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe`" -s PHONE_CODE install -r $apk"
