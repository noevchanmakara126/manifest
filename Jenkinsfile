pipeline {
    agent  any 
    stages {
        stage('greeting'){
            steps {
              echo 'hello bong bong'
            }
        }
        stage('checking directory'){
          steps {
            sh 'pwd'
            sh 'whoami'
          }      
        }
        stage('build next js ')
           steps{
            sh 'npm run build'
           }  
    }
    post {
      always {
        echo ('this is always run now matter error or not')
      }
      success {
        echo('only run when the pipeline success')
      }
      failure {
        echo('this will show when error')
      }
    }
}
