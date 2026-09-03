$targetGame = "Unnamed Pogo Game"
$internalModPath = "res://mod.gd"

$tempDir = "$env:TEMP\cheater"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
New-Item -ItemType Directory -Path "$tempDir\mod" -Force | Out-Null
New-Item -ItemType Directory -Path "$tempDir\decomp" -Force | Out-Null

echo "Downloading mod scripts..."
$githubModScript = "https://raw.githubusercontent.com/AndrewCromar/cheater/main/mod.gd"
$githubSnippetScript = "https://raw.githubusercontent.com/AndrewCromar/cheater/main/snippet.gd"
$modFile = "$tempDir\mod\mod.gd"
$snippetFile = "$tempDir\mod\snippet.gd"
Invoke-WebRequest -Uri $githubModScript -OutFile $modFile
Invoke-WebRequest -Uri $githubSnippetScript -OutFile $snippetFile
echo "Done."

echo "Downloading GDRE Tools..."
$releaseApi = "https://api.github.com/repos/GDRETools/gdsdecomp/releases/latest"
$latestRelease = Invoke-RestMethod -Uri $releaseApi -Headers @{"User-Agent"="PowerShell"}
$zipUrl = ($latestRelease.assets | Where-Object { $_.name -like "*windows*.zip" } | Select-Object -First 1).browser_download_url
$gdreZipPath = "$tempDir\gdre.zip"
Invoke-WebRequest -Uri $zipUrl -OutFile $gdreZipPath
Expand-Archive -Path $gdreZipPath -DestinationPath $tempDir -Force
$gdreExe = (Get-ChildItem -Path $tempDir -Recurse -Filter "*.exe" | Select-Object -First 1).FullName
echo "Done."

echo "Finding game files..."
$pckPath = $null
$steamPath = (Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath
if (-not $steamPath) {
    $steamPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -ErrorAction SilentlyContinue).InstallPath
}
$libraryFolders = @($steamPath)
$vdfPath = "$steamPath\steamapps\libraryfolders.vdf"
if (Test-Path $vdfPath) {
    $extraPaths = Get-Content $vdfPath | 
        Select-String '"path"\s+"([^"]+)"' | 
        ForEach-Object { $_.Matches.Groups[1].Value -replace '\\\\', '\' }
    $libraryFolders += $extraPaths
}
$appId = "4925300" 
$manifestPath = $libraryFolders | ForEach-Object {
    "$_\steamapps\appmanifest_$appId.acf"
} | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($manifestPath) {
    $installDir = (Get-Content $manifestPath | Select-String '"installdir"\s+"([^"]+)"').Matches.Groups[1].Value
    $libraryPath = Split-Path (Split-Path $manifestPath -Parent) -Parent
    $pckPath = "$libraryPath\steamapps\common\$installDir\$installDir.pck"
}
echo "Done."

echo "Decompiling pck..."
$decompDir = "$tempDir\decomp"
$recoverProc = Start-Process -FilePath $gdreExe -ArgumentList "--headless --recover=`"$pckPath`" --output=`"$decompDir`"" -NoNewWindow -PassThru
$recoverProc.WaitForExit()
if (Test-Path "$decompDir\project.godot") {
    Write-Host "Successfully extracted project files to: $decompDir" -ForegroundColor Green
} else {
    Write-Host "Error: Failed to extract project files." -ForegroundColor Red
}
echo "Done."

echo "Modifying target script..."
$targetScriptPath = "$decompDir\Scripts\Menu.gd"
if (Test-Path $targetScriptPath) {
    $scriptContent = Get-Content $targetScriptPath -Raw
    $snippetContent = Get-Content $snippetFile -Raw
    $readyPattern = '(?m)^(\s*func\s+_ready\s*\([^)]*\)\s*(?:->\s*[^:]+)?\s*:)'
    if ($scriptContent -match $readyPattern) {
        $modifiedContent = [regex]::Replace($scriptContent, $readyPattern, '${1}' + "`r`n$snippetContent")
        Set-Content -Path $targetScriptPath -Value $modifiedContent -NoNewline
        Write-Host "Successfully injected snippet.gd into Menu.gd!" -ForegroundColor Green
    } else {
        Write-Host "Error: Could not match _ready() signature in Menu.gd." -ForegroundColor Red
    }
} else {
    Write-Host "Error: Target script not found at $targetScriptPath" -ForegroundColor Red
}
echo "Done."

echo "Patching PCK file..."
$relativePath = $targetScriptPath.Substring($decompDir.Length).TrimStart('\', '/') -replace '\\', '/'
$internalScriptPath = "res://$relativePath"
$patchArg1 = "${targetScriptPath}=${internalScriptPath}"
$patchArg2 = "${modFile}=res://mod.gd"
if ($pckPath -and (Test-Path $pckPath)) {
    $patchOutput = Start-Process -FilePath $gdreExe -ArgumentList "--headless --pck-patch=`"$pckPath`" --patch-file=`"$patchArg1`" --patch-file=`"$patchArg2`" --output=`"$pckPath`"" -NoNewWindow -PassThru -RedirectStandardOutput "$tempDir\patch_log.txt"
    $patchOutput.WaitForExit()
    $logContent = Get-Content "$tempDir\patch_log.txt" -ErrorAction SilentlyContinue
    if ($logContent -match "Patched PCK file") {
        Write-Host "Successfully patched $pckPath!" -ForegroundColor Green
    } else {
        Write-Host "Error: GDRE failed to patch the PCK archive." -ForegroundColor Red
    }
} else {
    Write-Host "Error: Game PCK path not found." -ForegroundColor Red
}

echo "Done."

echo "Cleaning up files."
Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue