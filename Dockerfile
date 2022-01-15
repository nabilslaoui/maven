FROM registry.gitlab.com/d837/java-headless:master

LABEL org.opencontainers.image.description="Image Maven"

ARG VERSION_MAVEN="3.6.3"
ARG NOM_USER="maven"
ARG MAVEN_CONFIG="/usr/share/maven/conf/settings.xml"
ARG SOURCES_DIR="/sources"
ARG REPO_DIR="/maven-repo"

USER root

# Installation des utilitaires
# hadolint ignore=DL3008
RUN apt-get update && apt-get -y --no-install-recommends install \
  curl unzip jq xmlstarlet git openjdk-11-jdk maven \
  # Cleanup apt
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Création de l'utilisateur maven
RUN groupadd $NOM_USER \
	&& useradd --gid $NOM_USER --shell /bin/bash --create-home $NOM_USER 


RUN mkdir $SOURCES_DIR \
    # On créé un repertoire qui peut contenir un dépot maven si utilisé sur poste de dev
    # avec un -Dmaven.repo.local=/maven-repo/.m2. Lors de l'affectation d'un volume, les droits
    # son conservés donc tout utilisateur (pas seulement root) pourra y écrire les jars
    && mkdir $REPO_DIR && chmod -R 777 $REPO_DIR

# Paramétrage git nécessaire à maven-release
RUN git config --system user.email "nabil.slaoui@outlook.fr" \
    && git config --system user.name "nabilslaoui"

USER $NOM_USER

ENV PATH=/usr/java/openjdk-11/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/apache-maven-$VERSION_MAVEN/bin \
	MAVEN_HOME=/usr/share/maven \
	MAVEN_CONFIG=$MAVEN_CONFIG

COPY --chown=$NOM_USER:$NOM_USER settings.xml  $MAVEN_CONFIG

WORKDIR /sources

# Comme l'image officielle Dockerhub, on n'utilise pas d'entrypoint ni de CMD, on devra donc
# lancer le containeur avec "mvn <options>" et pas "<options>"
ENTRYPOINT []

