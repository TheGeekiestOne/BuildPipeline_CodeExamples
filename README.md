# CI/CD Automation Pipeline Code Examples

## 📂 Folder Structure

### `package_project.py`  
Manages Windows-to-Linux environment bridging

### `CI\BackendDeployTeamCity/`
Handles Unreal Engine backend builds and AWS deployments

### `CI\TeamCity-to-Cygwin/`  
Manages Windows-to-Linux environment bridging

---
## 🔍 Debug Symbol Processing (`package_project.py`)
Handles Unreal Engine Android symbol files (`libUnreal.so`) for Sentry crash reporting:


```python
   def compress_and_upload_symbols(ndk_path, symbols_path, sentry_cli_path, org, project, auth_token):
    """Compresses and uploads UE debug symbols to Sentry for Android crash reporting"""
```
Key Features:
Sentry Integration: Automates symbol upload for UE Android builds  

NDK Compression: Uses llvm-objcopy to reduce symbol file size by ~60%

CI Ready: Designed for build pipelines with environment variable support

UE-Specific Usage:
Ensure Sentry plugin is installed in your Unreal project

Configure in DefaultEngine.ini:

```ini
[Sentry]
Dsn=https://your-key@sentry.io/your-project
```
Call during Android builds:

```python
compress_and_upload_symbols(
    ndk_path="C:/AndroidNDK",
    symbols_path="Binaries/Android/ARM64",
    sentry_cli_path=find_sentry_cli(),
    org="your-game-studio",
    project="your-ue-project",
    auth_token=os.getenv("SENTRY_AUTH_TOKEN")
```
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
