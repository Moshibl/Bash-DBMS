#!/bin/bash
# This script contains reusable utility functions for the DBMS
# - Formatting output
# - Handling user input safely
# - Displaying messages

# Function to print formatted tables
print_table() {
    # Format and display table data in a structured way
    true
}

# # Function to handle user input
read_input() {
    read -p "Enter a valid name: " name
    echo $name 
}

# # Function to display error messages
error_message() {
   message=$1
   echo -e "\e[1;31m$message\e[0m"
}
success_message() {
   message=$1
   echo -e "\e[1;32m$message\e[0m"
}