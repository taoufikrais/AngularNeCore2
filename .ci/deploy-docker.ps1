Param (
    [string]$dockerImageName
)

Write-Host "Deploying image: $dockerImageName";

$env:dockerImageName = $dockerImageName;
$env:dockerImageTag = $dockerImageName.Split(":")[-1]

# Build Docker Compose
docker-compose build;

if ($lastExitCode -ne 0) {
    Write-Host "ERROR : Docker-compose build failed." -ForeGroundColor Red;
    return 1;
}

# Déploiement Docker Compose
docker-compose up -d

if ($lastExitCode -ne 0) {
    Write-Host "ERROR : Docker-compose up failed." -ForeGroundColor Red;
    return 2;
}

# Affichage d'infos génériques sur le container créé
$CONTAINERID = docker ps --filter "ancestor=$dockerImageName" --format "{{ .ID }}";
Write-Host "Container id : $CONTAINERID";

# Affichage de l'IP du container créé
$CONTAINERIP = docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" $CONTAINERID;
Write-Host "Container IP Address: $CONTAINERIP";

return 0;