pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_IMAGE_FRONTEND = 'yourusername/frontend'
        DOCKER_IMAGE_BACKEND = 'yourusername/backend'
        DOCKER_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                git branch: 'main', url: 'https://github.com/YOUR_GITHUB_USERNAME/devops-assessment.git'
            }
        }

        stage('Build Frontend Image') {
            steps {
                echo 'Building frontend Docker image...'
                dir('frontend') {
                    sh 'docker build -t $DOCKER_IMAGE_FRONTEND:$DOCKER_TAG .'
                    sh 'docker tag $DOCKER_IMAGE_FRONTEND:$DOCKER_TAG $DOCKER_IMAGE_FRONTEND:latest'
                }
            }
        }

        stage('Build Backend Image') {
            steps {
                echo 'Building backend Docker image...'
                dir('backend') {
                    sh 'docker build -t $DOCKER_IMAGE_BACKEND:$DOCKER_TAG .'
                    sh 'docker tag $DOCKER_IMAGE_BACKEND:$DOCKER_TAG $DOCKER_IMAGE_BACKEND:latest'
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing images to Docker Hub...'
                sh 'echo $DOCKER_HUB_CREDENTIALS_PSW | docker login -u $DOCKER_HUB_CREDENTIALS_USR --password-stdin'
                sh 'docker push $DOCKER_IMAGE_FRONTEND:$DOCKER_TAG'
                sh 'docker push $DOCKER_IMAGE_FRONTEND:latest'
                sh 'docker push $DOCKER_IMAGE_BACKEND:$DOCKER_TAG'
                sh 'docker push $DOCKER_IMAGE_BACKEND:latest'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                sh 'docker-compose down || true'
                sh 'docker-compose pull'
                sh 'docker-compose up -d --build'
            }
        }

        stage('Health Check') {
            steps {
                echo 'Performing health check...'
                sh 'sleep 10'
                sh 'curl -f http://localhost:5000/health || exit 1'
                sh 'curl -f http://localhost:3000 || exit 1'
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
            sh 'docker logout'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the logs for details.'
        }
    }
}
