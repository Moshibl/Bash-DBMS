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
    local tableName=$(read_input "👉 Please enter the name of the table: ")
    # set +x
    tableName=$(validate_name "$tableName")
    # set -x
    table_exists $tableName
    # set +x

    # Step 2: Create an empty data file for storing records and metadata
    # - Store actual table data in a separate `.table` file and columnName in .meta
    # 
    touch $tableName.tb $tableName.meta

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
      local columnName=$(read_input "👉 Please enter the name of the column: ")
      columnName=$(validate_name "$columnName")
      local columnDataType=$(choose_data_type)
      local columnUniqueness=$(choose_uniqueness)
      metaData+=("${columnName}":${columnDataType}:${columnUniqueness})


    done

  
    # Step 4: Ask the user to enter the number corresponding to the primary key column.
    # - Validate the selection:
    #   - Ensure the input is a valid number.
    clear
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
    printf "%s\n" "${metaData[@]}" > $tableName.meta
    

    
    # Step 6: Display a success message after table creation
    clear
    success_message "🎉 Table '$tableName' has been successfully created! 🚀"

}



list_tables() {
# Function to list all available tables in the currently connected database.
# After listing the tables, the function will prompt the user with two options:
# 1) Choose a table to perform record operations (Insert, Select, Delete, Update).
# 2) Exit back to the database menu.
# If the user selects a table, they will be navigated to the record operations menu,
# where they must choose an operation or exit.
db_name="DB"
PS3="$db_name# "
cd test_db/
echo "Select a table from $db_name:"
echo""
select tb_name in $(ls *.tb | sed 's/.tb//') 
do
if [ ! -f $tb_name.tb ]; then
    echo "Table Doesn't Exist!"
    return 1
fi
  case $tb_name in
    $tb_name)
      selected_table=$tb_name
      PS3="$selected_table# "
      echo""
      echo "Selected Table: $selected_table"
      print_table
      echo""
      break
      ;;
    *)
      echo "Invalid choice. Please select a table."
      exit
      ;;
  esac
done
select next in "Perform Operations" "Exit"
do
  case $next in
    "Perform Operations")
      perform_operations $selected_table

      ;;
    "Exit")
      echo "Exit"
      exit
      ;;
    *)
      echo "Invalid choice. Please select an option."
      ;;
  esac
done
}

perform_operations() {
echo""
echo "Select Operation perform on $selected_table:"
echo""
select operation in "Select Record" "Insert Record" "Update Record" "Delete Record"  "Drop Table" "Exit"
do
  case $operation in
    "Select Record")
      select_from_table $selected_table
      perform_operations $selected_table
      ;;
    "Insert Record")
      insert_into_table $selected_table
      perform_operations $selected_table
      ;;
    "Update Record")
      update_table  $selected_table
      perform_operations $selected_table
      ;;
    "Delete Record")
      delete_from_table $selected_table
      perform_operations $selected_table
      ;;
    "Drop Table")
      drop_table  $selected_table
      perform_operations $selected_table
      ;;
    "Exit")
      echo "Exit"
      break
      ;;
    *)
      echo "Invalid choice. Please select an operation."
      ;;
  esac
done
    true
}

# Function to drop a table
drop_table() {
    # Confirm and delete the selected table and its metadata
    echo "Drop Table"
}

# list_tables
create_table 