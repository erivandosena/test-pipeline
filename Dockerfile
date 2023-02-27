# Dockerfile for sample-app
#
# Maintainer: Erivando Sena <erivandoramos@unilab.edu.br>
#
# Description: Este Dockerfile cria uma imagem para sample-app, um aplicativo da Web escrito em Java.
#
# Build instructions:
#
#   docker buildx build -t dti-registro.unilab.edu.br/unilab/sample-app --build-arg 'COMMIT_SHA=$(git rev-parse --short HEAD) VERSION=1.0.0 BUILDKIT_INLINE_CACHE=1' --no-cache .
#   docker push dti-registro.unilab.edu.br/unilab/sample-app
#
# Usage:
#
#   docker run -it --rm -d -p 8081:80 --name sample-app dti-registro.unilab.edu.br/unilab/sample-app
#   docker logs -f --tail --until=2s sample-app
#   docker exec -it sample-app bash
#
# Dependencies: openjdk:11.0-jre-bullseye
#
# Environment variables:
#
#   COMMIT_SHA: o hash SHA-1 de um determinado commit do Git.
#   VERSION: usado na tag de imagem ou como parte dos metadados.
#
# Notes:
#
# - Este Dockerfile assume que o código do aplicativo está localizado no diretório atual
# - O aplicativo pode ser acessado em um navegador da Web em https://hello-world-test.unilab.edu.br/
#
# Version: 1.0

FROM openjdk:11.0-jre-bullseye

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get upgrade -y \
  && apt-get autoremove -y \
  && apt-get install -y --no-install-recommends --allow-remove-essential \
    curl \
    telnet \
    iputils-ping \
    lsb-release \
    locales

ARG VERSION
ARG COMMIT_SHA
ENV TZ America/Fortaleza
ENV LANG pt_BR.UTF-8 
ENV LC_CTYPE pt_BR.UTF-8 
ENV LC_ALL C
ENV LANGUAGE pt_BR:pt:en
RUN locale-gen pt_BR.UTF-8 
RUN dpkg-reconfigure locales tzdata -f noninteractive

ENV APP_VERSION ${VERSION}

ENV APP_NAME "sample-app-${APP_VERSION}-SNAPSHOT.jar"

WORKDIR /opt

ADD "${PWD}/target/${APP_NAME}" /opt

LABEL \
    org.opencontainers.image.vendor="Divisão de Infraestrutura, Segurança da Informação e Redes" \
    org.opencontainers.image.title="Exemplo de Microsserviço de Aplicação em container Docker Linux" \
    org.opencontainers.image.description="sample-app é um software Java usado para demostrar aplicativos dentro de containers." \
    org.opencontainers.image.version="${VERSION}" \
    org.opencontainers.image.url="https://hello-world-test.unilab.edu.br/" \
    org.opencontainers.image.source="https://github.com/erivandosena/test-pipeline" \
    org.opencontainers.image.revision="${COMMIT_SHA}" \
    org.opencontainers.image.licenses="N/A" \
    org.opencontainers.image.author="Erivando Sena<erivandoramos@unilab.edu.br>" \
    org.opencontainers.image.company="Universidade da Integração Internacional da Lusofonia Afro-Brasileira (UNILAB)" \
    org.opencontainers.image.maintainer="DTI/Unilab"

# ENTRYPOINT java -jar $APP_NAME
CMD ["java", "-jar", "$APP_NAME"]
