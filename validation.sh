#!/bin/bash
# This script contains validation functions used across the DBMS
# - Validate database/table names
# - Ensure correct data types
# - Check primary key uniqueness
source utils.sh
# Function to validate database/table names
validate_name() {
    local name=$1
    if [[ -z $name ]]
    then
        name=$(read_input)
    fi
    while true
    do
        if [[ $name =~ ^[a-zA-Z]+(_?[a-zA-Z0-9]+)*$ ]]
        then
            success_message "✅ Valid name: $name"
            break
        fi
        error_message "⚠️ Invalid input! Please enter a valid name."
        name=$(read_input) 
    done
}

# # Function to validate data types
validate_data_type() {
    
    # Ensure input matches the expected type (integer, string, etc.)
    # metafile=$1
    # field=$2 
    # if [[ -f metafile ]]
    # then 
    #     error_message "It's not a file"
    # elif
    #     while [[  ]]
    #     do

    #     done 
    # then

    # fi
}

# # Function to check primary key uniqueness
validate_primary_key() {
    # Ensure the given primary key does not already exist
    true
}

validate_name "123"