#!/usr/bin/env groovy

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
    IMAGE_TAG = "erivando/${APP_NAME}:${env.BUILD_NUMBER}"
  }
  agent {
    kubernetes {
      //label 'mypod'
      inheritFrom 'jnlp-pod'  // all your pods will be named with this prefix, followed by a unique id
      idleMinutes 5  // how long the pod will live after no jobs have run on it
      defaultContainer 'maven'
      yaml """
apiVersion: v1
data:
  .dockerconfigjson: eyJhdXRocyI6eyJodHRwczovL2R0aS1yZWdpc3Ryby51bmlsYWIuZWR1LmJyIjp7InVzZXJuYW1lIjoiYWRtaW4iLCJwYXNzd29yZCI6IkR0aUB1bmlsYWIyMDIzIiwiZW1haWwiOiJkaXNpckB1bmlsYWIuZWR1LmJyIiwiYXV0aCI6IllXUnRhVzQ2UkhScFFIVnVhV3hoWWpJd01qTT0ifX19
kind: Secret
metadata:
  name: harbor-registro 
  namespace: docker
type: kubernetes.io/dockerconfigjson

---
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: some-label-value
spec:
  containers:
  - name: maven-alpine
    image: maven:alpine
    command:
    - cat
    tty: true
  - name: busybox
    image: busybox
    command:
    - cat
    tty: true

---
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: slave
spec:
  containers:  # list of containers that you want present for your build, you can define a default container in the Jenkinsfile
    - name: maven
      image: erivando/maven:3.9.0-openjdk-11 #maven:3.8.6-openjdk-11
      #command: ["tail", "-f", "/dev/null"]  # this or any command that is bascially a noop is required, this is so that you don't overwrite the entrypoint of the base container
      #command: ["/bin/sh -cp"]
      #args: ["sleep", "9999999"]
      imagePullPolicy: Always # use cache or pull image for agent
      resources:  # limits the resources your build contaienr
        requests:
          cpu: "250m"
          memory: "512Mi"
        limits:
          cpu: "5000m"
          memory: "3Gi"
      env:
      - name: JENKINS_URL
        value: "http://jenkins.jenkins.svc.cluster.local"
      - name: JENKINS_TUNNEL
        value: "jenkins.jenkins.svc.cluster.local:"
    - name: docker
      image: docker:20.10 #dti-registro.unilab.edu.br/unilab/docker:latest
      #command: ["tail", "-f", "/dev/null"]
      imagePullPolicy: IfNotPresent
      resources: {}
      volumeMounts:
        - name: docker
          mountPath: /var/run/docker.sock # We use the k8s host docker engine
  volumes:
    - name: docker
      hostPath:
        path: /var/run/docker.sock
  imagePullSecrets:
  - name: harbor-registro
"""
    }
  }
  /*
  stages {
    stage('Run maven') {
      steps {
        container('maven') {
          sh 'mvn -version'
        }
        container('busybox') {
          sh '/bin/busybox'
        }
      }
    }
  }
  */
  stages {
    stage('Build') {
      steps {  // no container directive is needed as the maven container is the default
        echo "2. Build Application"
        sh "mvn clean package -Dmy.variable=${APP_NAME}"   
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
