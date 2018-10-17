$Host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size (500, 25)

# Description :   Fichier exécuté par Gitla-CI lors de la phase de build.
# Auteur :        Simon Guidera
# Date :          20/03/2018

function Quit($errno) {
    Write-Host "Exiting .gitlab-create.ps1 script with return code : $errno";
    EXIT $errno;
}

$CURPATH = (Get-Item -Path ".\\").FullName;
$CURVERSION="v$CI_PIPELINE_ID";
$ERRNO=0;

# Sélection du repository DOCKER
$DOCKER_REPO = $NEXUS_DOCKER_REGISTRY_SNAPSHOTS_URL;

if ($CI_COMMIT_REF_NAME -eq "Release") {
    $DOCKER_REPO = $NEXUS_DOCKER_REGISTRY_RELEASES_URL;
}

# Répertoire en cours
Write-Host "Working directory : $CURPATH";
Write-Host "Nexus Docker Repository: $DOCKER_REPO";
Write-Host "Current job id: $CI_JOB_ID";
Write-Host "Current version: $CURVERSION";

# Déplacement des fichiers à packager vers le répertoire de CI.
Move-Item build .ci\build;

# Création de l'image et installation dans son environnement Docker local
Write-Host "docker build -t ${DOCKER_IMAGE_NAME}:$CURVERSION --build-arg version=$CURVERSION --build-arg title=""$DOCKER_IMAGE_TITLE"" .\.ci";
docker build -t ${DOCKER_IMAGE_NAME}:$CURVERSION --build-arg version=$CURVERSION% --build-arg title="$DOCKER_IMAGE_TITLE" .\.ci;

if ($lastExitCode -ne 0) {
    Write-Host "ERROR : Docker build failed." -ForeGroundColor Red;
    $ERRNO = $ERRNO -bor 1;
    Quit($ERRNO);
}

# Ajout de la nouvelle image à Nexus
Write-Host "Pushing new image to nexus Docker Registry";
docker.exe login --username $CI_DOCKER_NEXUS_USERNAME --password $CI_DOCKER_NEXUS_PASSWORD $DOCKER_REPO
docker.exe tag ${DOCKER_IMAGE_NAME}:$CURVERSION $DOCKER_REPO/${DOCKER_IMAGE_NAME}:$CURVERSION;
docker.exe push $DOCKER_REPO/${DOCKER_IMAGE_NAME}:$CURVERSION;

if ($lastExitCode -ne 0) {
    Write-Host "ERROR : Docker push failed." -ForeGroundColor Red;
    $ERRNO = $ERRNO -bor 1;
    Quit($ERRNO);
}

Quit($ERRNO);