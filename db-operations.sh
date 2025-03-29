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
        error_message "Database already exists! ❌"
    else
        mkdir -p "$databaseDire"/$DB_name
        success_message "DataBase '$DB_name' has been successfully created! 🚀"
    fi
}

# Function to list available databases
list_databases() {

    local databaseDire=$(database_exists) 

    if [ -z "$(ls -A "$databaseDire" )" ]
    then
        error_message "No Databases found! ❌">&2
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
        error_message "Databases directory not found! ❌"
        return 1
    fi

    local databases=($(ls "$databaseDire"))
    if [ ${#databases[@]} -eq 0 ]; then
        error_message "No Databases found! ❌"
        return 1
    fi

    while true; do
        clear
        Search=$(read_input "Search for a Database: ")
        if [[ $Search == "."* || $Search == '\' ]]
        then
            error_message "Invalid Input! ❌"
            echo
            return
        fi
        local list=($(list_databases | grep -i "^$Search"))
        if [[ $list != "" ]]
        then
            prompt_message "${list[*]}"
            echo
        else
            error_message "No Matches found! ❌"
            echo
            return
        fi
        prompt_message "Select a Database:"
        PS3="DBMS# "
        select DB_name in "${list[@]}" "Cancel"; do
            case $DB_name in
                "Cancel")
                    clear
                    PS3=$current_PS3
                    return
                    ;;
                "")
                    clear
                    error_message "Invalid selection, Please try again! ❌"
                    break 2
                    ;;
                *)
                    if [ -d "$databaseDire/$DB_name" ]; then
                        clear
                        PS3="$DB_name# "
                        success_message "Successfully Connected to $DB_name ✅!"
                        list_tablesOperations "$databaseDire/$DB_name"
                        clear
                        break 2
                    else
                        error_message "Database not found! ❌"
                        break
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
    Search=$(read_input "Search for a Database: ")
    if [[ $Search == "."* || $Search == '\' ]]
    then
        error_message "Invalid Input!"
        echo
        return
    fi
    local list=($(list_databases | grep -i "^$Search"))
    if [[ $list != "" ]]
    then
        prompt_message "${list[*]}"

        echo
    else
        error_message "No Matches found! ❌"
        echo
        return
    fi
  
    prompt_message "Select the database you want to drop:"
    PS3="$DB_name# "
    select DB_name in "${list[@]}" "Cancel"; do
        case $DB_name in
            "Cancel")
                clear
                PS3=$current_PS3
                return
                ;;
            "")
                clear
                error_message "Invalid selection, Please try again! ❌"
                break 2
                ;;
            *)
            if [ -d "$databaseDire/$DB_name" ]; then
                select confirm in "Yes" "No"
                    do
                    case $confirm in
                        "Yes")
                        clear
                        success_message "$DB_name Dropped Successfully! ✅"
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
            fi
            break
                ;;
        esac
    done
   













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
                error_message "Invalid choice ❌. Please select an operation."
                ;;
            esac
            done  
    done
}