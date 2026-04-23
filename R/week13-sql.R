#Script Settings and Resources 
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) 
library(DBI)
library(RPostgres)
library(tidyverse)

# Data Import and Cleaning
con <- DBI::dbConnect( # Following instructions for connecting to SQL database in lesson slides
  RPostgres::Postgres(),
  user = Sys.getenv("NEON_USER"), # maintained a User name and password in the system files on my local harddrive
  password = Sys.getenv("NEON_PW"), # maintained a User name and password in the system files on my local harddrive
  host = "ep-billowing-union-am14lcnh-pooler.c-5.us-east-1.aws.neon.tech", #host location from instructions
  port = 5432, #port
  dbname = "neondb", #databse name
  sslmode = "require" #SSL requirement
)

# # Analysis
# Display the total number of managers; COUNTS employee_id of those that have a test score >= 0, but must ensure joined to the table that has the information on test scores
dbGetQuery(con, "
           SELECT COUNT(employee_id)  
           FROM datascience_employees 
           LEFT JOIN datascience_testscores 
           USING (employee_id)
           WHERE test_score >= 0 
           ")

# Display the total number of unique managers; COUNTS employee_id of those that have a test score >= 0, but must ensure joined to the table that has the information on test scores, adds DISTINC to make sure only unique numbers are counted
dbGetQuery(con, "
           SELECT COUNT(DISTINCT(employee_id))  
           FROM datascience_employees 
           LEFT JOIN datascience_testscores 
           USING (employee_id)
           WHERE test_score >= 0
           ")

#Display summary of the number of managers split by location (only not original manager hires)
## SELECT city and counts employee_id WHERE there is a test score >= 0 AND where they were not oriiginally hired as a manager, groups by city and arranges by city ascending (added to match dplyr default)
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
## SELECTs the grouping variable, performs mean and sd on the yrs_employed, ensuring it grabs from employees that have a test score >= 0, grouping by performance_group
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
## SELECTs the three variables of interest, joins the appropriate tables to produce both the office location type (urban v suburban) in alphabetical order and arranges by test score descending
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
