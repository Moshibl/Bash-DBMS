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
    dbdir=$(dirname $tableDir)
    if [ ! -s "$tableDir.tb" ]; then
        error_message "This table is still empty or has no records. ❌"
        prompt_message "Do you want to add records now? "
        select choice in "Yes" "No"
            do 
                case $choice in 
                    "Yes")
                        insert_into_table $tableDir
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
                clear
                awk -F: '{ printf "%s%s", (NR==1 ? "" : ":"), $1 } END { print "" }' $tableDir.meta > $dbdir/$tb_name.header
                print_table
                break
                ;;
            "Select Record by Value")
                clear
                select_by_value
                break
                ;;
            "Select Record by Key")
                clear
                select_by_key
                break
                ;;
            "Select Column")
                clear
                select_column
                break
                ;;
            "Go Back")
                clear
                break
                ;;
            *)
                clear
                error_message "Invalid Choice, please Try again"
                ;;
        esac
    done           
}

# Function to insert a new record
insert_into_table() {
    clear
    # Validate input types, enforce primary key constraints
    # Append data to the table file
    local tableDir="$1"
    local fieldNum=0
    local record=""
    prompt_message "Inserting Into: $tb_name"
    
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
    clear
    success_message "✅ Record inserted successfully: [$record]"
}

# Function to update a record
update_table() {
    # Modify an existing record while keeping data integrity
    prompt_message "Updating on: $tb_name"
    local tableDir="$1"
    select option in "Update one record based on PK 🔑" "Updete all occurrences 🔄" "Go Back"
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
    "Go Back")
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

    local fieldsNames+=($(awk -F":" '{print $1}' "$tableDir.meta"))
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


delete_from_table() {
    prompt_message "Deleting Records From: $tb_name"
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

##BUG
select_by_value(){
    prompt_message "Select By Value on: $tb_name"
    term=$(read_input "Enter the value you want to select: ")
    echo ""

    awk -F: -v term="$term" '
    BEGIN{
        found=0
        }
        {
        for (i = 1; i <= NF; i++) {
            if ($i == term) {
                print $0
                found=1
                }
            }
        }
    END{
        if (found == 0) 
        print "Value not found" 
        }
    ' "$tableDir.tb"

    echo ""
}


select_by_key() {
    prompt_message "Select By Key on: $tb_name"
    local key=$(grep -in "PK" "$tableDir.meta" | cut -d: -f1)

    if [ -z "$key" ]; then
        error_message "No primary key found in metadata!"
        return
    fi
    enter=$(read_input "Enter the value of the PK you want to select by: ")
    awk -F: -v key="$key" -v search_value="$enter" '$key == search_value {print $0}' "$tableDir.tb"
    echo ""
}


select_column() {
    prompt_message "Select Column from: $tb_name"
    if [ ! -f "$tableDir.meta" ]; then
        error_message "Metadata file not found!"
        return 1
    fi
    columns=($(awk -F: '{print $1}' $tableDir.meta))

    if [ ${#columns[@]} -eq 0 ]; then
        error_message "No columns found in metadata!"
        return 1
    fi

    echo "Select a column:"
    select option in "${columns[@]}" "Go Back"
    do
        if [[ $option == "Go Back" ]]
        then
            break
        elif [[ -n "$option"  ]]
        then 
            local selected_col=$(grep -in "$option" "$tableDir.meta" | cut -d: -f1)
            awk -F: -v selected_col=$selected_col '{ print $selected_col }' $tableDir.tb  
            break
        else
            error_message "Invalid Choice"
        fi
    done
}