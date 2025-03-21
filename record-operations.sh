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

    if [ ! -s "$tableDir.tb" ]; then
        error_message "This table is still empty or has no records. ❌"
        prompt_message "Do you want to add records now? "
        select choice in "Yes" "No"
            do 
                case $choice in 
                    "Yes")
                        insert_into_table $tableDir.tb
                        break
                        ;;
                    "No")
                        return
                        ;;
                    *)
                        error_message "Invalid Choice"
                        ;;
                esac
            done
    fi

    select operation in "Select All" "Select Record by Value" "Select Record by Key" "Select Column" "Go Back"
    do
        case $operation in 
            "Select All")
                print_table
                break
                ;;
            "Select Record by Value")
                select_by_value
                break
                ;;
            "Select Record by Key")
                select_by_key
                break
                ;;
            "Select Column")
                select_column
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
    select option in "Update one record based on PK" "Updete all occurrences"
    do
    case $option in
    "Update one record based on PK")
        update_record_by_pk "$tableDir"
        break
    ;;
    "Updete all occurrences")
        batch_update_by_value "$tableDir"
        break
    ;;
    esac
    done
    

}
update_record_by_pk()
{
    local tableDir="$1"
    local fieldNum=$(grep -in "PK" "$tableDir.meta" | cut -d ":" -f1)
    local PK_oldValue=$(read_input "Please enter the PK of the record you want to update 🔑: ")


    
    record=$(awk -F":" -v fieldNum="$fieldNum" -v PK_oldValue="$PK_oldValue"  '$fieldNum==PK_oldValue {print NR":"$0}' "$tableDir.tb") 
    # ---------> validate this record exists
    if [[ -z "$record" ]]
    then
        error_message "No record found with PK = $PK_oldValue ❌"
        return 
    fi

    lineNum=$(echo $record | cut -d ":" -f1)
    
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

# --> search about PK line 
# --> ask for column that want to update
# --> ask about old value
# --> search in file for this value 
# --> ask about new value for this column    
# --> check validation_dataType and uniqueness
# --> updata this value 

# Function to delete a specific record
delete_from_table() {
    local tableDir="$1"
    local fieldNum=$(grep -in "PK" "$tableDir.meta" | cut -d ":" -f1)
    local PK_oldValue=$(read_input "Please enter the PK of the record you want to delete 🔑: ")
    local record=$(awk -F":" -v fieldNum="$fieldNum" -v PK_oldValue="$PK_oldValue" \
        '$fieldNum == PK_oldValue { print NR }' "$tableDir.tb")

    if [[ -z "$record" ]]; then
        error_message "No record found with PK = $PK_oldValue ❌"
        return
    fi
    sed -i "${record}d" "$tableDir.tb"
    success_message "Record with PK = $PK_oldValue deleted successfully ✅"
}


select_by_value(){
    echo""
    term=$(read_input "Enter The value you want to select: ")
    echo""
    grep -i $term $tableDir.tb
    echo""
}

select_by_key() {
    echo ""
    local key=$(grep -in "PK" "$tableDir.meta" | cut -d: -f1)

    if [ -z "$key" ]; then
        error_message "No primary key found in metadata!"
        return
    fi
    enter=$(read_input "Enter the value of the PK you want to select by: ")
    awk -F: -v key="$key" -v search_value="$enter" '$key == search_value' "$tableDir.tb"
    echo ""
}


select_column() {
    local col=$(read_input "Choose the column number")
    awk -F: -v col="$col" '
    {
        if (col > 0 && col <= NF) 
            print $col
        else 
            print "Invalid column number"
    }' "$tableDir.tb"
}
