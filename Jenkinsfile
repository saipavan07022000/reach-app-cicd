pipeline {
    agent any
    environment {
        APP_NAME = 'pavan-project'
        DOCKER_CREDENTIALS_ID = 'DOCKER_CREDENTIALS_ID'
        K8S_MANIFESTS = 'kubernetes-manifests'
        DOCKER_USERNAME_DOCKER = 'saipavan0702'
    }
    stages {
        stage("Checkout") {
            steps {
                git branch: 'main', url: 'https://github.com/saipavan07022000/reach-app-cicd.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'npm test -- --watchAll=false'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'Sonar-Creds', usernameVariable: 'SONAR_HOST_URL', passwordVariable: 'SONAR_LOGIN_TOKEN')]) {
                    withSonarQubeEnv('SonarServer') {
                        sh """
                        /opt/sonar-scanner/bin/sonar-scanner \
                        -Dsonar.projectKey=${APP_NAME} \
                        -Dsonar.sources=. \
                        -Dsonar.login=${SONAR_LOGIN_TOKEN} \
                        -Dsonar.host.url=${SONAR_HOST_URL}
                        """
                    }
                }
            }
        }


        stage('Docker Image Build') {
            steps {
                script {
                    sh 'docker system prune -f'
                    sh 'docker build -t ${APP_NAME}:${BUILD_NUMBER} .'
                }
            }
        }

        stage('Image Vulnarability Scan - Trivy') {
            steps {
                sh '''docker run --rm \
                    -v /var/run/docker.sock:/var/run/docker.sock \
                    aquasec/trivy:latest \
                    image --exit-code 1 \
                    --severity CRITICAL,HIGH \
                    --ignore-unfixed \
                    ${APP_NAME}:${BUILD_NUMBER}'''
            }
        }

        stage('Docker Image Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    script {
                        sh 'ls -la'
                        sh 'pwd'
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                        sh 'docker tag ${APP_NAME}:${BUILD_NUMBER} ${DOCKER_USERNAME_DOCKER}/${APP_NAME}:${BUILD_NUMBER}'
                        sh 'docker tag ${APP_NAME}:${BUILD_NUMBER} ${DOCKER_USERNAME_DOCKER}/${APP_NAME}:latest'
                        sh 'docker push ${DOCKER_USERNAME_DOCKER}/${APP_NAME}:${BUILD_NUMBER}'
                        sh 'docker push ${DOCKER_USERNAME_DOCKER}/${APP_NAME}:latest'
                        sh 'docker logout'
                    }
                }
            }
        }

        stage('Deployment to EC2') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]){
                    script {
                        sh 'pwd'
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                        sh 'docker stop react-app || true'
                        sh 'docker rm react-app || true'        
                        sh 'docker pull ${DOCKER_USERNAME_DOCKER}/${APP_NAME}:${BUILD_NUMBER}'
                        sh 'docker run -d --name react-app -p 80:80 ${DOCKER_USERNAME_DOCKER}/${APP_NAME}:${BUILD_NUMBER}'
                        sh 'docker ps'
                        sh 'docker logout'
                    }
                }
            }
        }

        stage('Deployment to K8s') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'AWS_CREDS', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    script {
                        sh '''
                        # aws eks --region us-east-1 update-kubeconfig --name eks-cluster
                        # kubectl apply -f ${K8S_MANIFESTS}/deployment.yaml
                        # kubectl apply -f ${K8S_MANIFESTS}/service.yaml
                        # kubectl apply -f ${K8S_MANIFESTS}/hpa.yaml
                        '''
                    }
                }
            }
        }
    }
}


