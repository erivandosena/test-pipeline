pipeline {
  agent {
    kubernetes {
      inheritFrom 'sample-app'  // all your pods will be named with this prefix, followed by a unique id
      idleMinutes 5  // how long the pod will live after no jobs have run on it
      yamlFile 'build-pod.yaml'  // path to the pod definition relative to the root of our project 
      defaultContainer 'maven'  // define a default container if more than a few stages use it, will default to jnlp container
    }
  }
  stages {
    stage('Build Keystore') {
      echo "1. Add cert in Java"
      steps {
        sh "mvn clean install -Djavax.net.ssl.trustStore=$JAVA_HOME/lib/security/cacerts"   
      }
    }
    stage('Build') {
      echo "2. Build Application"
      steps {  // no container directive is needed as the maven container is the default
        sh "mvn clean package"   
      }
    }
    stage('Build Docker Image') {
      echo "3. Build of Image"
      steps {
        container('docker') {  
          sh "docker build -t erivando/sample-app:${build_tag} ."  // when we run docker in this step, we're running it via a shell on the docker build-pod container, 
        }
      }
    }
    stage('Docker Push Image') {
      echo "4. Push of Image"
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
          sh "docker login -u ${dockerHubUser} -p ${dockerHubPassword}"
          sh "docker push erivando/sample-app:${build_tag}"        // which is just connecting to the host docker deaemon
        }
      }
    }
  }
}
