pipeline {
    agent  any 
    stages {
        stage('greeting'){
            step {
              echo 'hello bong bong'
            }
        }
        stage('bye'){
          step {
            echo 'bye bye everyone'
          }      
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
