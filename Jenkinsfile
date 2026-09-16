pipeline {
    agent any
    environment {
        DOCKER_CREDS = credentials('dockerhub-credentials')
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
        // stage('4. Remove Image if exist') {
        //   steps{
        //     script {
        //        def prevBuild = env.BUILD_NUMBER.toInteger() - 1
        //          sh(script: "sudo docker rmi rag-ui:v${prevBuild} || true")
        //     }
        //   }
          
        // }
        stage('5. Build Docker Image') {
            steps {
                sh(script: "sudo docker build -t rag-ui .")
            }
        }
        stage('6. Tag image for DockerHub') {
            steps {
                sh(script: "sudo docker tag rag-ui ${DOCKER_CREDS_USR}/rag-ui")
            }
        }
        stage('7. Checking docker image') {
            steps {
                sh 'sudo docker images | grep rag-ui'
            }
        }
        stage('8. Push to DockerHub') {
            steps {
                sh(script: "sudo docker push $DOCKER_CREDS_USR/rag-ui")
            }
        }
    }
    post {
        always {
            sh 'sudo docker logout'
        }
    }
}