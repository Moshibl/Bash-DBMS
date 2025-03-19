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
    local databaseDire=$(database_exists) 
    DB_name=$(read_input "Enter Database Name: ")
    DB_name=$(validate_name $DB_name)
    if [ -d "$databaseDire"/$DB_name ]
    then
        error_message "Database already exists!"

    else
        mkdir -p "$databaseDire"/$DB_name
        success_message "Database created successfully"
    fi
    clear
    success_message "🎉 DataBase '$DB_name' has been successfully created! 🚀"


}

# Function to list available databases
list_databases() {
    local databaseDire=$(database_exists) 

    
    if [ -z "$(ls -A "$databaseDire" )" ]
    then
        error_message "No databases found!"
    else
       clear
        success_message "Available Databases:"
        ls -1 "$databaseDire"
        echo""
    fi
}

# Function to connect to a database
connect_database() {
    # Allow user to choose a DB and navigate to table operations
    local databaseDire=$(database_exists) 
    local current_PS3=$PS3


    prompt_message "Select a Database: "
    while true
    do
        clear
        prompt_message "Select a Database: "
        PS3="DBMS# "
        select DB_name in $(ls "$databaseDire") "Exit"
        do
            case $DB_name in
                "Exit")
                    break 2
                    ;;

                $DB_name)
                    PS3="$DB_name# "
                    success_message "Connected to $DB_name!"

                    list_tablesOperations "$databaseDire/$DB_name"

                    break
                    ;;

                *)
                    error_message "Invalid selection"
                    ;;
            esac
        done
    done


}

# Function to drop a database
drop_database() {
    # Confirm and delete the selected database directory
    list_databases
    DB_name=$(read_input "Select the database you want to drop: ")
    if [ -d $DB_name ]
    then
        PS3="$DB_name# "
        select confirm in "Yes" "No"
        do
        case $confirm in
            "Yes")
            success_message "$DB_name Dropped"
            rm -r $DB_name
            break
            ;;
            "No")
            success_message "Drop Aborted"
            break
            ;;
        esac
        done
    else
        error_message "This Database Doesn't exist"
    fi
    sleep 10
}

list_tablesOperations(){
    local db_dir=$1
    prompt_message "📌 Please choose an operation to perform on the database:"
    echo""
    while true
    do      
            clear
            prompt_message "⚡ Choose from the following operations for your database:"
            PS3="📌 Please choose an operation to perform on the database: "
            select operation in "create_table" "list_tables" "drop_table" "Exit"
            do
            case $operation in
                "create_table")
                create_table "$db_dir"
                break
                ;;
                "list_tables")
                list_tables "$db_dir"
                break

                ;;
                "drop_table")
                drop_table  "$db_dir"
                break

                ;;
                "Exit")
                success_message "Goodbye!"
                break 2
                ;;
                *)
                error_message "Invalid choice. Please select an operation."
                ;;
            esac
            done  
    done
}