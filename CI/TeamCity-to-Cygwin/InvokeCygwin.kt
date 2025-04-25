....

script {
    name = "Execute for $ReleaseType"
    scriptContent = """
        @echo off
        cd /d %system.teamcity.build.checkoutDir%\Game\Backend
        IF "%env.GAME_DEPLOYMENT_NAME%" == "Dev" (
        	cmd /c CygwinRun.bat "%ReleaseType%" "%env.AWS_ACCESS_KEY_ID%" "%env.AWS_SECRET_ACCESS_KEY%" "%env.AWS_DEFAULT_REGION%" "%env.CDK_DEFAULT_ACCOUNT%" "%env.GAME_BUILD_VERSION%"
        )
    """.trimIndent()
}

.....