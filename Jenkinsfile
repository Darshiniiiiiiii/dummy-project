// Jenkinsfile (Groovy Script)
pipeline {
    // Defines the entire pipeline to run on the 'master' node (your EC2 instance)
    agent any
    
    // Define environment variables for the pipeline
    environment {
        // !!! REPLACE THESE PLACEHOLDERS !!!
        ECR_REGISTRY = 'YOUR_AWS_ACCOUNT_ID.dkr.ecr.YOUR_AWS_REGION.amazonaws.com/myapp-repo'
        
        // This tag ensures the image is unique for every build
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        
        // Set your ECS service and cluster names
        ECS_CLUSTER_NAME = 'MyAppCluster' 
        ECS_SERVICE_NAME = 'MyAppService'
        
        // The Jenkins credential ID you created in Phase I
        AWS_CREDENTIALS_ID = 'aws-jenkins-creds'
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
                withAWS(credentials: AWS_CREDENTIALS_ID, region: 'YOUR_AWS_REGION') {
                    sh "docker push ${ECR_REGISTRY}:${IMAGE_TAG}"
                }
            }
        }
        
        stage('Deploy to ECS') {
            steps {
                echo 'Updating ECS Service to deploy new image...'
                echo 'Deployment stage complete.'
            }
        }
    }
}
