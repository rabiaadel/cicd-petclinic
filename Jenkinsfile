pipeline {
    agent any

    environment {
        SONAR_URL = 'http://172.19.208.1:9000'  // Adjust if remote
        NEXUS_URL   = '172.19.208.1:8083'  // Nexus Docker registry
        NEXUS_REPO  = 'docker-hosted'
        IMAGE_NAME  = 'spring-petclinic-app1'
        DOCKER_IMAGE = "${NEXUS_URL}/${NEXUS_REPO}/${IMAGE_NAME}"
        IMAGE_TAG   = "${env.BUILD_NUMBER}"
        SONAR_TOKEN = credentials('sonar-token')  // From Jenkins creds
        NEXUS_USER = credentials('nexus-creds')  // Username from creds
        NEXUS_PASS = credentials('nexus-creds')  // Password (hidden)
        MAVEN_OPTS = "-Dmaven.repo.local=$WORKSPACE/.m2/repository"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm  // Pulls from GitHub
            }
        }
        stage('Build') {
            steps {
                script {
                docker.image('maven:3.9.6-eclipse-temurin-21').inside('-v $WORKSPACE/.m2:/root/.m2') {
                    sh 'mvn clean compile -Dcheckstyle.skip=true'
                    }
                }
            }
        }

        stage('Test') {
            steps {
                script {
                docker.image('maven:3.9.6-eclipse-temurin-21').inside {
                    sh 'mvn test -Dcheckstyle.skip=true'
                    }
                }
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withDockerContainer('maven:3.9.3-eclipse-temurin-17') {
                withSonarQubeEnv('SonarQube') {  // <- must match the Jenkins configuration
                    sh 'mvn clean verify sonar:sonar'
                }
            }
        }
    }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                waitForQualityGate abortPipeline: true
            }
        }
    }


        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} .
                        docker tag ${DOCKER_IMAGE}:${IMAGE_TAG} ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }

        stage('Push to Nexus') {
            steps {
                script {
                    sh """
                        echo ${NEXUS_PASS} | docker login ${NEXUS_URL} -u ${NEXUS_USER} --password-stdin
                        docker push ${DOCKER_IMAGE}:${IMAGE_TAG}
                        docker push ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    // Assumes target env has Docker Compose; for local: ssh or direct
                    // For remote: Use 'ssh' step with creds (add SSH credential in Jenkins)
                    sh 'docker-compose down'  // Stop existing
                    sh 'docker-compose up -d --build'  // Rebuild/deploy stack
                    // For remote deploy: sh 'ssh user@remote-host "cd /path/to/repo && docker-compose up -d"'
                }
            }
        }
    }

    post {
        always {
            // Clean up Docker images if needed
            sh 'docker system prune -f'
        }
        success {
            echo 'Pipeline succeeded! Check Grafana at http://localhost:3000'
        }
        failure {
            echo 'Pipeline failed. Check logs.'
        }
    }
}