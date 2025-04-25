param([Parameter(Mandatory=$true)][string]$Version, [Parameter(Mandatory=$false)][string]$Stream="dev")

Push-Location $PSScriptRoot/../Projects/Config

"
[/Script/AWSBackend.AWSBackendPerBuildSettings]
Stream=$Stream
Version=$Version
" | Out-File -FilePath ".\DefaultAWSBackendPerBuildSettings.ini"

Write-Output "Successfully set stream $Stream version $Version in Project/DefaultAWSBackendPerBuildSettings.ini"

Pop-Location