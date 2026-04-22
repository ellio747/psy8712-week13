#Script Settings and Resources 
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) 
library(DBI)
library(RPostgres)
library(tidyverse)

#Data Import and Cleaning 
con <- DBI::dbConnect(
  RPostgres::Postgres(),
  user = Sys.getenv("NEON_USER"),
  password = Sys.getenv("NEON_PW"),
  host = "ep-billowing-union-am14lcnh-pooler.c-5.us-east-1.aws.neon.tech",
  port = 5432,
  dbname = "neondb",
  sslmode = "require"
)

# Download and save employees #dbListTables() was used to find four tables: "datascience_employees"  "datascience_offices"    "datascience_testscores" "participant_scores"   
employees_tbl <- dbGetQuery(con, "SELECT * FROM datascience_employees") %>% 
  write_csv("../data/employees.csv")

# Download and save testscores
testscores_tbl <- dbGetQuery(con, "SELECT * FROM datascience_testscores") %>% 
  write_csv("../data/testscores.csv")

# Download and save offices
offices_tbl <- dbGetQuery(con, "SELECT * FROM datascience_offices") %>% 
  write_csv("../data/offices.csv")

# Combine data such that employees without test scores are removed
week13_tbl <- testscores_tbl %>% # this retains an individual with a test score = 0, but not NULL, so retained
  left_join(
    employees_tbl,
    by = "employee_id"
  ) %>% 
  left_join(
    offices_tbl,
    by = join_by("city" == "office")
  ) %>% 
  write_csv("../out/week13.csv")


#Visualization

#Analysis

#Publication



dbExecute(con, "SELECT * FROM participant_scores") # This will return a 0 # returns a result

# Only using #dbGetQuery

# this will do the tables