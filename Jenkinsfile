pipeline {
    agent any

    environment {
        // Docker Hub credentials ID from Jenkins
        DOCKER_CREDENTIALS = 'dockerhub-cred'  
        IMAGE_NAME = 'kunalpatidar/dashboard'
        IMAGE_TAG = 'latest'
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Checkout your Git repo
                git branch: 'master', url: 'https://github.com/k-patidar/aws-file-pipeline.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    docker.build("${IMAGE_NAME}:${IMAGE_TAG}", "./dashboard")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Login and push Docker image using Jenkins credentials
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS) {
                        def appImage = docker.image("${IMAGE_NAME}:${IMAGE_TAG}")
                        appImage.push()
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Docker image successfully built and pushed: ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "Build failed. Check the logs."
        }
    }
}

