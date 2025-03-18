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
        name=$(read_input "⚡ Please enter the value ")
    fi
    while true
    do
        if [[ $name =~ ^[a-zA-Z]+(_?[a-zA-Z0-9]+)*$ ]]
        then
            # set -x
            success_message "✅ Valid name: $name" >&2
            echo $name
            # set +x
            break
        fi
        error_message "⚠️ Invalid input!" >&2
        name=$(read_input  "✅ Please enter a valid name: ") 
    done
}

# # Function to validate data types
# validate_data_type() {
    
#     # Ensure input matches the expected type (integer, string, etc.)
#     metafile=$1
#     field=$2 
#     if [[ -f metafile ]]
#     then 
#         error_message "It's not a file"
#     elif
#         file= $1
#         while [[ read -p line  ]]
#         do
#         done 
#     then
    
#     fi
# }

# # Function to check primary key uniqueness
validate_primary_key() {
    # Ensure the given primary key does not already exist
    true
}

table_exists()
{
    local tableName=$1
    while true
    do
        if [[ -f $tableName.tb ]]
        then
                PS3="🔹 Please enter your option: "
                select  option in "🔄 Choose another name" "❌ Exit"
                do
                    case $option in
                    "🔄 Choose another name")
                        
                        tableName=$(read_input "Choose another name: ")
                        validate_name $tableName
                        break
                        ;;
                    "❌ Exit")
                        break
                        ;;
                    esac
                done
        else 

            break

        fi
    done
}