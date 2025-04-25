param([Parameter(Mandatory=$true)]$ImageTag)

function CheckLastExitCode {
    param ([int[]]$SuccessCodes = @(0), [scriptblock]$CleanupScript=$null)

    if ($SuccessCodes -notcontains $LastExitCode) {
        if ($CleanupScript) {
            "Executing cleanup script: $CleanupScript"
            &$CleanupScript
        }
        $msg = @"
EXE RETURNED EXIT CODE $LastExitCode
CALLSTACK:$(Get-PSCallStack | Out-String)
"@
        throw $msg
    }
}

# Clean up any old build
# $archiveDirectory .. path works from both Infrastructure and root folders
$archiveDirectory=".\Build\Shipping"
$serverArchiveDirectory="$archiveDirectory\LinuxServer"
if(Test-Path $serverArchiveDirectory)
{
	Remove-Item $serverArchiveDirectory -Force -Recurse
}

# Navigate to root directory as that's where all the Unreal tools assume we are so paths make more sense this way
Push-Location ..

# Build dedicated server
Write-Output "Building Dedicated Server..."
.\Engine\Build\BatchFiles\RunUAT BuildCookRun `
  -project=".\Project\Game.uproject" `
  -nop4 `
  -cook `
  -stage `
  -archive `
  -archivedirectory="$archiveDirectory" `
  -package `
  -pak `
  -prereqs `
  -distribution `
  -nodebuginfo `
  -manifests `
  -targetplatform=Linux `
  -build `
  -utf8output `
  -compile `
  -compressed `
  -unattended `
  -signed `
  -noclient `
  -server `
  -serverconfig=Shipping `
  -target=GameServer
  
#-makebinaryconfig
CheckLastExitCode -CleanupScript { Pop-Location }

# Pop back to Infrastructure directory
Pop-Location

# Strip debug symbols
Write-Output "Stripping debug symbols..."
$stripExe="$env:LINUX_MULTIARCH_ROOT\x86_64-unknown-linux-gnu\bin\x86_64-unknown-linux-gnu-strip.exe"
& $stripExe ..\Build\Shipping\LinuxServer\Game\Binaries\Linux\GameServer-Linux-Shipping
CheckLastExitCode

# Build and deploy container
Write-Output "Building and deploying Container..."
.\Scripts\_build_and_deploy.ps1 -ImageName Game-linux-server -VersionNumber "$ImageTag" -RootPath "../Build/Shipping/LinuxServer" -DockerFilePath ../Containers/LinuxServer/Dockerfile
