#!/bin/bash
# This script contains reusable utility functions for the DBMS
# - Formatting output
# - Handling user input safely
# - Displaying messages

# Function to print formatted tables

# local selected_col=$(grep -in "$option" "$tableDir.meta" | cut -d: -f1)
# local match=$(awk -F: -v selected_col=$selected_col ' {print $selected_col} ' $tableDir.tb)
print_table() {
    prompt_message "Table Selected: $tb_name"
    col_count=$(wc -l "$tableDir.meta")
    
    awk -v col_count="$col_count" '
    BEGIN {
        FS=":"
        OFS=" | "
        column_width = 12
        LS = "+"
        for (j = 1; j <= col_count; j++) {
            LS = LS sprintf("%-*s+", column_width, "--------------") 
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
    ' "$tableDir.header" "$tableDir.tb" 
    rm "$tableDir.header"
}
# # Function to handle user input
read_input() {
    local message=$1
    read -r -p "$message" name
    echo "$name" 
}
 # Function to display error messages
error_message() {
   local message=$1
   echo -e "\e[1;31m$message\e[0m" >&2
}
success_message() {
   local message=$1
   echo -e "\e[1;32m$message\e[0m" >&2
}
prompt_message() {
   local message=$@
   echo -e "\e[1;36m$message\e[0m" >&2
}
# =======================================================================
#                           Helper Functions
# =======================================================================

choose_data_type() {

    select option in "INTEGER 📊"  "STRING 🔤" "DATE 📅"
    do
    case $option in
        "INTEGER 📊")
            echo "INTEGER"
        break
        ;;
        "STRING 🔤")
            echo "STRING"
        break
        ;;
        "DATE 📅")
            echo "DATE"
        break
        ;;
    esac
    done
}

choose_uniqueness(){

    select option in "Yes 🔒"  "No ❌"
    do
        case $option in
        "Yes 🔒")
            echo "UNIQUE"
            break
        ;;
        "No ❌")
            echo "NULL"
            break
        ;;
        esac
    done
}
