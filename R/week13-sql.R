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

# dbExecute(con, "SELECT * FROM participant_scores") 
# 
# # Only using #dbGetQuery
# 
# # this will do the tables
# 
# 
# # Analysis
# dbGetQuery(con, "SELECT * FROM datascience_employees")