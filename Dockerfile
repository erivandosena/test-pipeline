FROM java:openjdk-8u111-jre
ENV APP_NAME "sample-app"
WORKDIR /opt
ADD $PWD/target/br.edu.unilab."${APP_NAME}"-1.0-SNAPSHOT.jar /opt

CMD ["java", "-jar", "opt/${APP_NAME}-1.0-SNAPSHOT.jar"]
