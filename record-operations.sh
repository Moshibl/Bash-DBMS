#!/bin/bash
# This script handles record-level operations inside a table:
# - Insert Record
# - Select Records
# - Delete Record
# - Update Record

# source validation.sh  # Import validation functions
source utils.sh


# Function to select and display records
select_from_table() {

    local tableDir="$1"
    select operation in "Select All" "Select Record" "Select Column"
    do
        case  $operation in 
            "Select All")
                print_table
                break
                ;;
            "Select Record")
                prompt_message "Choose The Select type: " 
                select_type
                break
                ;;
            "Select Column")
                select_column
                break
                ;;
        esac
    done           
}
# Function to insert a new record
insert_into_table() {
    # Validate input types, enforce primary key constraints
    # Append data to the table file
    local tableDir="$1"

    # cc=$(cat "$tableDir".meta)
    
    # echo insert fun $cc
    while read -r line
    do
    
        local fieldName=$( echo $line | cut -d ":" -f1 ) 
        local fieldDataType=$( echo $line | cut -d ":" -f2 ) 
        local fieldConstraint=$( echo $line | cut -d ":" -f3 )
        
        
        local fieldValue=$(read_input "Please Enter Value of $fieldName")
        validate_data_type $fieldDataType $fieldValue
        
       
    
    
    done < "$tableDir".meta
    # for each line i have to ask yoser to insert first field 
    # then send dataType and value  to vaidate datatype
    # then check uniquness  

    # in for loop i will use select---->
}

# Function to update a record
update_table() {
    # Modify an existing record while keeping data integrity
    echo""
    echo $1
    echo "Update Record"
}

# Function to delete a specific record
delete_from_table() {
    # Locate and remove a record based on conditions
    echo""
    echo $1
    echo "Delete Record"
}


select_type(){ 
    select type in "Select by Key" "Select by Value" "Go Back"
    do
        case $type in 
            "Select by Key")
                select_by_key
                break
                ;;
            "Select by Value")
                select_by_value
                break
                ;;
            "Go Back")
                break
                ;;
            *)
                error_message "Invalid Choice, please Try again"
                ;;
        esac
    done
}

select_by_value(){
    echo""
    term=$(read_input "Enter The value you want to search by: ")
    echo""
    grep -i $term $tableDir.tb
    echo""
}

select_by_key() {
    echo ""
    key=$(grep -in "PK" "$tableDir.meta" | cut -d: -f1)

    if [ -z "$key" ]; then
        error_message "No primary key found in metadata!"
        return
    fi
    enter=$(read_input "Enter the value of the PK you want to search by: ")
    awk -F: -v key="$key" -v search_value="$enter" '$key == search_value' "$tableDir.tb"
    echo ""
}


select_column(){
    
    select col in $tableDir.tb
    do
        case $col in
            $tableDir)
            cut -d : -f $tableDir
            break
            ;;
            *)
            error_message "Invalid choice, please try again"
            break
            ;;
        esac
    done
}
