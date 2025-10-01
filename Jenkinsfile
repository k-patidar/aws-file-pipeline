pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps { git 'https://github.com/k-patidar/aws-file-pipeline.git' }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t kundan/dashboard:latest ./dashboard'
                sh 'docker push kundan/dashboard:latest'
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/dashboard-deployment.yaml'
            }
        }
    }
}
