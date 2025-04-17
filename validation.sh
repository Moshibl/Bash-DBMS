#!/bin/bash
# This script contains validation functions used across the DBMS
# - Validate database/table names
# - Ensure correct data types
# - Check primary key uniqueness
source utils.sh

validate_name() {
    local name=$1
    if [[ -z $name ]]
    then
        echo
        prompt_message "Please enter the value ⚡" 
        name=$(read_input "$PS3")
    fi
    while true
    do
        if [[ $name =~ ^[a-zA-Z]+(_?[a-zA-Z0-9]+)*$ ]]
        then
            echo $name
            break
        fi

        error_message "Invalid input! ❌" 
        echo  
        prompt_message "Please enter a valid name: " 
        name=$(read_input "$PS3") 
    done
}

storage_exists() {
    if ! [ -d "$SCRIPT_DIR/Databases" ]
    then
        mkdir -p  "$SCRIPT_DIR/Databases"
    fi
    echo "$SCRIPT_DIR/Databases"
}


validate_data_type() {
    local fieldDataType=$1
    local fieldValue=$2
    while true
    do
    case $fieldDataType in 
        "INTEGER")
            if  [[ "$fieldValue" =~ ^[0-9]+$ && "$fieldValue" -ge 0  ]]
            then
                success_message "Entry $fieldValue Valid ✅" 
                break
            else
                error_message "Invalid input! Please enter a positive integer ❌ "
            fi
            ;;
        "STRING")
            if  [[ "$fieldValue" =~ ^[A-Za-z\ ]+$ ]]
            then
                success_message "Entry $fieldValue accepted ✅"
                break
            else
                error_message "Invalid: '$fieldValue' contains numbers or special characters.❌"
            fi
            ;;
        "DATE")
            if  [[ "$fieldValue" =~ ^([0-9]{4})-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$ ]]
            then
                success_message "Date accepted: $fieldValue ✅"
                break
            else
                error_message "Invalid date format! Please enter in YYYY-MM-DD format.❌"
                
            fi
        ;;
        *)
                error_message "Unknown data type: $fieldDataType ❌" 
        esac
        echo
        prompt_message "Enter a valid $fieldName " 
        fieldValue=$(read_input "$PS3")
    done
    echo $fieldValue
}


validate_uniqueness_dataType() {
    local DataFile=$1
    local fieldDataType=$2
    local fieldConstraint=$3
    local fieldValue=$4
    local fieldNum=$5

    fieldValue="$(validate_data_type "$fieldDataType" "$fieldValue")"
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
                            error_message "The value '$fieldValue' already exists in the database. ❌" 
                            prompt_message "Enter a valid value: " 
                            fieldValue=$(read_input "$PS3")
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

table_exists() {
    local tableName=$1
    while true
    do
        if [[ -f $tableName.tb ]]
        then    
            error_message  "A table with this name already exists! ❌" 
            select  option in "Choose another name 🔄" "Exit ❌"
            do
                case $option in
                "Choose another name 🔄")
                    prompt_message "Choose another name: " 
                    tableName=$(read_input "$PS3")
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

validate_column_count() {
    local nOfColumns=$1
    while true 
    do
      if ! [[ $nOfColumns =~  ^[1-9][0-9]*$  ]]
      then
        error_message "Invalid input! ❌" 
        prompt_message  "Please enter a positive number for the number of columns 📊: " 
        nOfColumns=$(read_input "$PS3")

      else
        success_message "Success! The number of columns has been accepted. ✅" 
        echo $nOfColumns
        break
      fi

    done 
}


