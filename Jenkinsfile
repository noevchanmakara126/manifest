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
            steps {
                script {
                    def prevBuild = env.BUILD_NUMBER.toInteger() - 1
                    sh(script: "sudo docker rmi ${DOCKER_CREDS_USR}/rag-ui:v${prevBuild} || true")
                }
            }
        }
        stage('5. Build Docker Image') {
            steps {
                sh(script: "sudo docker build -t ${DOCKER_CREDS_USR}/rag-ui:${IMAGE_TAG} .")
            }
        }
        stage('6. Checking docker image') {
            steps {
                sh 'sudo docker images | grep rag-ui'
            }
        }
        stage('7. Push to DockerHub') {
            steps {
                sh(script: "sudo docker push ${DOCKER_CREDS_USR}/rag-ui:${IMAGE_TAG}")
            }
        }
        stage('8. Update manifest repo') {
             steps {
                     sh """
                        set -e
                        cd 
                        cd manifest/
                        rm -rf argo
                        git clone https://github.com/noevchanmakara126/argo.git
                        cd argo
                        sed -i "s/tag: .*/tag: \\"${IMAGE_TAG}\\"/" values.yaml
                        git add values.yaml
                        if git diff --cached --quiet; then
                        echo "No changes to commit"
                        else
                        git commit -m "Update rag-ui image to ${IMAGE_TAG}"
                        git push origin main
                      fi
                      """
                    }
        }
    }
    post {
        always {
            sh 'sudo docker logout'
        }
    }
}