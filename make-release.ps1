param(
    [parameter(Mandatory = $true)]
    [string] $Version
)

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

Write-Host "Checking for sanity."
git diff-index --quiet HEAD --
$clean = $LASTEXITCODE -eq 0
if (-not $clean)
{
    throw "Repository is dirty, will not continue."
}

Write-Host "Searching for the $Version release."

$hashUrl = "https://github.com/gerardog/gsudo/releases/download/v$Version/gsudo.v$Version.zip.sha256"
$response = Invoke-WebRequest $hashUrl -UseBasicParsing
$downloadSuccess = $response.StatusCode -eq "200"
if (-not $downloadSuccess)
{
    throw "Version was not found."
}

$hash = [System.Text.Encoding]::UTF8.GetString($response.Content).Trim()

$release = @{
    Version = $Version
    Hash    = $hash
} | ConvertTo-Json

$release | Out-File -FilePath "./release.json"

Write-Host "Release file updated."

Write-Host "Creating git commit and tag."

git commit -a -m "Upstream release $Version."
git tag $Version