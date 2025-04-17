#!/bin/bash
# Main script for the Bash Shell Script DBMS
# Displays the main menu and handles user navigation

source db-operations.sh
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
success_message "🎉 Welcome to Bash DBMS! 🎉"
echo 

main_menu() {
    while true
    do  
        prompt_message "What would you like to do?"
        PS3="🔹 DBMS# "
        select option in "Create DB" "List DBs" "Connect DB" "Drop DB" "Exit"
        do
            case $option in
            "Create DB")
                create_database
                break 
            ;;
            "List DBs")
                list_databases
                break
            ;;
            "Connect DB")
                connect_database
                break
            ;;
            "Drop DB")
                drop_database
                break
            ;;
            "Exit")
                pacman_exit
                ;;
            *)
            echo "Invalid option. Please try again. ❌"
            ;;
            esac    
        done
    done
}

main_menu

