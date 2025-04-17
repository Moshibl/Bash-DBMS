#!/bin/bash
# This script handles table-level operations within a connected database:
# - Create Table
# - List Tables
# - Drop Table

source validation.sh  
source record-operations.sh
source utils.sh


create_table() {

    clear
    local dataBaseDir=$1
    prompt_message "Please enter the name of the table: "
    local tableName=$(read_input "$PS3")
    tableName=$(validate_name "$tableName")
    table_exists "$dataBaseDir"/$tableName
    checkFileEXists=$?
    if [[ "$checkFileEXists" -eq 0 ]]
    then
      return 0
    fi

    echo
    prompt_message "Please enter the number of columns for your table: "
    local nOfColumns=$(read_input "$PS3")
    nOfColumns=$(validate_column_count $nOfColumns)
    for(( i=1; i<=nOfColumns; i++))
    do
      echo
      prompt_message  "Please enter the name of the column: "
      local columnName=$(read_input "$PS3")
      columnName=$(validate_name "$columnName")
      echo
      prompt_message "Please enter the data type for the column ( INTEGER 📊 /  STRING 🔤 / DATE 📅): "
      local columnDataType=$(choose_data_type)
      echo
      prompt_message "Would you like this field to be unique? ( Yes 🔒 /  No ❌ ): "
      local columnUniqueness=$(choose_uniqueness)
      local metaData+=("${columnName}":${columnDataType}:${columnUniqueness})
    done

    fieldNames=($(printf "%s\n" "${metaData[@]}" | awk -F':' '{print $1}'))
    echo
    prompt_message "Please choose the column you want to set as the Primary Key (PK): "
    select option in ${fieldNames[@]}
    do
    case $REPLY in 
     [1-$((${#fieldNames[@]}))])   
        pkIndex=$((REPLY - 1))  
        metaData[pkIndex]=$(echo "${metaData[pkIndex]}" | awk -F':' 'BEGIN{OFS=":"} {$NF="PK"; print $0}')
        break
      ;;
      *)
      echo "Invalid choice! ❌ Please select a Primary Key (PK) from the available options. 🔑"
      ;;
    esac
    done

    local tableDataDir="$dataBaseDir"/$tableName.tb
    local tableMetaDir="$dataBaseDir"/$tableName.meta
    touch "$tableDataDir" "$tableMetaDir" 
    printf "%s\n" "${metaData[@]}" > "$tableMetaDir"
    
    clear
    success_message "Table '$tableName' has been successfully created! 🚀"
}


list_tables() {
  clear
  local dbTablesDir="$1"
  if [[ -z $(ls -A "$dbTablesDir"/*.tb 2>/dev/null) ]]
  then
      error_message "No tables found in this database! ❌"
      return 
  fi

  for table in "$dbTablesDir"/*.tb
  do
    local tables+=($(basename "$table" .tb))
  done 

  DB_name=$(basename "$dbTablesDir")
  while true
  do 
    prompt_message "Select a table from $DB_name: "
    local tb_name
    select tb_name in ${tables[@]} "Go Back"
    do
          case $tb_name in
            "Go Back")
              clear
              break 2
            ;;
            $tb_name)
              clear
              success_message "Selected Table: $tb_name"
              perform_operations "$dbTablesDir"/$tb_name
              PS3="🔹 $DB_name# "
              break
              ;;
            *)
              error_message "Invalid choice! ❌ Please select a table."
              ;;
          esac
    done
  done

}


perform_operations() {
    local tableDir="$1"
    while true 
    do 
      PS3="🔹 $tb_name# "
      prompt_message "Select the operation you want to perform on $tb_name:"
      select operation in "Select" "Insert" "Update" "Delete"  "Go Back"
      do
        case $operation in
          "Select")
            clear
            select_from_table "$tableDir"
            break
            ;;
          "Insert")
            clear
            insert_into_table "$tableDir"
            break
            ;;
          "Update")
            clear
            update_table  "$tableDir"
            break
            ;;
          "Delete")
            clear
            delete_from_table "$tableDir"
            break
            ;;
          "Go Back")
            clear
            break 2
            ;;
          *)
            error_message "Invalid choice! ❌ Please select an operation."
            ;;
        esac
      done
    done
}


drop_table() {
    local dbTablesDir="$1"
    if [[ -z $(ls -A "$dbTablesDir"/*.tb 2>/dev/null) ]]
    then
        error_message "No tables found in this database! ❌"
        return 
    fi
    local dbTablesDir="$1"
    for table in "$dbTablesDir"/*.tb
    do
      local tables+=($(basename "$table" .tb))
    done 

    DB_name=$(basename "$dbTablesDir")
    clear
  
    prompt_message "Select the table you want to drop from $DB_name 🗑️:"
    select option in ${tables[@]} "Abort ❌"
     do
     if [[ $option == "Abort ❌" ]]
     then
        clear
        return
     elif [[ -n $option ]]
     then
          local tb_name=$option
          break
     else 
       error_message "Invalid choice! ❌ Please select a table."   
     fi
     done

    clear
    prompt_message "Are you sure you want to delete $tb_name? "
    select confirm in "Yes" "No"
    do
      case $confirm in
        "Yes")
          clear
          success_message "$tb_name Deleted ✅"
          rm -f "$dbTablesDir"/$tb_name.* 2> /dev/null
          break
          ;;
        "No")
          clear
          success_message "Delete Aborted"
          break
          ;;
      esac
    done
}