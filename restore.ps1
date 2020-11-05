
$vendorDirectory = "vendor"
$contantsTemplateFile = "src\gsudomsi\Constants.Template.wxi"
$contantsFile = "src\gsudomsi\Constants.wxi"

$release = Get-Content -Raw -Path "release.json" | ConvertFrom-Json

$version = $release.Version
$hash = $release.Hash.ToUpper()
$downloadUrl = "https://github.com/gerardog/gsudo/releases/download/v$version/gsudo.v$version.zip"
$outputArchive = "release.zip"
$outputDirectory = "release"

Write-Host "Downloading gsudo from $downloadUrl."
Invoke-WebRequest -UseBasicParsing -Uri $downloadUrl -OutFile $outputArchive

Write-Host "Checking downloaded archive '$outputArchive' for integrity."
$downloadHash = (Get-FileHash -Path $outputArchive -Algorithm SHA256).Hash.ToUpper()
Write-Host "Got $downloadHash, expected $hash."
$hasMatches = $hash -eq $downloadHash

if ($hasMatches)
{
    Write-Host "Archive hash matches, will continue."

    Write-Host "Copying gsudo to the vendor directory."
    Expand-Archive $outputArchive -DestinationPath $outputDirectory -Force
    Copy-Item "$outputDirectory/gsudo.exe" "$vendorDirectory/gsudo.exe"

    Write-Host "Patching constants file."
    $template = Get-Content -Raw -Path $contantsTemplateFile
    ($template).Replace("%VERSION%", $version) | Set-Content $contantsFile

    Write-Host "Solution is now ready for building."
}
else
{
    throw "Archive hash does not match, will fail."
}