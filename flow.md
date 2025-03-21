# Psuedo code for the execution process of different stages
**Execution Process Flow**

- **User chooses from main menu options on Database Such as:**
    - **Create Database** – Create a new database as a directory.

        **Read DB name, regex validate & make sure it doesn't already exist, and create as a directory**
        ```bash 
        read db_name && [[ $db_name =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] && [[ ! -d "./Databases/$db_name" ]] && mkdir "./Databases/$db_name"
        ```
        
    - **List Databases** – Display all existing databases.
        ```bash 
        ls ./Databases/
        ```
    - **Connect to Database** – Select a database to manage tables.
        ```bash 
        select db_name in $(ls ./Databases/) && cd "./Databases/$db_name"
        ```
    - **Drop Database** – Delete a database.
        ```bash 
        read db_name && [[ -d "./Databases/$db_name" ]] && rm -r "./Databases/$db_name"
        ```


### **Database Menu (After Connecting to a Database):**
- **Create Table Flow:**

    - **Choose number of columns** – The user picks the number of columns in their database
        ```bash 
        read num_columns && echo "Columns: $num_columns" > "$table_name.meta"
        ```


    - **Define metadata in metadata file** – The user should be prompted to define the name for each column along with their restriction/type.
        ```bash 
        for ((i=1; i<=num_columns; i++)); do read col_name col_type; echo "$col_name:$col_type" >> "$table_name.meta"; done 
        ```
        ### Optional --Check if unique per entry
        

    - **The data itself is stored in a different file** - each row is a record

    - **PK Restriction** – The first column is selected to be PK by default and should be unique.
        ```bash 
        PK = $1
        echo $PK is the primary key
        head -n 1 "$table_name.meta" | cut -d':' -f1 > "$table_name.pk
        ```
        ### Optional --Select PK from given metadata {ID, Name, Email}


- **List Tables** – Show all tables in the current database.
    ```bash
    ls db/*.tb
    ```

- **Drop Table** – Delete a table.
    ```bash
    read table_name && [[ -f "$table_name.meta" ]] && rm "$table_name.meta" "$table_name.data"
    ```

- **Insert into Table** – Add records while enforcing data type and primary key constraints.
    ```bash
    read -a values && ! grep -q "^${values[0]}:" "$table_name.data" && echo "${values[@]}" >> "$table_name.data"
    ```


- **Select from Table** – Retrieve and display records in a structured format.
    ### Should have options such as; Select All, Select Column, Select Record
    ```bash
    cat "$table_name.data" | column -t -s' '
    ```

- **Delete from Table** – Remove specific records.
    ```bash
    read key && sed -i "/^$key:/d" "$table_name.data"
    ```

- **Update Table** – Modify existing records.
    ### sed -n 's/value/newvalue/
    ```bash
    read key old_val new_val && sed -i "/^$key:/s/$old_val/$new_val/" "$table_name.data"
    ```



<!-- In update Function -->
1- update based on PK
--> ask user he user to enter PK
--> and ask user about column for the column name they want to update
--> then the new value for that column
--> update this column with new value


2-update Batch baesd on matching
--> ask user about column name to search within
--> ask for  old value  that needs to be replaced
--> ask user for new value to update all matching records
--> search for all occurrences of the old value 
--> update all matching with new value





