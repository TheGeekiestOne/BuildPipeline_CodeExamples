@echo off
setlocal enableextensions
set TERM=

:: Set the path to the Cygwin binary
set "CYGWIN_PATH=C:\cygwin64\bin"

:: Capture arguments from TeamCity
set "GAME_DEPLOYMENT_NAME=%1"
set "AWS_ACCESS_KEY_ID=%2"
set "AWS_SECRET_ACCESS_KEY=%3"
set "AWS_DEFAULT_REGION=%4"
set "CDK_DEFAULT_ACCOUNT=%5"
set "GAME_BUILD_VERSION=%6"

:: Write the variables to a temp file
echo export GAME_DEPLOYMENT_NAME='%GAME_DEPLOYMENT_NAME%' > C:\cygwin64\home\Build\tmp\env_vars.sh
echo export AWS_ACCESS_KEY_ID='%AWS_ACCESS_KEY_ID%' >> C:\cygwin64\home\Build\tmp\env_vars.sh
echo export AWS_SECRET_ACCESS_KEY='%AWS_SECRET_ACCESS_KEY%' >> C:\cygwin64\home\Build\tmp\env_vars.sh
echo export AWS_DEFAULT_REGION='%AWS_DEFAULT_REGION%' >> C:\cygwin64\home\Build\tmp\env_vars.sh
echo export CDK_DEFAULT_ACCOUNT='%CDK_DEFAULT_ACCOUNT%' >> C:\cygwin64\home\Build\tmp\env_vars.sh
echo export GAME_BUILD_VERSION='%GAME_BUILD_VERSION%' >> C:\cygwin64\home\Build\tmp\env_vars.sh

:: Dynamically determine the script's directory and convert it to a Cygwin-compatible path
:: Assuming the script will always be run from a directory on the C: drive
set "SCRIPT_PATH=%~dp0"
set "SCRIPT_PATH=%SCRIPT_PATH:~0,-1%"  ; Remove trailing backslash
set "BASE_PATH=%SCRIPT_PATH:C:=/cygdrive/c%"
set "BASE_PATH=%BASE_PATH:\=/%"

:: Use the Cygwin bash to export the variables and start an interactive session
::"%CYGWIN_PATH%\bash" --login -i -c "export GAME_DEPLOYMENT_NAME='$GAME_DEPLOYMENT_NAME'; export AWS_ACCESS_KEY_ID='$AWS_ACCESS_KEY_ID'; export AWS_SECRET_ACCESS_KEY='$AWS_SECRET_ACCESS_KEY'; export AWS_DEFAULT_REGION='$AWS_DEFAULT_REGION'; export CDK_DEFAULT_ACCOUNT='$CDK_DEFAULT_ACCOUNT'; exec bash"
:: Start Cygwin and source the temp file
"%CYGWIN_PATH%\bash" --login -i -c "source /tmp/env_vars.sh; exec bash"