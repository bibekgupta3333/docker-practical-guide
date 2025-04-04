#!/bin/bash
set -e

# This script deploys the application using AWS CDK

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Please install it first."
    exit 1
fi

# Check if CDK is installed
if ! command -v cdk &> /dev/null; then
    echo "AWS CDK is not installed. Installing it globally..."
    npm install -g aws-cdk
fi

# Navigate to CDK directory
cd cdk

# Install dependencies
echo "Installing CDK dependencies..."
npm install

# Bootstrap CDK (if not already done)
echo "Bootstrapping CDK..."
cdk bootstrap

# Deploy the stack
echo "Deploying the stack..."
cdk deploy --require-approval never

echo "Deployment completed!"
