# Bash Shell Script Database Management System (DBMS)

## Project Overview
This project is a **Bash Shell Script Database Management System (DBMS)** that allows users to create, store, retrieve, and manage structured data directly on their hard disk. The system provides a **Command-Line Interface (CLI)** for managing databases and tables.

## Features
### **Main Menu:**
- **Create Database** – Create a new database as a directory.
- **List Databases** – Display all existing databases.
- **Connect to Database** – Select a database to manage tables.
- **Drop Database** – Delete a database.

### **Database Menu (After Connecting to a Database):**
- **Create Table** – Define a new table with column names, data types, and a primary key.
- **List Tables** – Show all tables in the current database.
- **Drop Table** – Delete a table.
- **Insert into Table** – Add records while enforcing data type and primary key constraints.
- **Select from Table** – Retrieve and display records in a structured format.
- **Delete from Table** – Remove specific records.
- **Update Table** – Modify existing records.

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

## Validations Implemented
- **Database Name Validation**: 
  - Database names must be unique and valid (no special characters or spaces).
- **Table Name Validation**: 
  - Table names must be unique within a database.
  - Column names must be valid (no special characters or spaces).
- **Column Definitions**: 
  - Enforces correct data types and primary key constraints.

- **Data Entry Validations**:
  - Data types must match the column definitions.
  - Primary key values must be unique and not null.
  - Unique column values must be unique (if specified).

## Data Storage Structure
Each database is stored as a **directory**, and each table is stored as two separate files inside its respective database directory:

1. **Metadata File (`table_name.meta`)**
   - Stores the table structure, including column names, data types, and constraints (e.g., PRIMARY KEY, UNIQUE).
   - Format:
     ```
     column_name|data_type|constraint
     id|INTEGER|PRIMARY_KEY
     name|STRING|UNIQUE
     age|INTEGER|NULLABLE
     ```

2. **Data File (`table_name.table`)**
   - Stores actual table records, with values separated by `|`.
   - Format:
     ```
     1|Alice|25
     2|Bob|30
     ```
