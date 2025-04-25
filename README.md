# CI/CD Automation Pipeline Code Examples

## 📂 Folder Structure

### `BackendDeployTeamCity/`
Handles Unreal Engine backend builds and AWS deployments

### `TeamCity-to-Cygwin/`  
Manages Windows-to-Linux environment bridging

---

## 🏗 Backend Deployment (`BackendDeployTeamCity/`)

### Core Files:
- `Build Backend + Deploy to AWS.kt` - Main TeamCity Kotlin DSL definition
- `scripts_used/` - Supporting PowerShell scripts

### Workflow:

1. **Configuration**
   ```powershell
   # configure_build.ps1
   Sets version in DefaultAWSBackendPerBuildSettings.ini
   Parameters: -Version (required), -Stream (optional)
Build Process

powershell
# build_dedicated_server.ps1
Runs UE4 BuildCookRun for Linux servers
Parameters: -ImageTag (required)
Container Deployment

powershell
# _build_and_deploy.ps1
Builds Docker image and pushes to ECR
Parameters: -ImageName, -VersionNumber (required)
Key Features:
Automatic version tagging from VCS

AWS credential validation

UGS badge status updates

## 🌉 Cygwin Bridge (TeamCity-to-Cygwin/)
Core Files:
InvokeCygwin.kt - TeamCity Kotlin step definition

CygwinRun.bat - Windows-to-Cygwin environment setup

Workflow:
batch
:: Converts paths and sets environment
set "BASE_PATH=%SCRIPT_PATH:C:=/cygdrive/c%"
"%CYGWIN_PATH%\bash" --login -i -c "source /tmp/env_vars.sh"
Key Features:
Secure credential passing via temp files

Windows/Linux path translation

Environment variable isolation
