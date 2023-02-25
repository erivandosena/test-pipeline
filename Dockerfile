FROM openjdk-8u111-jre
WORKDIR /opt
ADD target/br.edu.unilab.${APP_NAME}-1.0-SNAPSHOT.jar /opt

CMD ["java", "-jar", "opt/${APP_NAME}-1.0-SNAPSHOT.jar"]
