pipeline {
    agent any

    environment {
        IMAGE_NAME = "kunalpatidar/dashboard"
        IMAGE_TAG  = "latest"
        DOCKER_USERNAME = "kunalpatidar"
        DOCKER_PASSWORD = credentials('dockerhub-cred') // Jenkins credential ID
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'master', url: 'https://github.com/k-patidar/aws-file-pipeline.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ./dashboard"
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                docker push ${IMAGE_NAME}:${IMAGE_TAG}
                '''
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

