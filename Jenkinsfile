#!/usr/bin/env groovy

def loadValuesYaml(){
  def valuesYaml = readYaml (file: './values.yaml')
  return valuesYaml;
}

pipeline {
  environment {
    /*
    JENKINS_URL = "http://jenkins.jenkins.svc.cluster.local"
    JENKINS_TUNNEL = "jenkins.jenkins.svc.cluster.local:50000"
    JENKINS_AGENT_NAME = "jnlp-slave"
    JENKINS_AGENT_WORKDIR = "/home/jenkins/agent"
    PROJECT = "jenkins-cd-k8s"
    */
    APP_NAME = "sample-app"
    //DOCKER_TAG = getDockerTag()
    DOCKER_TAG = "latest"
    BUILD_NUMBER = "${env.BUILD_NUMBER}"
    IMAGE_TAG = "erivando/${APP_NAME}:${DOCKER_TAG}"
  }
  agent {
    kubernetes {
      //label 'mypod'
      inheritFrom 'jnlp-pod'  // all your pods will be named with this prefix, followed by a unique id
      idleMinutes 5  // how long the pod will live after no jobs have run on it
      defaultContainer 'maven'
    }
  }
  stages {
    stage('CI/CD Initialize') {
      steps {
        script{
          valuesYaml = loadValuesYaml()
          println valuesYaml.getClass()
        }
      }
    }
    stage('Build') {
      steps {  // no container directive is needed as the maven container is the default
        echo "2. Build Application"
        container('maven') { 
          sh "mvn clean package -Dmy.variable=${APP_NAME}"
        }
      }
    }
    stage('Build Docker Image') {
      steps {
        echo "3. Build of Image"
        container('docker') {  
          sh "docker build -t ${IMAGE_TAG} ."  // when we run docker in this step, we're running it via a shell on the docker build-pod container, 
        }
      }
    }
    stage('Docker Push Image') {
      steps {
        echo "4. Push of Image"
        container('docker') { 
          withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
            sh "docker login -u ${dockerHubUser} -p ${dockerHubPassword}"
            sh "docker push ${IMAGE_TAG}"        // which is just connecting to the host docker deaemon
          }
        }
      }
    }
    stage('Deploy') {
      steps {
        echo "5. Deploy to K8S Cluster"
        container('maven') {
          /*
          sh "sed -i 's/<BUILD_TAG>/${build_tag}/' k8s.yaml"
          sh "sed -i 's/<BRANCH_NAME>/${env.BRANCH_NAME}/' k8s.yaml"
          */
          sh 'curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"'  
          sh 'chmod u+x ./kubectl'  
          sh './kubectl apply -f k8s.yaml'      
          sh "kubectl apply -f k8s.yaml --record"
        }
      }
    }
  }
}
