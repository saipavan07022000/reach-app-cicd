# React App CI /CD Pipeline

We are using below stages as part of CI/CD pipeline for React App

1. Checkout - Source code checkout

2. Install Dependencies - Dependencies for Node package manager

3. Run Tests - Unit test execution

4. SonarQube Analysis - Code analysis for security vulnarabilities (Running in container)

5. Docker Image Build - Building docker image

6. Trivy Image Scanning - Scanning image for critical issues. Failing build if a critical issue is found (Running in container)

7. Docker Image Push - Pushing image to dockerhub

8. EC2 Deployment - Currently deploying to EC2

9. K8s Deployment - Manifest files are ready. This is dummy for now as we dont have any cluster. All we need to do is change the cluster name in stage and else will work as expected. 

