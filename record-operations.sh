#!/bin/bash
# This script handles record-level operations inside a table:
# - Insert Record
# - Select Records
# - Delete Record
# - Update Record

source validation.sh  # Import validation functions


# Function to select and display records
select_from_table() {
    # Read and format table data for display
    echo""
    echo $1
    echo "Select Record"
}
# Function to insert a new record
insert_into_table() {
    # Validate input types, enforce primary key constraints
    # Append data to the table file
    local tableDir="$1"
    local fieldNum=0
    
    exec 3< "$tableDir.meta"
    while read -r line <&3
    do
        ((fieldNum++))
        local fieldName=$( echo $line | cut -d ":" -f1 ) 
        local fieldDataType=$( echo $line | cut -d ":" -f2 ) 
        local fieldConstraint=$( echo $line | cut -d ":" -f3 )
        local fieldValue="$(read_input "Please Enter Value of $fieldName: ")"
        fieldValue="$(validate_uniqueness_dataType "$tableDir.tb" "$fieldDataType" "$fieldConstraint" "$fieldValue" "$fieldNum")"
        record+="$fieldValue:" 
    done
    exec 3<&-
    record="${record%:}"
    echo $record >> "$tableDir.tb"
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



