#!/bin/bash
# Automation script for CloudFormation templates. 
#
# Parameters
#   $1: Execution mode. Valid values: deploy, delete, preview.
#   $2: Target region.
#   $3: Name of the cloudformation stack.
#   $4: Name of the template file.
#   $5: Name of the parameters file.
#
# Usage examples:
#   ./run-stack.sh deploy us-east-1 udacity-scripts-exercise exercise.yml exercise-params.json
#   ./run-stack.sh preview us-east-1 udacity-scripts-exercise exercise.yml exercise-params.json
#   ./run-stack.sh delete us-east-1 udacity-scripts-exercise
#

# Validate parameters
if [[ $1 != "deploy" && $1 != "delete" && $1 != "preview" ]]; then
    echo "ERROR: Incorrect execution mode. Valid values: deploy, delete, preview." >&2
    exit 1
fi

EXECUTION_MODE=$1
REGION=$2
STACK_NAME=$3
TEMPLATE_FILE_NAME=$4
PARAMETERS_FILE_NAME=$5

# Function to deploy the stack
deploy_stack() {
    echo "Deploying stack: $STACK_NAME in region: $REGION"
    aws cloudformation deploy \
        --region $REGION \
        --stack-name $STACK_NAME \
        --template-file $TEMPLATE_FILE_NAME \
        --parameter-overrides file://$PARAMETERS_FILE_NAME \
        --capabilities CAPABILITY_NAMED_IAM
}

# Function to delete the stack
delete_stack() {
    echo "Deleting stack: $STACK_NAME in region: $REGION"
    aws cloudformation delete-stack \
        --region $REGION \
        --stack-name $STACK_NAME
    
    # Optionally wait until the stack is deleted
    aws cloudformation wait stack-delete-complete \
        --region $REGION \
        --stack-name $STACK_NAME
}

# Function to preview the stack changes (create change set)
preview_stack() {
    echo "Previewing changes for stack: $STACK_NAME in region: $REGION"
    aws cloudformation deploy \
        --region $REGION \
        --stack-name $STACK_NAME \
        --template-file $TEMPLATE_FILE_NAME \
        --parameter-overrides file://$PARAMETERS_FILE_NAME \
        --capabilities CAPABILITY_NAMED_IAM \
        --no-execute-changeset
}

# Execute the appropriate function based on the execution mode
case "$EXECUTION_MODE" in
    deploy)
        deploy_stack
        ;;
    delete)
        delete_stack
        ;;
    preview)
        preview_stack
        ;;
    *)
        echo "Invalid execution mode. Valid values are: deploy, delete, preview."
        exit 1
        ;;
esac