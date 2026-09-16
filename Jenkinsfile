pipeline {
    agent  any 
    environment {
      DOCKER_CREDS = credentials('dockerhub-credentials')
    }
    stages {
        stage('1.Greeting'){
            steps {
              echo 'Hello this Jenkins'
            }
        }
        stage('2. Checking Directory'){
          steps {
            sh 'pwd'
            sh 'whoami'
          }      
        }
        stage('3. Login to DockerHub') {
          steps {
            script {
              def result = sh (
                script ("docker login -u makarajr126 ${DOCKER_CREDS} --password-stdin"),
                returnStdout: true
              ).trim()
              echo "Login Result : ${result}" 
            }
          }
         
        }
        stage('4. Build  Docker Image'){
          steps{
            script {
              def image = sh (
                script("docker build --platform=linux/arm64 -t rag-ui:v${env.BUILD_NUMBER} ."),
                returnStdout: true
              ).trim()
              echo "This is resutl of build image : ${image}"
            }
          }
        }
        stage('5. Tag image with Dockerhub'){
          steps{
             script {
              def taged = sh (
                script("docker tag makarajr126/rag-ui rag-ui:v${env.BUILD_NUMBER}"),
                returnStdout: true
              ).trim()
              echo "This is resutl of tag : ${taged}"
            }
          }
        }
        stage("6. Checking docker image"){
          steps{
           script {
              def image = sh (
                script("docker ps"),
                returnStdout: true
              ).trim()
              echo "This is docker image : ${image}"
            }
          }
        }
        stage('7. Push to Dockerhub'){
          steps{
             script {
              def pushed = sh (
                script("docker push makarajr126/rag-ui:v${env.BUILD_NUMBER}"),
                returnStdout: true
              ).trim()
              echo "This is result after pushed : ${pushed}"
            }
          }
        }

  
    }
    
}
