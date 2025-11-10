// Jenkinsfile (Groovy Script)
pipeline {
    agent any
    
    environment {
        // --- AWS Details ---
        ECR_REGISTRY = '405721655829.dkr.ecr.us-east-1.amazonaws.com/devops'
        AWS_REGION = 'us-east-1' 
        AWS_CREDENTIALS_ID = 'DARSHINI' 
        
        // --- ECS Target Names ---
        ECS_CLUSTER_NAME = 'devops_cluster' 
        ECS_SERVICE_NAME = 'devops_service'
        IMAGE_TAG = "${env.BUILD_NUMBER}"

        // --- Task Definition Details ---
        TASK_DEF_FAMILY = 'myapp-task-family'
        CONTAINER_NAME = 'myapp-container' 
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
                
                // Uses raw AWS CLI login via Instance Role and DARSHINI credentials
                withAWS(credentials: AWS_CREDENTIALS_ID, region: AWS_REGION) {
                    sh """
                        ECR_TOKEN=\$(aws ecr get-login-password --region ${AWS_REGION})
                        echo \$ECR_TOKEN | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                        docker push ${ECR_REGISTRY}:${IMAGE_TAG}
                    """
                }
            }
        }
        
        stage('Deploy to ECS') {
            steps {
                echo 'Registering new Task Definition and updating ECS Service...'
                
                withAWS(credentials: AWS_CREDENTIALS_ID, region: AWS_REGION) {
                    
                    // 1. Register a new Task Definition revision with full JSON cleanup
                    sh """
                        TASK_DEF_JSON=\$(aws ecs describe-task-definition --task-definition \$TASK_DEF_FAMILY --query taskDefinition --output json)
                        NEW_TASK_DEF=\$(echo \$TASK_DEF_JSON | \
                            jq '.containerDefinitions[] |= if .name == "\$CONTAINER_NAME" then .image = "\$ECR_REGISTRY:\$IMAGE_TAG" else . end' | \
                            jq 'del(.taskDefinitionArn)' | \
                            jq 'del(.revision)' | \
                            jq 'del(.status)' | \
                            jq 'del(.requiresAttributes)' | \
                            jq 'del(.compatibilities)' | \
                            jq 'del(.registeredAt)' | \
                            jq 'del(.registeredBy)')
                        
                        aws ecs register-task-definition --cli-input-json "\$NEW_TASK_DEF"
                    """

                    // 2. Update the ECS Service to force a new deployment
                    sh "aws ecs update-service --cluster ${ECS_CLUSTER_NAME} --service ${ECS_SERVICE_NAME} --force-new-deployment"
                    
                    echo 'Deployment complete! The new image is rolling out.'
                }
            }
        }
    }
    
    // ====================================================================
    // MONITORING & LOGGING STEP: EMAIL NOTIFICATIONS (REQUIRED SUBMISSION CODE)
    // ====================================================================
    post {
        // Clean up workspace after build
        always {
            cleanWs()
        }
        // Send email on success
        success {
            emailext (
                subject: "SUCCESS: Pipeline ${env.JOB_NAME} Build #${env.BUILD_NUMBER}",
                body: "Deployment SUCCESSFUL! Application is running on AWS. Log: ${env.BUILD_URL}/console",
                to: 'your.email.address@example.com' // <<== UPDATE THIS
            )
        }
        // Send email on failure
        failure {
            emailext (
                subject: "FAILURE: Pipeline ${env.JOB_NAME} Build #${env.BUILD_NUMBER}",
                body: "Deployment FAILED. Please check Jenkins console for errors. Log: ${env.BUILD_URL}/console",
                to: 'your.email.address@example.com', // <<== UPDATE THIS
                attachLog: true
            )
        }
    }
}
