pipeline {
    agent {
        label 'ecs-fargate'
    }

    stages {
        stage('Test') {
            steps {
                sh 'echo hello'
            }
        }
    }
}