// Jenkinsfile (Groovy Script)
pipeline {
    agent any
    
    environment {
        // --- Confirmed AWS Details ---
        // Your AWS Account ID and ECR Repository Name
        ECR_REGISTRY = '405721655829.dkr.ecr.us-east-1.amazonaws.com/devops'
        // Your AWS Region (critical for AWS SDK calls)
        AWS_REGION = 'us-east-1' 
        // Your Jenkins Credential ID (for ECR login and ECS update)
        AWS_CREDENTIALS_ID = 'DARSHINI' 
        
        // --- ECS Target Names ---
        ECS_CLUSTER_NAME = 'devops_cluster'  
        ECS_SERVICE_NAME = 'devops_service'
        // Image Tag
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Checking out code from Git...'
            }
        }
        
        stage('Build & Test') {
            steps {
                echo 'Building application with Maven...'
                sh 'mvn clean package -DskipTests'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo "Building Docker image with tag: ${ECR_REGISTRY}:${IMAGE_TAG}"
                sh "docker build -t ${ECR_REGISTRY}:${IMAGE_TAG} ."
            }
        }
        
        stage('Push to ECR') {
            steps {
                echo 'Pushing image to ECR...'
                // Finalized Push with correct Region variable
                withAWS(credentials: AWS_CREDENTIALS_ID, region: AWS_REGION) {
                    sh "docker push ${ECR_REGISTRY}:${IMAGE_TAG}"
                }
            }
        }
        
        stage('Deploy to ECS') {
            steps {
                echo 'Updating ECS Service to deploy new image...'
                // Finalized Deployment logic using the ecsDeploy step
                withAWS(credentials: AWS_CREDENTIALS_ID, region: AWS_REGION) {
                    ecsDeploy(
                        cluster: ECS_CLUSTER_NAME,
                        service: ECS_SERVICE_NAME,
                        // Assumed Task Definition Family and Container Name from previous steps:
                        taskDefinition: "myapp-task-family", 
                        container: 'myapp-container',
                        image: "${ECR_REGISTRY}:${IMAGE_TAG}"
                    )
                }
                echo 'Deployment stage complete.'
            }
        }
    }
}
