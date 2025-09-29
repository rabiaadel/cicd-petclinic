pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = 'rabiaadel/petclinic-app'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-creds',
                    url: 'https://github.com/rabiaadel/cicd-petclinic.git'
            }
        }

        stage('Unit Tests') {
            steps {
                sh './mvnw test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Build with Maven') {
            steps {
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKERHUB_REPO:${BUILD_NUMBER} .'
                sh 'docker tag $DOCKERHUB_REPO:${BUILD_NUMBER} $DOCKERHUB_REPO:latest'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker push $DOCKERHUB_REPO:${BUILD_NUMBER}'
                    sh 'docker push $DOCKERHUB_REPO:latest'
                }
            }
        }

        stage('Deploy to Local Docker') {
            steps {
                sh '''
                  docker rm -f petclinic-app || true
                  docker run -d --name petclinic-app -p 8091:8090 $DOCKERHUB_REPO:latest
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Build ${BUILD_NUMBER} successful!"
        }
        failure {
            echo "❌ Build ${BUILD_NUMBER} failed!"
        }
    }
}
