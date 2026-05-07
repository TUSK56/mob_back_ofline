param(
  [string]$Configuration = "Release",
  [string]$Output = "publish",
  [string]$Runtime = "win-x64",
  [string]$SelfContained = "true"
)

$SelfContained = [System.Convert]::ToBoolean($SelfContained)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectPath = Join-Path $scriptDir "Jobito.Api/Jobito.Api.csproj"

if (-not (Test-Path $projectPath)) {
  throw "Project file not found: $projectPath"
}

if ([System.IO.Path]::IsPathRooted($Output)) {
  $outputDir = $Output
} else {
  $outputDir = Join-Path $scriptDir $Output
}

if (Test-Path $outputDir) {
  Write-Host "Cleaning existing publish folder: $outputDir"
  Get-ChildItem -Path $outputDir -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
} else {
  New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$logsDir = Join-Path $outputDir "logs"
if (-not (Test-Path $logsDir)) {
  New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
}

Write-Host "Publishing $projectPath to $outputDir ..."
Write-Host "Runtime: $Runtime | SelfContained: $SelfContained"

if ([string]::IsNullOrWhiteSpace($Runtime)) {
  dotnet publish $projectPath `
    -c $Configuration `
    --self-contained $SelfContained `
    /p:PublishSingleFile=false `
    -o $outputDir
} else {
  dotnet publish $projectPath `
    -c $Configuration `
    -r $Runtime `
    --self-contained $SelfContained `
    /p:PublishSingleFile=false `
    -o $outputDir
}

# Keep only deploy-relevant root contents (defensive cleanup)
$extraDirs = @("publish_output")
foreach ($dirName in $extraDirs) {
  $dirPath = Join-Path $outputDir $dirName
  if (Test-Path $dirPath) {
    Remove-Item -Recurse -Force $dirPath -ErrorAction SilentlyContinue
  }
}

$extraFiles = @("appsettings.zip")
foreach ($fileName in $extraFiles) {
  $filePath = Join-Path $outputDir $fileName
  if (Test-Path $filePath) {
    Remove-Item -Force $filePath -ErrorAction SilentlyContinue
  }
}

# Ensure logs folder exists for stdout logs in IIS
if (-not (Test-Path $logsDir)) {
  New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
}

# ─── Overwrite web.config for MonsterASP.net (Framework Dependent Mode) ───
# Most compatible mode: using the dotnet runtime provided by the server.
$webConfigContent = @'
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <location path="." inheritInChildApplications="false">
    <system.webServer>
      <handlers>
        <add name="aspNetCore" path="*" verb="*" modules="AspNetCoreModuleV2" resourceType="Unspecified" />
      </handlers>
      <aspNetCore processPath="dotnet"
                  arguments=".\Jobito.Api.dll"
                  stdoutLogEnabled="true"
                  stdoutLogFile=".\logs\stdout"
                  captureStartupErrors="true"
                  hostingModel="outofprocess">
        <environmentVariables>
          <environmentVariable name="ASPNETCORE_ENVIRONMENT" value="Production" />
        </environmentVariables>
      </aspNetCore>
    </system.webServer>
  </location>
</configuration>
'@

$webConfigPath = Join-Path $outputDir "web.config"
Set-Content -Path $webConfigPath -Value $webConfigContent -Encoding UTF8
Write-Host "web.config written (Framework Dependent / dotnet mode)."

Write-Host "Published to $outputDir"
Write-Host ""
Write-Host "======================================================"
Write-Host " Upload the contents of: $outputDir"
Write-Host " to the ROOT of your site on runasp.net"
Write-Host "======================================================"
