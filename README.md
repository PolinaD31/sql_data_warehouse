# Data Warehouse and Analytics
This is a data warehouse & analytics setup built on SQL Server.

The goal of this project is to:
- create a warehouse solution, going from raw data to analytics-ready data
- analyze the final data using SQL

### Architecrure
The project uses a 3-layer pattern:
1. Layer 1 – Raw/Staging
    - Tables are loaded using a stored procedure
2. Layer 2 – Cleansed/Integrated
    - Data is cleaned and standardized
3. Layer 3 – Analytics-Ready
    - Business logic is added
    - Star schema is cerated
    - Analytics-ready data
  
### Overview 
- 3 layer data warehouse pattern
- Data modeling
- Data analytics
- Stored procedures for loading data
- Re-runnable scripts
- Diagrams to explain the flow
  
### Tech
- **Database:** Microsoft SQL Server
- **Language:** T-SQL
- **Pattern:** 3 layer DW
- **Objects used:** schemas, tables, views, stored procedures
- **Documentation:** diagrams to explain flow and model, in-file explanations

### Analytics
The `analytics/` folder includes scripts for EDA.
      
### Diagrams
Diagrams in the `diagrams/` folder visually present architecture, data flow, star schema.
