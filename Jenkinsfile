pipeline {
    agent any
    environment {
        DOCKER_CREDS = credentials('dockerhub-credentials')
        IMAGE_TAG = "v${env.BUILD_NUMBER}"

    }
    stages {
        stage('1. Greeting') {
            steps {
                echo 'Hello this Jenkins'
            }
        }
        stage('2. Checking Directory') {
            steps {
                sh 'pwd'
                sh 'whoami'
            }
        }
        stage('3. Login to DockerHub') {
            steps {
                sh(script: 'echo $DOCKER_CREDS_PSW | sudo docker login -u $DOCKER_CREDS_USR --password-stdin')
            }
        }
        stage('4. Remove Image if exist') {
          steps{
            script {
               def prevBuild = env.BUILD_NUMBER.toInteger() - 1
                 sh(script: "sudo docker rmi rag-ui:v${prevBuild} || true")
            }
          }
          
        }
        stage('5. Build Docker Image') {
            steps {
                sh(script: "sudo docker build -t ${DOCKER_CREDS_USR}/rag-ui:${IMAGE_TAG} .")
            }
        }
        stage('6. Tag image for DockerHub') {
            steps {
                sh(script: "sudo docker tag rag-ui ${DOCKER_CREDS_USR}/rag-ui:${IMAGE_TAG}")
            }
        }
        stage('7. Checking docker image') {
            steps {
                sh 'sudo docker images | grep rag-ui'
            }
        }
         stage('8. Clone manifest repo ') {
            steps {
              sshagent(credentials: ['ssh-inside']){
                sh """
                   git clone https://github.com/noevchanmakara126/argo.git
                   sed -i "s/tag: .*/tag: ${IMAGE_TAG}/" templates_or_values_path/values.yaml
                   git config user.email "jenkins@ci.local"
                   git config user.name "jenkins"
                   git add .
                   git commit -m "Update rag-ui image to ${IMAGE_TAG}"
                   git push origin main
                 """ 
              }
            }
        }
        stage('9. Push to DockerHub') {
            steps {
                sh(script: "sudo docker push ${DOCKER_CREDS_USR}/rag-ui:${IMAGE_TAG}")
            }
        }
    }
    post {
        always {
            sh 'sudo docker logout'
        }
    }
}