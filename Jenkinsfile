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
                sh(script: 'echo $DOCKER_CREDS_PSW | docker login -u $DOCKER_CREDS_USR --password-stdin')
            }
        }
        stage('4. Build Docker Image') {
            steps {
                sh(script: "sudo docker build --platform=linux/arm64 -t rag-ui:v${env.BUILD_NUMBER} .")
            }
        }
        stage('5. Tag image for DockerHub') {
            steps {
                sh(script: "sudo docker tag rag-ui:v${env.BUILD_NUMBER} makarajr126/rag-ui:v${env.BUILD_NUMBER}")
            }
        }
        stage('6. Checking docker image') {
            steps {
                sh 'sudo docker images | grep rag-ui'
            }
        }
        stage('7. Push to DockerHub') {
            steps {
                sh(script: "sudo docker push makarajr126/rag-ui:v${env.BUILD_NUMBER}")
            }
        }
    }
    post {
        always {
            sh 'docker logout'
        }
    }
}