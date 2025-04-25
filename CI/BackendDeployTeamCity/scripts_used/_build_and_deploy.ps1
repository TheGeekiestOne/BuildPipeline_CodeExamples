param([Parameter(Mandatory=$true)]$ImageName, [Parameter(Mandatory=$true)]$VersionNumber, $RootPath=".", $ContextPath=".", $DockerFilePath=".", [switch]$ApplyLatestTag, $AWSProfile="default", $AWSRegion="eu-west-1", [switch]$NoCache)

# Get AWS details
$awsIdentityOutput=(aws sts get-caller-identity --output json --profile $AWSProfile) | Out-String | ConvertFrom-Json
$awsAccount=$awsIdentityOutput.Account
$ecrAccount="$awsAccount.ecr.$AWSRegion.amazonaws.com"

# Login to ECR
aws ecr get-login-password --region $AWSRegion --profile $AWSProfile | docker login --username AWS --password-stdin $ecrAccount

# Build Docker Image
Push-Location $RootPath
if($NoCache)
{
	& docker build --no-cache -t ${ImageName}:local -f $DockerFilePath $ContextPath
}
else
{
	& docker build -t ${ImageName}:local -f $DockerFilePath $ContextPath
}
Pop-Location

# Call deploy script
if($ApplyLatestTag)
{
    .\scripts\_deploy_docker_image.ps1 -ImageName $ImageName -ImageTag $VersionNumber -AWSProfile $AWSProfile -ApplyLatestTag
}
else
{
    .\scripts\_deploy_docker_image.ps1 -ImageName $ImageName -ImageTag $VersionNumber -AWSProfile $AWSProfile
}
