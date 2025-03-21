#!/bin/bash
# This script handles record-level operations inside a table:
# - Insert Record
# - Select Records
# - Delete Record
# - Update Record

source validation.sh  # Import validation functions
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
    local fieldNum=0
     local record=""
    
    exec 3< "$tableDir.meta"
    while read -r line <&3
    do
        ((fieldNum++))
        local fieldName=$( echo $line | cut -d ":" -f1 ) 
        local fieldDataType=$( echo $line | cut -d ":" -f2 ) 
        local fieldConstraint=$( echo $line | cut -d ":" -f3 )
        local fieldValue
        fieldValue="$(read_input "Please Enter Value of $fieldName: ")"
        fieldValue="$(validate_uniqueness_dataType "$tableDir.tb" "$fieldDataType" "$fieldConstraint" "$fieldValue" "$fieldNum")"
        record+="$fieldValue:" 
    done
    exec 3<&-
    record="${record%:}"
    echo "$record" >> "$tableDir.tb"
    echo "✅ Record inserted successfully: [$record]"

}

# Function to update a record
update_table() {
    # Modify an existing record while keeping data integrity
    local tableDir="$1"
    select option in "Update one record based on PK 🔑" "Updete all occurrences 🔄"
    do
    case $option in
    "Update one record based on PK 🔑")
        update_record_by_pk "$tableDir"
        break
    ;;
    "Updete all occurrences 🔄")
        batch_update_by_value "$tableDir"
        break
    ;;
    esac
    done
    

}

update_record_by_pk()
{
    local tableDir="$1"
    # Retrieves the entire line along with its line number from the metadata file.
    # Extracts only the line number to determine the field position. 
    local fieldNum=$(grep -in "PK" "$tableDir.meta" | cut -d ":" -f1)
    #  ask user about PK
    local PK_oldValue=$(read_input "Please enter the PK of the record you want to update 🔑: ")


    # Retrieve the entire record from the database table.
    # Searches for the record where PK matches the given value.
    # Outputs the matching record along with its line number in the format: "lineNum:record
    record=$(awk -F":" -v fieldNum="$fieldNum" -v PK_oldValue="$PK_oldValue"  '$fieldNum==PK_oldValue {print NR":"$0}' "$tableDir.tb") 
   
   if [[ -z "$record" ]]
    then
        error_message "No record found with PK = $PK_oldValue ❌"
        return 
    fi

    lineNum=$(echo $record | cut -d ":" -f1)
    
    # Prompt the user to select a column to update
    # Retrieve the selected column's metadata (name, datatype, constraints)
    #  Extract the old value from the selected record
    # Ask the user for a new value and validate it based on datatype and constraints
    # Perform the update in the database using `sed`

    fieldsNames+=($(awk -F":" '{print $1}' "$tableDir.meta"))
    PS3="Enter the number of the column you want to update: "
    select option in "${fieldsNames[@]}"
    do
        case $option in
            $option)
                fieldNum=$(grep -in "$option" "$tableDir.meta" | cut -d ":" -f1)
                local fieldDataType=$(grep -i "$option" "$tableDir.meta" | cut -d ":" -f2 )
                local fieldConstraint=$(grep -i "$option" "$tableDir.meta" | cut -d ":" -f3 )
                oldValue=$(echo "$record" | cut -d ":" -f"$(($fieldNum + 1))")
                local newValue=$(read_input "Please enter new Value you want to update 📝: ")
                newValue="$(validate_uniqueness_dataType "$tableDir.tb" "$fieldDataType" "$fieldConstraint" "$newValue" "$fieldNum")"
                sed -i "${lineNum}s|$oldValue|$newValue|" "$tableDir.tb"
                break
            ;;
     
        esac
    done
    success_message "✅ Successfully updated '$oldValue' to '$newValue' in line $lineNum!"

}
batch_update_by_value()
{
    local tableDir="$1"
    local fieldsNames+=($(awk -F":" '{print $1}' "$tableDir.meta"))
    PS3="Enter the number of the column you want to update: "
    select option in "${fieldsNames[@]}"
    do
            if [[ -n "$option" ]]; then 
                local fieldNum=$(grep -in "$option" "$tableDir.meta" | cut -d ":" -f1)
                local fieldDataType=$(grep -i "$option" "$tableDir.meta" | cut -d ":" -f2 )
                local fieldConstraint=$(grep -i "$option" "$tableDir.meta" | cut -d ":" -f3 )
                local oldValue=$(read_input "Please enter old Value you want to update 📝: ")

                oldValueMatching=$(awk -F":" -v fieldNum=$fieldNum -v oldValue=$oldValue '$fieldNum==oldValue {print $fieldNum}' "$tableDir.tb")
                if [[ -z $oldValueMatching ]]
                then
                    error_message "No record found with $option = $oldValue ❌"
                    return

                fi
                local newValue=$(read_input "Please enter new Value you want to update 📝: ")
                newValue="$(validate_uniqueness_dataType "$tableDir.tb" "$fieldDataType" "$fieldConstraint" "$newValue" "$fieldNum")"
                awk -F":" -v fieldNum=$fieldNum -v oldValue=$oldValue -v newValue="$newValue" '{
                 OFS=":";
                 if($fieldNum==oldValue) $fieldNum=newValue;
                 print}' "$tableDir.tb" > temp && mv temp "$tableDir.tb"
 
                
                break

            else
                error_message "❌ Invalid choice! Please select a valid column number."
            fi
     
    done

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


# update_record_by_pk
# batch_update_by_value