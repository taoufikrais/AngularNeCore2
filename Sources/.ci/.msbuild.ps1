Param(
  [string]$sln_filename,
  [string]$publish_profile,
  [string]$nuget_repo
)

$Host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size (400, 25);

# Description :   Fichier exécuté par le conteneur de build pour lancer la build du projet Visual Studio 2017.
# Auteur :        Simon Guidera
# Date :          05/03/2018

function Quit($errno) {
    Write-Host "Exiting .msbuild.ps1 script with return code : $errno";
    EXIT $errno;
}

$ERRNO=0;
$ERROR_NUGET_RESTORE=1;
$ERROR_MSBUILD_PUBLISH=2;

Write-Host "Nuget package restoration : $sln_filename";

# Restauration des packages nuget via les deux sources de données suivantes : nexusint / nuget.org
C:\bin\nuget.exe restore C:\Sources\$sln_filename -Source $nuget_repo -Source http://nexusproxy.dalkia.net/repository/nuget.org-proxy/;

if ($lastExitCode -ne 0) {
    Write-Host "ERROR: Nuget package restoration failed." -ForeGroundColor Red;
    $ERRNO = $ERRNO -bor $ERROR_NUGET_RESTORE;
    Quit($ERRNO);
}

Write-Host "Starting build and publish process: ""$sln_filename | $publish_profile""";
Write-Host "msbuild C:\Sources\$sln_filename /p:DeployOnBuild=true /p:PublishProfile=$publish_profile /t:Rebuild";
msbuild C:\Sources\$sln_filename /p:DeployOnBuild=true /p:PublishProfile=$publish_profile /t:Rebuild;

if ($lastExitCode -ne 0) {
    Write-Host "ERROR: Msbuild publish failed." -ForeGroundColor Red;
    $ERRNO = $ERRNO -bor $ERROR_MSBUILD_PUBLISH;
    Quit($ERRNO);
}

Quit($ERRNO);
