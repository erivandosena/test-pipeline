FROM java:openjdk-8u111-jre

LABEL \
    org.opencontainers.image.vendor="Divisão de Infraestrutura, Segurança da Informação e Redes" \
    org.opencontainers.image.title="Exemplo de Microsserviço de Aplicação em container Docker Linux" \
    org.opencontainers.image.description="sample-app é um software Java usado para demostrar aplicativos dentro de containers." \
    org.opencontainers.image.version="1.0.0" \
    org.opencontainers.image.url="https://hub.docker.com/_/docker/tags" \
    org.opencontainers.image.source="https://github.com/jenkinsci/docker" \
    org.opencontainers.image.revision="${COMMIT_SHA}" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.author="Erivando Sena<erivandoramos@unilab.edu.br>" \
    org.opencontainers.image.company="Universidade da Integração Internacional da Lusofonia Afro-Brasileira (UNILAB)" \
    org.opencontainers.image.maintainer="Tianon (of the Docker Project) / DISIR/DTI/Unilab"
    
ENV APP_NAME "sample-app-1.0.0-SNAPSHOT.jar"

WORKDIR /opt

ADD "${PWD}/target/${APP_NAME}" /opt

CMD ["java", "-jar", "opt/${APP_NAME}"]
