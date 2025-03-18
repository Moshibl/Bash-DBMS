#!/bin/bash
# This script handles database-level operations: 
# - Create Database
# - List Databases
# - Connect to Database
# - Drop Database

source validation.sh  # Import validation functions
source table-operations.sh

# Function to create a new database
create_database() {
    # Ask for DB name, validate, and create as a directory
    DB_name=$(read_input "Enter Database Name: ")
    DB_name=$(validate_name $DB_name)
    if [ -d Databases/$DB_name ]
    then
        error_message "Database already exists!"

    else
        mkdir Databases/$DB_name
        success_message "Database created successfully"
    fi
}

# Function to list available databases
list_databases() {
    # Display all database directories
    if [ ! -d Databases ]
    then
        mkdir Databases
    fi
    cd Databases
    if [ -z "$(ls -A )" ]
    then
        error_message "No databases found!"
    else
        success_message "Available Databases:"
        ls -1
        echo""
    fi
}

# Function to connect to a database
connect_database() {
    # Allow user to choose a DB and navigate to table operations
    PS3="DBMS# "
    cd Databases/
    prompt_message "Select a Database: "
    select DB_name in $(ls)
    do
        if [ -z $DB_name ]
        then
            error_message "Database does not exist!"
            return 1
        fi
        case $DB_name in
            $DB_name)
                cd $DB_name
                PS3="$DB_name# "
                success_message "Connected to $DB_name!"
                list_tables DB_name
                break
                ;;
            *)
                error_message "Invalid selection"
                ;;
        esac
    done

}

# Function to drop a database
drop_database() {
    # Confirm and delete the selected database directory
    cd Databases/
    ls
    DB_name=TEST
    if [ -d $DB_name ]
    then
        rm -r $DB_name
    else
        error_message "This Database Doesn't exist"
    fi
}

# create_database
# list_databases
connect_database
# drop_database