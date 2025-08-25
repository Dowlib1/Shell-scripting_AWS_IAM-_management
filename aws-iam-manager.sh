#!/bin/bash

# AWS IAM Manager Script for CloudOps Solutions
# This script automates the creation of IAM users, groups, and permissions

# --- Objective 1: Define IAM User Names Array ---
# Store the names of the five IAM users in an array for easy iteration.
IAM_USER_NAMES=("user-alpha" "user-beta" "user-gamma" "user-delta" "user-epsilon")

# Function to create IAM users
create_iam_users() {
    echo "Starting IAM user creation process..."
    echo "-------------------------------------"
    
    # --- Objective 2: Create the IAM Users ---
    # Iterate through the array using AWS CLI commands.
    for user in "${IAM_USER_NAMES[@]}"; do
        echo "Creating user: $user"
        aws iam create-user --user-name "$user"
        if [ $? -eq 0 ]; then
            echo "Success: User '$user' created."
        else
            echo "Warning: User '$user' might already exist or another error occurred."
        fi
    done
    
    echo "------------------------------------"
    echo "IAM user creation process completed."
    echo ""
}

# Function to create admin group and attach policy
create_admin_group() {
    GROUP_NAME="admin"
    POLICY_ARN="arn:aws:iam::aws:policy/AdministratorAccess"

    echo "Creating admin group and attaching policy..."
    echo "--------------------------------------------"
    
    # --- Objective 3: Create an IAM group named "admin" ---
    # Check if the group already exists before creating it.
    aws iam get-group --group-name "$GROUP_NAME" >/dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        echo "Group '$GROUP_NAME' does not exist. Creating it now..."
        aws iam create-group --group-name "$GROUP_NAME"
    else
        echo "Info: Group '$GROUP_NAME' already exists."
    fi
    
    # --- Objective 4: Attach an AWS-managed administrative policy ---
    echo "Attaching AdministratorAccess policy to '$GROUP_NAME' group..."
    aws iam attach-group-policy --group-name "$GROUP_NAME" --policy-arn "$POLICY_ARN"
        
    if [ $? -eq 0 ]; then
        echo "Success: AdministratorAccess policy attached to '$GROUP_NAME'."
    else
        echo "Error: Failed to attach AdministratorAccess policy."
    fi
    
    echo "--------------------------------------------"
    echo ""
}

# Function to add users to admin group
add_users_to_admin_group() {
    GROUP_NAME="admin"
    echo "Adding users to the '$GROUP_NAME' group..."
    echo "------------------------------------"
    
    # --- Objective 5: Assign each user to the "admin" group ---
    # Iterate through the array of IAM user names and assign each to the group.
    for user in "${IAM_USER_NAMES[@]}"; do
        echo "Adding user '$user' to group '$GROUP_NAME'..."
        aws iam add-user-to-group --user-name "$user" --group-name "$GROUP_NAME"
        if [ $? -eq 0 ]; then
            echo "Success: User '$user' added to '$GROUP_NAME'."
        else
            echo "Error: Failed to add user '$user' to group."
        fi
    done
    
    echo "----------------------------------------"
    echo "User group assignment process completed."
    echo ""
}

# Main execution function
main() {
    echo "=================================="
    echo " AWS IAM Management Script"
    echo "=================================="
    echo ""
    
    # Verify AWS CLI is installed and configured
    if ! command -v aws &> /dev/null; then
        echo "Error: AWS CLI is not installed. Please install and configure it first."
        exit 1
    fi
    
    # Execute the functions
    create_iam_users
    create_admin_group
    add_users_to_admin_group
    
    echo "=================================="
    echo " AWS IAM Management Completed"
    echo "=================================="
}

# Execute main function
main

exit 0
