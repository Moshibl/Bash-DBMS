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
database_exists()
{
    if ! [ -d "$SCRIPT_DIR/Databases" ]
    then
        mkdir -p  "$SCRIPT_DIR/Databases"
    fi
    echo "$SCRIPT_DIR/Databases"
}
# # Function to validate data types
validate_data_type() {
    # Ensure input matches the expected type (integer, string, etc.)
    local fieldDataType=$1
    local fieldValue=$2
    while true
    do
    case $fieldDataType in 
        "INTEGER")
            if  [[ "$fieldValue" =~ ^[0-9]+$ && "$fieldValue" -ge 0  ]]
            then
                success_message "✅ $fieldValue accepted" >&2
                break
            else
                error_message "❌ Invalid input! Please enter a positive integer ">&2
            fi
            ;;
        "STRING")
            if  [[ "$fieldValue" =~ ^[A-Za-z\ ]+$ ]]
            then
                success_message "✅ $fieldValue accepted">&2
                break
            else
                error_message "❌ Invalid: '$fieldValue' contains numbers or special characters.">&2
            fi
            ;;
        "DATE")
            if  [[ "$fieldValue" =~ ^([0-9]{4})-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$ ]]
            then
                success_message "✅ Date accepted: $fieldValue">&2
                break
            else
                error_message "❌ Invalid date format! Please enter in YYYY-MM-DD format.">&2
                
            fi
        ;;
        *)
                error_message "❌ Unknown data type: $fieldDataType"
        esac
        fieldValue=$(read_input "Enter a valid $fieldName ")
    done
    echo $fieldValue
}

# # Function to check primary key uniqueness
validate_uniqueness_dataType() {
    # Ensure the given primary key does not already exist
    local DataFile=$1
    local fieldDataType=$2
    local fieldConstraint=$3
    local fieldValue=$4
    local fieldNum=$5

    fieldValue="$(validate_data_type "$fieldDataType" "$fieldValue")"
    # set -x 
    if [[ -z "$(cat "$DataFile")" ]]
    then
        echo $fieldValue
        return 
    fi

    if [[ $fieldConstraint == "UNIQUE" || $fieldConstraint == "PK"  ]]
    then

        columnData=()  
        while read -r line; do
            columnData+=("$line")
        done < <(awk -F':' -v fieldNum="$fieldNum" '{print $fieldNum}' "$DataFile") # process substitution < <(...)
        #  redirects the output of that subshell as input to the command before it 
        # it means <(awk -F':' -v fieldNum="$fieldNum" '{print $fieldNum}' "$metaDataFile")  will be executed first
    
        while true 
        do
                duplicate_found=false
                for value in ${columnData[@]}
                do

                        if [[ $value == $fieldValue ]]
                        then
                            error_message "❌ The value '$fieldValue' already exists in the database." >&2
                            fieldValue=$(read_input "Enter a valid value ")
                            fieldValue="$(validate_data_type "$fieldDataType" "$fieldValue")"
                            duplicate_found=true
                            break
                        fi

                done
                if [[ "$duplicate_found" == false ]] 
                then
                    break
                fi
        done
    fi
    echo $fieldValue



}

table_exists()
{
    local tableName=$1
    while true
    do
        if [[ -f $tableName.tb ]]
        then    

                error_message  "A table with this name already exists! ❌"
                PS3="🔹 Please enter your option: "
                select  option in "🔄 Choose another name" "Exit ❌"
                do
                    case $option in
                    "🔄 Choose another name")
                        
                        tableName=$(read_input "Choose another name: ")
                        validate_name $tableName
                        break
                        ;;
                    "Exit ❌")
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


