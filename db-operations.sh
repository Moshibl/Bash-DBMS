#!/bin/bash
# This script handles database-level operations: 
# - Create Database
# - List Databases
# - Connect to Database
# - Drop Database
clear
source validation.sh  # Import validation functions
source table-operations.sh

# Function to create a new database
create_database() {
    # Ask for DB name, validate, and create as a directory
    clear
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
    success_message "DataBase '$DB_name' has been successfully created! 🚀"
    echo
}

# Function to list available databases
list_databases() {

    local databaseDire=$(database_exists) 

    if [ -z "$(ls -A "$databaseDire" )" ]
    then
        error_message "No databases found!">&2
    else
        success_message "Available Databases:">&2
        ls -1 "$databaseDire"
    fi
    echo
}


connect_database() {
    clear
    local current_PS3=$PS3
    local databaseDire=$(database_exists) 
    if [ ! -d "$databaseDire" ]; then
        error_message "Databases directory not found!"
        return 1
    fi

    local databases=($(ls "$databaseDire"))
    if [ ${#databases[@]} -eq 0 ]; then
        error_message "No databases found!"
        return 1
    fi

    while true; do
        clear
        prompt_message "Select a Database:"
        PS3="DBMS# "
        select DB_name in "${databases[@]}" "Cancel"; do
            case $DB_name in
                "Cancel")
                    clear
                    PS3=$current_PS3
                    return
                    ;;
                "")
                    error_message "Invalid selection. Please try again."
                    break
                    ;;
                *)
                    if [ -d "$databaseDire/$DB_name" ]; then
                        clear
                        PS3="$DB_name# "
                        success_message "Connected to $DB_name!"
                        list_tablesOperations "$databaseDire/$DB_name"
                    else
                        error_message "Database not found!"
                    fi
                    break
                    ;;
            esac
        done
    done
}


# Function to drop a database
drop_database() {
    # Confirm and delete the selected database directory
    clear
    local databaseDire=$(database_exists) 
    Search=$(read_input "Search for database: ")
    local list=$(list_databases | grep -i "$Search")
    echo $list

    DB_name=$(read_input "Select the database you want to drop: ")
    if [ -d "$databaseDire"/$DB_name ]
    then
        PS3="$DB_name# "
        select confirm in "Yes" "No"
        do
        case $confirm in
            "Yes")
            clear
            success_message "$DB_name Dropped Successfully!"
            rm -r "$databaseDire"/$DB_name
            echo
            break
            ;;
            "No")
            clear
            success_message "Drop Aborted"
            echo
            break
            ;;
        esac
        done
    else
        clear
        error_message "This Database Doesn't exist"
    fi
}

list_tablesOperations(){
    clear
    local db_dir=$1
    while true
    do      
            # clear
            prompt_message "⚡ Please Choose the operation to perform on $DB_name:"
            PS3="$DB_name# "
            select operation in "Create Table" "List Tables" "Drop Table" "Go Back"
            do
            case $operation in
                "Create Table")
                create_table "$db_dir"
                break
                ;;
                "List Tables")
                list_tables "$db_dir"
                break
                ;;
                "Drop Table")
                drop_table  "$db_dir"
                break
                ;;
                "Go Back")
                break 2
                ;;
                *)
                error_message "Invalid choice. Please select an operation."
                ;;
            esac
            done  
    done
}