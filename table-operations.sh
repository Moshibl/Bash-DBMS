#!/bin/bash
# This script handles table-level operations within a connected database:
# - Create Table
# - List Tables
# - Drop Table

# source validation.sh  # Import validation functions
source validation.sh  
source record-operations.sh
source utils.sh


# Function to create a table
create_table() {
  # Step 1: Ask the user for the table name
    # - Validate that the name follows naming conventions
    # - Ensure the table name does not already exist
    # set -x
    clear
    local dataBaseDir=$1
    local tableName=$(read_input "Please enter the name of the table: ")
    # set +x
    tableName=$(validate_name "$tableName")
    table_exists "$dataBaseDir"/$tableName
    checkFileEXists=$?
    if [[ "$checkFileEXists" -eq 0 ]]
    then
      return 0
    fi

    # Step 2: Create an empty data file for storing records and metadata
    # - Store actual table data in a separate `.table` file and columnName in .meta
    # 


    # Step 3: Define table columns
    # - Ask the user how many columns they want
    # - For each column:
    #   - Ask for column name and validate it (must not contain spaces/special characters)
    #   - Ask for column data type (e.g., STRING, INTEGER) and validate it
    #   - Ask if this column should be UNIQUE (Yes/No)
    local  metaData
    local nOfColumns=$(read_input "📊 Please enter the number of columns for your table: ")
    nOfColumns=$(validate_column_count $nOfColumns)

    for(( i=1; i<=nOfColumns; i++))
    do
      local columnName=$(read_input "Please enter the name of the column: ")
      columnName=$(validate_name "$columnName")
      local columnDataType=$(choose_data_type)
      local columnUniqueness=$(choose_uniqueness)
      local metaData+=("${columnName}":${columnDataType}:${columnUniqueness})
    done
    # Step 4: Ask the user to enter the number corresponding to the primary key column.
    # - Validate the selection:
    #   - Ensure the input is a valid number.
    fieldNames=($(printf "%s\n" "${metaData[@]}" | awk -F':' '{print $1}'))
    PS3="🔑 Please choose the column you want to set as the Primary Key (PK): "
    select option in ${fieldNames[@]}
    do
    case $REPLY in 
     [1-$((${#fieldNames[@]}))])   
        pkIndex=$((REPLY - 1))  
        metaData[pkIndex]=$(echo "${metaData[pkIndex]}" | awk -F':' 'BEGIN{OFS=":"} {$NF="PK"; print $0}')
        break
      ;;
      *)
      echo "⚠️ Invalid choice! Please select a Primary Key (PK) from the available options. 🔑"
      ;;
    esac
    done
    
    # Step 5: Store metadata
    # - Save column definitions, data types, and constraints (UNIQUE, PRIMARY KEY)
    # - Store this information in a `.meta` file inside the database directory
    local tableDataDir="$dataBaseDir"/$tableName.tb
    local tableMetaDir="$dataBaseDir"/$tableName.meta
    touch "$tableDataDir" "$tableMetaDir" 

    printf "%s\n" "${metaData[@]}" > "$tableMetaDir"
    
    # Step 6: Display a success message after table creation
    clear
    success_message "Table '$tableName' has been successfully created! 🚀"
}



list_tables() {
  clear
  # Function to list all available tables in the currently connected database.
  # After listing the tables, the function will prompt the user with two options:
  # 1) Choose a table to perform record operations (Insert, Select, Delete, Update).
  # 2) Exit back to the database menu.
  # If the user selects a table, they will be navigated to the record operations menu,
  # where they must choose an operation or exit.
  local dbTablesDir="$1"
  if [[ -z $(ls -A "$dbTablesDir"/*.tb 2>/dev/null) ]]
  then
      error_message "No tables found in this database"
      return 
  fi

  for table in "$dbTablesDir"/*.tb
  do
    local tables+=($(basename "$table" .tb))
  done 

  DB_name=$(basename "$dbTablesDir")
  prompt_message "Tables are available in $DB_name. 📜"
  while true
  do 
    prompt_message "Select a table from $DB_name: "
    PS3="$DB_name# "
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
              PS3="$tb_name# "
              success_message "Selected Table: $tb_name"
              perform_operations "$dbTablesDir"/$tb_name
              break
              ;;
            *)
              error_message "Invalid choice. Please select a table."
              ;;
          esac
    done
  done

}


perform_operations() {
    local tableDir="$1"
    while true 
    do 
      PS3="Select the operation you want to perform on $tb_name:  "
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
            error_message "Invalid choice. Please select an operation."
            ;;
        esac
      done
    done
}

# Function to drop a table
drop_table() {
    local dbTablesDir="$1"
    if [[ -z $(ls -A "$dbTablesDir"/*.tb 2>/dev/null) ]]
    then
        error_message "No tables found in this database"
        return 
    fi
    local dbTablesDir="$1"
    for table in "$dbTablesDir"/*.tb
    do
      local tables+=($(basename "$table" .tb))
    done 

    DB_name=$(basename "$dbTablesDir")
    clear
    prompt_message "Tables are available in $DB_name.📜"
    PS3="🗑️ Select a table from '$DB_name' that you want to drop:"
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
       error_message "Invalid choice. Please select a table."   
     fi
     done

    clear
    prompt_message "Are you sure you want to delete $tb_name? "
    select confirm in "Yes" "No"
    do
      case $confirm in
        "Yes")
          clear
          success_message "$tb_name Deleted"
          rm -f "$dbTablesDir"/$tb_name.*
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