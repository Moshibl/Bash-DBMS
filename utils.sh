#!/bin/bash
# This script contains reusable utility functions for the DBMS
# - Formatting output
# - Handling user input safely
# - Displaying messages

# Function to print formatted tables
print_table() {
col_count=4
ls *.tb | sed 's/.tb//'
read -p "Enter Table Name: " tb_name
if [ ! -f $tb_name.tb ]; then
    clear
    echo "Table Doesn't Exist!"
    return
else
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
fi
}

# # Function to handle user input
# read_input() {
#     # Read  user input
# }

# # Function to display error messages
# error_message() {
#     # Print error messages in red for better visibility
# }

print_table
