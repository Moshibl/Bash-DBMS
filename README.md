# Bash Shell Script Database Management System (DBMS)

## Overview
This project is a simple **Database Management System (DBMS)** implemented using **Bash scripting**. It allows users to create, manage, and manipulate databases and tables through a command-line interface.

## Features
- **Database Operations**:
  - Create, List, Drop, and Connect to databases.
- **Table Operations**:
  - Create, List, Drop tables within a database.
- **Record Operations**:
  - Insert, Select, Update, and Delete records within tables.
- **Data Validation**:
  - Enforces data types and constraints such as Primary Keys and Unique values.

## Project Structure
```
dbms_project/
│── main.sh               # Main script (entry point)
│── db_operations.sh      # Database operations (create, list, drop, connect)
│── table_operations.sh   # Table operations (create, list, drop)
│── record_operations.sh  # Data operations (insert, select, delete, update)
│── validation.sh         # Input validation functions
│── utils.sh              # Common helper functions
```

## Data Storage Structure
Each database is stored as a **directory**, and each table is stored as two separate files inside its respective database directory:

1. **Metadata File (`table_name.meta`)**
   - Stores the table structure, including column names, data types, and constraints (e.g., PRIMARY KEY, UNIQUE).
   - Format:
     ```
     column_name:data_type:constraint
     id:INTEGER:PRIMARY_KEY
     name:STRING:UNIQUE
     age:INTEGER:NULLABLE
     ```

2. **Data File (`table_name.tb`)**
   - Stores actual table records, with values separated by `:`.
   - Format:
     ```
     1:Alice:25
     2:Bob:30
     ```

## Functionalities

### 1. **Database Operations (`db_operations.sh`)**
- **Create a Database**: Prompts user for a database name and creates a directory.
- **List Databases**: Displays all available databases.
- **Drop a Database**: Deletes a selected database directory after confirmation.
- **Connect to a Database**: Navigates into the selected database for further operations.

### 2. **Table Operations (`table_operations.sh`)**
- **Create a Table**: Prompts user for table name, column details, data types, and constraints.
- **List Tables**: Displays all tables in the connected database.
- **Drop a Table**: Deletes a selected table’s metadata and data files after confirmation.

### 3. **Record Operations (`record_operations.sh`)**
- **Insert a Record**: Adds a new row to a table while enforcing data type and constraint validation.
- **Select Records**:
  - **Select All**: Displays all records from the table.
  - **Select by Value**: Filters records based on a specific value.
  - **Select by Primary Key**: Retrieves a record using the primary key.
  - **Select Column**: Displays values from a specific column.
- **Update Records**:
  - **Update by Primary Key**: Modifies a specific record using its primary key.
  - **Batch Update**: Updates all occurrences of a value in a column.
- **Delete a Record**: Removes a record using its primary key.

### 4. **Validation & Utility Functions (`validation.sh`, `utils.sh`)**
- Ensures valid user input for database names, table structures, and record entries.
- Provides reusable utility functions for error handling and formatted messages.

## How to Use
1. Run the main script:
   ```bash
   ./main.sh
   ```
2. Follow the interactive menu to create databases, tables, and manage records.

## Notes
- All data is stored in plain text format.
- Data validation prevents duplicate primary keys and incorrect data types.
- Works entirely through command-line interface without external dependencies.

