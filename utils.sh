#!/bin/bash
# This script contains reusable utility functions for the DBMS
# - Formatting output
# - Handling user input safely
# - Displaying messages

# Function to print formatted tables
print_table() {
col_count=4
    awk -v col_count="$col_count" '
    BEGIN {
        FS=":"
        OFS=" | "
        column_width = 10
        LS = "+"
        for (j = 1; j <= col_count; j++) {
            LS = LS sprintf("%-*s+", column_width, "------------") 
        }
    }

    NR==1 {
        print LS
        output = "|"
        for (i = 1; i <= col_count; i++) {
            output = output sprintf(" %-*s |", column_width, $i)
        }
        print output
        print LS
        next
    }

    {
        output = "|"
        for (i = 1; i <= col_count; i++) {
            output = output sprintf(" %-*s |", column_width, $i)
        }
        print output
    }

    END {
        print LS
    }
    ' test.meta $tb_name.tb
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