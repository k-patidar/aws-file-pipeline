pipeline {
    agent any

    environment {
        // Docker Hub credentials ID from Jenkins
        DOCKER_CREDENTIALS = 'dockerhub-cred'  // Must match Jenkins credentials ID
        IMAGE_NAME = 'kunalpatidar/dashboard'
        IMAGE_TAG = 'latest'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'master', url: 'https://github.com/k-patidar/aws-file-pipeline.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
                    def appImage = docker.build("${IMAGE_NAME}:${IMAGE_TAG}", "./dashboard")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Pushing Docker image to Docker Hub"
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
            echo " Docker image successfully built and pushed: ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo " Build failed. Check the logs."
        }
    }
}

