#!/bin/bash
# This script handles table-level operations within a connected database:
# - Create Table
# - List Tables
# - Drop Table

source validation.sh  
source record-operations.sh


# Function to create a table
create_table() {
  # Step 1: Ask the user for the table name
    # - Validate that the name follows naming conventions
    # - Ensure the table name does not already exist
    # set -x
    local tableName=$(read_input "👉 Please enter the name of the table: ")
    # set +x
    validate_name $tableName
    # set -x
    table_exists $tableName
    # set +x



    # Step 2: Define table columns
    # - Ask the user how many columns they want
    # - For each column:
    #   - Ask for column name and validate it (must not contain spaces/special characters)
    #   - Ask for column data type (e.g., STRING, INTEGER) and validate it
    #   - Ask if this column should be UNIQUE (Yes/No)
    


    
    # Step 3: Ask the user to enter the number corresponding to the primary key column.
    # - Validate the selection:
    #   - Ensure the input is a valid number.
 
    
    # Step 4: Store metadata
    # - Save column definitions, data types, and constraints (UNIQUE, PRIMARY KEY)
    # - Store this information in a `.meta` file inside the database directory
    
    # Step 5: Create an empty data file for storing records
    # - Store actual table data in a separate `.table` file
    
    # Step 6: Display a success message after table creation
}



list_tables() {
# Function to list all available tables in the currently connected database.
# After listing the tables, the function will prompt the user with two options:
# 1) Choose a table to perform record operations (Insert, Select, Delete, Update).
# 2) Exit back to the database menu.
# If the user selects a table, they will be navigated to the record operations menu,
# where they must choose an operation or exit.
    true
}

# Function to drop a table
drop_table() {
    # Confirm and delete the selected table and its metadata
    true
}


create_table