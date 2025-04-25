....
powerShell {
    name = "Build Backend + Deploy to AWS environment"
    id = "Build_Backend_Deploy_to_AWS_environment"

    conditions {
        equals("BackendDeploy", "true")
    }
    scriptMode = script {
        content = """
            # --- Set Variables ---
            ${'$'}changelist = "%system.build.vcs.number%"
            ${'$'}my_tag_name = "dev-${'$'}changelist"
            ${'$'}checkoutDir = "%system.teamcity.build.checkoutDir%"
            #${'$'}projectRoot = "${'$'}checkoutDir\COMPASS\Projects\project_Hands"
            ${'$'}infrastructurePath = "${'$'}checkoutDir\Infrastructure"
            ${'$'}configureScript = "${'$'}checkoutDir\Scripts\configure_build.ps1"
            ${'$'}buildScript = "${'$'}infrastructurePath\Scripts\build_dedicated_server.ps1"
            ${'$'}postBadge = "${'$'}checkoutDir\Engine\Source\Programs\UnrealGameSync\PostBadgeStatus\bin\Release\PostBadgeStatus.exe"
            ${'$'}ugsRestUrl = "http://uesyncvm"
            ${'$'}ugsProjectPath = "${'$'}perforceProjectPath"
            ${'$'}buildUrl = "${'$'}BuildURL"
            
            # --- UGS Badge: Starting ---
            if (${'$'}env:BUILD_IS_PERSONAL -eq "true") {
                Write-Output "Personal Build - Skipping UGS Badge"
            } else {
                & "${'$'}postBadge" -Name="AWS" -Change=${'$'}changelist -Project=${'$'}ugsProjectPath -RestUrl=${'$'}ugsRestUrl -Status="Starting" -Url=${'$'}buildUrl
            }
            
            # --- Test AWS Credentials ---
            aws sts get-caller-identity --profile default
            if (${'$'}LASTEXITCODE -ne 0) {
                Write-Error "AWS credentials failed."
                Exit 1
            }
            
            # --- Test Docker Installation ---
            docker --version
            if (${'$'}LASTEXITCODE -ne 0) {
                Write-Error "Docker not installed or not in PATH."
                Exit 1
            }
            
            # --- Configure Build ---
            Write-Output "Changing directory to: ${'$'}checkoutDir"
            Set-Location ${'$'}checkoutDir
            
            Write-Output "Configuring build with tag: ${'$'}my_tag_name"
            Write-Output "Current Directory: ${'$'}(Get-Location)"
            & ${'$'}configureScript ${'$'}my_tag_name
            if (${'$'}LASTEXITCODE -ne 0) {
                goto :HandleError
            }
            
            # --- Build Server ---
            Write-Output "Changing directory to: ${'$'}infrastructurePath"
            Set-Location ${'$'}infrastructurePath
            
            Write-Output "Building dedicated server with tag: ${'$'}my_tag_name"
            Write-Output "Current Directory: ${'$'}(Get-Location)"
            & ${'$'}buildScript ${'$'}my_tag_name
            if (${'$'}LASTEXITCODE -ne 0) {
                goto :HandleError
            }
            
            # --- UGS Badge: Success ---
            if (${'$'}env:BUILD_IS_PERSONAL -eq "true") {
                Write-Output "Personal Build - Skipping UGS Badge"
            } else {
                & "${'$'}postBadge" -Name="AWS" -Change=${'$'}changelist -Project=${'$'}ugsProjectPath -RestUrl=${'$'}ugsRestUrl -Status="Success" -Url=${'$'}buildUrl
            }
            Exit 0
            
            :HandleError
            # --- UGS Badge: Failure ---
            if (${'$'}env:BUILD_IS_PERSONAL -eq "true") {
                Write-Output "Personal Build - Skipping UGS Badge"
            } else {
                & "${'$'}postBadge" -Name="AWS" -Change=${'$'}changelist -Project=${'$'}ugsProjectPath -RestUrl=${'$'}ugsRestUrl -Status="Failure" -Url=${'$'}buildUrl
            }
            Exit 1
        """.trimIndent()
    }
}
.....