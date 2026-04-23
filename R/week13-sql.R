#Script Settings and Resources 
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) 
library(DBI)
library(RPostgres)
library(tidyverse)

# Data Import and Cleaning
con <- DBI::dbConnect(
  RPostgres::Postgres(),
  user = Sys.getenv("NEON_USER"),
  password = Sys.getenv("NEON_PW"),
  host = "ep-billowing-union-am14lcnh-pooler.c-5.us-east-1.aws.neon.tech",
  port = 5432,
  dbname = "neondb",
  sslmode = "require"
)

# # Analysis
# Display the total number of managers
dbGetQuery(con, "
           SELECT COUNT(employee_id)  
           FROM datascience_employees 
           LEFT JOIN datascience_testscores 
           USING (employee_id)
           WHERE test_score >= 0
           ")

# Display the total number of unique managers
dbGetQuery(con, "
           SELECT COUNT(DISTINCT(employee_id))  
           FROM datascience_employees 
           LEFT JOIN datascience_testscores 
           USING (employee_id)
           WHERE test_score >= 0
           ")

#Display summary of the number of managers split by location (only not original manager hires)
dbGetQuery(con, "
           SELECT city, COUNT(employee_id) 
           FROM datascience_employees
           LEFT JOIN datascience_testscores
           USING (employee_id)
           WHERE test_score >= 0 
              AND manager_hire = 'N'
           GROUP BY city
           ORDER BY city ASC
           ")

# Display mean, SD of years of employment, split by performance level
dbGetQuery(con, "
           SELECT 
             performance_group,
             AVG(yrs_employed),
             STDDEV(yrs_employed)
           FROM datascience_employees
           LEFT JOIN datascience_testscores
           USING (employee_id)
           WHERE test_score >= 0 
           GROUP BY performance_group
           ")

# Display location classification, ID number, test score, in alphabetical order by location type, test score descending
dbGetQuery(con, "
           SELECT 
             office_type,
             employee_id,
             test_score
           FROM datascience_employees e
           LEFT JOIN datascience_testscores t
           USING (employee_id)
           LEFT JOIN datascience_offices o
           ON e.city = o.office
           WHERE test_score >= 0 
           ORDER BY office_type ASC, test_score DESC
           ")
