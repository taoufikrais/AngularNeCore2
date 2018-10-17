$Host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size (500, 25)

# Description :   Fichier exécuté par Gitla-CI lors de la phase de compilation.
# Auteur :        Simon Guidera
# Date :          05/03/2018

# Génération d'un nom aléatoire pour le fichier contenant l'ID du container de build

function Quit($errno) {
    Write-Host "Exiting .gitlab-compile.ps1 script with return code : $errno";
    EXIT $errno;
}

$CURPATH = (Get-Item -Path ".\\").FullName;
$ERRNO=0;
$CURVERSION="v$CI_PIPELINE_ID";

# Sélection des repositories NUGET et RAW
$RAW_REPO = $NEXUS_RAW_REPOSITORY_SNAPSHOTS_URL;
$NUGET_REPO = $NEXUS_NUGET_REPOSITORY_SNAPSHOTS_URL;

if ($CI_COMMIT_REF_NAME -eq "master") {
    $NUGET_REPO = $NEXUS_NUGET_REPOSITORY_RELEASES_URL;
    $RAW_REPO = $NEXUS_RAW_REPOSITORY_RELEASES_URL;
}

Write-Host "Working directory : $CURPATH";
Write-Host "Nexus Nuget Repository: $NUGET_REPO";
Write-Host "Nexus Raw Repository: $RAW_REPO";
Write-Host "Launching docker MS Build Tools image" -ForeGroundColor Cyan;
Write-Host "docker run -t -v ${CURPATH}:C:\Sources nexusint.dalkia.net/vsbuildtools2017 C:\Sources\.ci\.msbuild.ps1 $SLN_FILENAME $CI_COMMIT_REF_NAME $NUGET_REPO";

# Lancement du conteneur Docker contenant les Visual Studio Build Tools 2017 - v15.0
docker run --rm -t -v ${CURPATH}:C:\Sources vsbuildtools2017 powershell C:\Sources\.ci\.msbuild.ps1 $SLN_FILENAME $CI_COMMIT_REF_NAME $NUGET_REPO;

if ($lastExitCode -ne 0) {
    Write-Host "ERROR: Docker run failed." -ForeGroundColor Red;
    $ERRNO = $ERRNO -bor 1;
}

# Archivage de l'artefact dans un fichier zip
Write-Host "Zipping artefact.";
Add-Type -assembly "system.io.compression.filesystem";

$zipSource = "$CURPATH\build";
$zipDestination = "$CURPATH\$APP_NAME.$CI_COMMIT_REF_NAME.$CURVERSION.zip";
$zipCompressionLevel = [System.IO.Compression.CompressionLevel]::Optimal;

If(Test-path $zipDestination) { Remove-item $zipDestination; }

Try {
    [System.IO.Compression.ZipFile]::CreateFromDirectory($zipSource, $zipDestination, $zipCompressionLevel, $false);
    Write-Host "OK";
}
Catch 
{
    Write-Host "ERROR: artefact zip compression failed." -ForeGroundColor Red;

    $ErrorMessage = $_.Exception.Message
    Write-Host "Exception message : $ErrorMessage";

    $ERRNO = $ERRNO -bor 3;
    Quit($ERRNO);
}

# Sauvegarde de l'artefact dans Nexus
Write-Host "Saving artefact to Nexus Raw Repository";

$password = ConvertTo-SecureString $CI_RAW_NEXUS_PASSWORD -AsPlainText -Force;
$credentials = New-Object System.Management.Automation.PSCredential ($CI_RAW_NEXUS_USERNAME, $password);
$uri = "$RAW_REPO$APP_NAME.$CI_COMMIT_REF_NAME.$CURVERSION.zip";

Write-Host "Artefact URL: $uri";

$res = $null;

try 
{
    # Delete item
    $res = Invoke-WebRequest -Uri $uri -Credential $credentials -Method Delete -UseBasicParsing;
}
Catch [System.Net.WebException]
{
    $status = $_.Exception.Response.StatusCode.value__;

    if ($status -ne 404)
    {
        Write-Host "Error deleting item.";
        Write-Host "Error message: " $_.Exception.Message;
        $ERRNO = $ERRNO -bor 4;
        Quit($ERRNO);
    }
}

try 
{
    # Upload item
    $res = Invoke-WebRequest -Uri $uri -InFile $zipDestination -Credential $credentials -Method Put -UseBasicParsing;
    Write-Host "OK";
}
Catch
{
    Write-Host "ERROR: upload failed." -ForeGroundColor Red;
    Write-Host "Error message: " $_.Exception.Message;
    $ERRNO = $ERRNO -bor 5;
    Quit($ERRNO);
}

Quit($ERRNO);