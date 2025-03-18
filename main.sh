#!/bin/bash
# Main script for the Bash Shell Script DBMS
# Displays the main menu and handles user navigation

# Import necessary scripts
source db-operations.sh

# Function to display the main menu
main_menu() {

    echo "========================================="
    echo "🎉 Welcome to Bash DBMS! 🎉"
    echo "📌 Manage your databases easily using this tool."
    echo "========================================="
    echo ""
    PS3="📌 Please choose an option:"
    select option in "Create DB" "List DBs" "Connect DB" "Drop DB" "Exit"
    do
        case $option in
        "Create DB")
            create_database 
        ;;
        "List DBs")
            list_databases
        ;;
        "Connect DB")
            connect_database
        ;;
        "Drop DB")
            drop_database
        ;;
        "Exit")
            break
            ;;
        *)
        echo "❌ Invalid option. Please try again."
        ;;
        esac    
    done
}

# Start the script by calling the main menu
main_menu
