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
            echo $name
            # set +x
            break
        fi
        error_message "⚠️ Invalid input!" >&2
        name=$(read_input  "✅ Please enter a valid name: ") 
    done
}

# # Function to validate data types
validate_data_type() {
    
    # Ensure input matches the expected type (integer, string, etc.)
    # if [[ -f metafile ]]
    # then 
    #     error_message "It's not a file"
    # elif
    #     file= $1
    #     while [[ read -p line  ]]
    #     do
    #     done 
    # then
    
    # fi
    echo dataType
}

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

                error_message  "❌ A table with this name already exists!"
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
                        return 0
                        ;;
                    esac
                done
        else 

            return 1

        fi
    done
}
validate_column_count()
{
    local nOfColumns=$1
    while true 
    do
      if ! [[ $nOfColumns =~  ^[1-9][0-9]*$  ]]
      then
        error_message "❌ Invalid input!" >&2
        nOfColumns=$(read_input "📊  Please enter a positive number for the number of columns : ")

      else
        success_message "✅ Success! The number of columns has been accepted." >&2
        echo $nOfColumns
        break
      fi

    done 
}


database_exists()
{
    if ! [ -d "$SCRIPT_DIR/Databases" ]
    then
        mkdir -p  "$SCRIPT_DIR/Databases"
    fi
    echo "$SCRIPT_DIR/Databases"
}