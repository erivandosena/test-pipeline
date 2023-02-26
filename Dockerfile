FROM java:openjdk-8u111-jre
ENV APP_NAME "sample-app"
WORKDIR /opt
ADD "${PWD}/target/${APP_NAME}-${VERSION}"-SNAPSHOT.jar /opt

CMD ["java", "-jar", "opt/${APP_NAME}-${VERSION}-SNAPSHOT.jar"]
