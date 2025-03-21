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

}

# Function to update a record
update_table() {
    # Modify an existing record while keeping data integrity
    local tableDir="$1"
    select option in "Update one record based on PK" "Updete all occurrences"
    do
    case $option in
    "Update one record based on PK")
        update_record_by_pk "$tableDir"
    ;;
    "Updete all occurrences")
        batch_update_by_value "$tableDir"
    ;;
    esac
    done
    

}
update_record_by_pk()
{
    # local tableDir="$1"
    local fieldNum=$(grep -in "PK" Writers.meta | cut -d ":" -f1)
    local PK_oldValue=$(read_input "Please enter the PK of the record you want to update 🔑: ")

    # ---------> validate this PK exists

    
    record=$(awk -F":" -v fieldNum="$fieldNum" -v PK_oldValue="$PK_oldValue"  '$fieldNum==PK_oldValue {print NR":"$0}' "Writers.tb") 
    lineNum=$(echo $record | cut -d ":" -f1)
    
    fieldsNames+=($(awk -F":" '{print $1}' "Writers.meta"))


    PS3="Enter the number of the column you want to update: "
    select option in "${fieldsNames[@]}"
    do
        case $option in
            $option)
                fieldNum=$(grep -in "$option" Writers.meta | cut -d ":" -f1)
                oldValue=$(echo "$record" | cut -d ":" -f"$((fieldNum + 1))")
                local newValue=$(read_input "Please enter new Value you want to update 🔑: ")
                sed -i "${lineNum}s|$oldValue|$newValue|" Writers.tb
                break
            ;;
            # ---> validate dataType to new value, constarint before Updating
            # 
        esac
    done

}

# --> search about PK line 
# --> ask for column that want to update
# --> ask about old value
# --> search in file for this value 
# --> ask about new value for this column    
# --> check validation_dataType and uniqueness
# --> updata this value 

# Function to delete a specific record
delete_from_table() {
    # Locate and remove a record based on conditions
    echo""
    echo $1
    echo "Delete Record"
}



update_record_by_pk