#!/usr/bin/env groovy

pipeline {
  agent {
    kubernetes {
      yamlFile './jenkins-agent-pod-k8s.yaml'
      inheritFrom 'jnlp'  // all your pods will be named with this prefix, followed by a unique id
      idleMinutes 5  // how long the pod will live after no jobs have run on it
      defaultContainer 'maven'
    }
  }
  options {
    timestamps()
    timeout(time: 2, unit: 'HOURS')
    parallelsAlwaysFailFast()
    rateLimitBuilds(throttle: [count: 3, durationName: 'minute', userBoost: false])
    buildDiscarder(logRotator(numToKeepStr: '100'))
    //gitLabConnection('Gitlab')
    //gitlabCommitStatus(name: "Jenkins build $BUILD_DISPLAY_NAME")
    ansiColor('xterm')
  }
  triggers {
    // replace 0 with H (hash) to randomize starts to spread load and avoid spikes
    pollSCM('H/10 * * * *')  // run every 10 mins, at a consistent offset time within that 10 min interval
    cron('H 10 * * 1-5')  // run at 10:XX:XX am every weekday morning, ie. some job fixed time between 10-11am
  }
  environment {
    APP_NAME = "sample-app"
    VERSION = "$GIT_COMMIT"
    //DOCKER_TAG = "$GIT_COMMIT" // ou "$GIT_BRANCH" que pode ser definido como uma tag git semver
    DOCKER_TAG = "${env.GIT_BRANCH.split('/')[-1]}"  //retire a 'origin/' inicial de 'origin/branch'
    DOCKER_IMAGE = "erivando/${APP_NAME}"
    BUILD_NUMBER = "${env.BUILD_NUMBER}"
    // se criar imagens docker em agentes, isso habilita o BuildKit, que cria automaticamente camadas de imagens em paralelo sempre que possível (especialmente útil para compilações de vários estágios)
    // adicione também '--build-arg BUILDKIT_INLINE_CACHE=1' ao comando docker build
    DOCKER_BUILDKIT = 1
    TF_IN_AUTOMATION = 1  // altera a saída para suprimir as sugestões da CLI para comandos relacionados
    THREAD_COUNT = 6
    //SLACK_MESSAGE = "Pipeline <${env.JOB_DISPLAY_URL}|${env.JOB_NAME}> - <${env.RUN_DISPLAY_URL}|Build #${env.BUILD_NUMBER}>"
    // Altera o tempo limite do trabalho (o padrão é 1800 segundos; defina como 0 para desabilitar
    SEMGREP_TIMEOUT = "300"
  }
  stages {
    // geralmente não é necessário ao obter o Jenkinsfile do Git SCM no Pipeline / Multibranch Pipeline, isso está implícito
    stage ('Checkout') {
      steps {
        milestone(ordinal: null, label: "Milestone: Checkout")
        checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '', url: 'https://github.com/erivandosena/test-pipeline']]])
        //container('git') {
        //  git credentialsId: 'GitHub', url: 'https://github.com/HariSekhon/Jenkins.git', branch: 'master'
        //}
      }
    }
    stage('CI/CD Initialize Setup') {
      steps {
        milestone(ordinal: null, label: "Milestone: Setup")
        label 'Setup'
        script {
          // reescrever o nome da compilação para incluir o ID do commit
          currentBuild.displayName = "$BUILD_DISPLAY_NAME (${GIT_COMMIT.take(8)})"
          // salve o caminho da área de trabalho para usar nos testes
          workspace = "$env.WORKSPACE"
        }
        // execute alguns comandos shell para configurar as coisas
        sh '''
          for x in /etc/mybuild.d/*.sh; do
            if [ -r "$x" ]; then
              source $x;
            fi;
          done;
        '''
        sh 'printenv'
      }
    }
    stage('Build') {
      steps {  // no container directive is needed as the maven container is the default
        echo "2. Build Application"
        //container('maven') { 
        sh "mvn clean package -Dmy.variable=${APP_NAME} -Dmy.variable=${VERSION}"
        //}
      }
    }
    stage('Build Docker Image') {
      steps {
        echo "3. Build of Image"
        container('docker') {  
          milestone(ordinal: null, label: "Milestone: Docker Build")
          timeout(time: 60, unit: 'MINUTES') {
            // check 'DOCKER_BUILDKIT = 1' is set in environment {} section
            sh "docker build -t '$DOCKER_IMAGE':'$DOCKER_TAG' --build-arg=BUILDKIT_INLINE_CACHE=1 --cache-from '$DOCKER_IMAGE':'$DOCKER_TAG' ."
          }
          //sh "docker build -t ${IMAGE_TAG} ."  // when we run docker in this step, we're running it via a shell on the docker build-pod container, 
        }
      }
    }
    stage('Docker Push Image') {
      steps {
        echo "4. Push of Image"
        container('docker') { 
          withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
            sh "docker login -u ${dockerHubUser} -p ${dockerHubPassword}"
            //sh "docker push ${IMAGE_TAG}"        // which is just connecting to the host docker deaemon
            milestone(ordinal: null, label: "Milestone: Docker Push")
            timeout(time: 15, unit: 'MINUTES') {
              sh "docker push '$DOCKER_IMAGE':'$DOCKER_TAG'"
            }
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
          //sh './kubectl apply -f k8s.yaml'      
          //sh "kubectl apply -f k8s.yaml --record"
          kubernetesDeploy configs: 'k8s.yaml', kubeconfigId: 'K8s-c2-config'
        }
      }
    }
  }
}
