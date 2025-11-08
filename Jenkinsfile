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
        
        // --- Task Definition Details (MUST match AWS console) ---
        TASK_DEF_FAMILY = 'myapp-task-family' // Ensure this matches the Family name in AWS ECS
        CONTAINER_NAME = 'myapp-container'     // Ensure this matches the Container Name in your Task Definition
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
                sh "docker build --no-cache -t ${ECR_REGISTRY}:${IMAGE_TAG} ."
            }
        }

        stage('Push to ECR') {
            steps {
                echo 'Authenticating with ECR via AWS CLI and pushing image...'
                
                withAWS(credentials: AWS_CREDENTIALS_ID, region: AWS_REGION) {
                    sh """
                        # 1. Get ECR Authentication Token using the AWS CLI
                        ECR_TOKEN=\$(aws ecr get-login-password --region ${AWS_REGION})
                        
                        # 2. Log Docker into ECR using the token as the password
                        echo \$ECR_TOKEN | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                        
                        # 3. Push the image
                        docker push ${ECR_REGISTRY}:${IMAGE_TAG}
                    """
                }
            }
        }
        
        stage('Deploy to ECS') {
            steps {
                echo 'Registering new Task Definition and updating ECS Service...'
                
                // Use the AWS credentials and region defined in the environment block
                withAWS(credentials: AWS_CREDENTIALS_ID, region: AWS_REGION) {
                    
                    // 1. Register a new Task Definition revision
                    sh """
                        # Retrieve the active task definition JSON
                        TASK_DEF_JSON=\$(aws ecs describe-task-definition --task-definition \$TASK_DEF_FAMILY --query taskDefinition --output json)
                        
                        # Use jq to update the image tag, and remove ARN/revision fields
                        NEW_TASK_DEF=\$(echo \$TASK_DEF_JSON | jq '.containerDefinitions[] |= if .name == "\$CONTAINER_NAME" then .image = "\$ECR_REGISTRY:\$IMAGE_TAG" else . end' | jq 'del(.taskDefinitionArn)' | jq 'del(.revision)' | jq 'del(.status)' | jq 'del(.requiresAttributes)' | jq 'del(.compatibilities)')
                        
                        # Register the new revision
                        aws ecs register-task-definition --cli-input-json "\$NEW_TASK_DEF"
                    """

                    // 2. Update the ECS Service to force a new deployment of the latest revision
                    sh "aws ecs update-service --cluster ${ECS_CLUSTER_NAME} --service ${ECS_SERVICE_NAME} --force-new-deployment"
                    
                    echo 'Deployment complete! The new image is rolling out.'
                }
            }
        }
    }
}
