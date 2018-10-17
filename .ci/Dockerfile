# Docker file pour la publication d'un site ASP.NET MVC dans un Container Docker

# On utilise une image aspnet qui contient déjà IIS + ASP .NET 4.6.2
FROM microsoft/aspnet:4.6.2
#FROM microsoft/aspnet:4.7.1-windowsservercore-1709

ARG title="IIS + ASP .Net Dalkia Image"
ARG version="1.0"

# Metadata indicating an image maintainer.
LABEL maintainer="simon.guidera@dalkia.fr"
LABEL version=$version
LABEL description=$title

EXPOSE 80

# The final instruction copies the site you published earlier into the container.
# TODO : adapter cette commande pour cibler le répertoire de publication du site web.
COPY /build /inetpub/wwwroot