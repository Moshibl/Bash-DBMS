#!/bin/bash
# This script handles record-level operations inside a table:
# - Insert Record
# - Select Records
# - Delete Record
# - Update Record

# source validation.sh  # Import validation functions


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
    echo""
    echo $1
    echo "Insert Record"
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



