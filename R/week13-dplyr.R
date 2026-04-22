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

#Analysis
# Display the total number of managers
week13_tbl %>% 
  count() %>% 
  View()# n = 549 managers

# Display the total number of unique managers
week13_tbl %>% 
  distinct(employee_id) %>% 
  count()%>% 
  View()# n = 549 managers

# Display summary of the number of managers split by location (only not original manager hires)
week13_tbl %>% 
  group_by(city) %>% 
  filter(manager_hire == "N") %>% 
  count()%>% 
  View() # Chicago = 61, Houston = 20, New York = 183, Orlando = 20, San Francisco = 48, Toronto = 189

# Display mean, SD of years of employment, split by performance level
week13_tbl %>% 
  group_by(performance_group) %>% 
  summarise(
    m = mean(yrs_employed),
    sd = sd(yrs_employed)
  )%>% 
  View() # Bottom = 4.74 (.537), Middle = 4.58 (.509), Top = 4.33 (.604)

# Display location classification, ID number, test score, in alphabetical order by location type, test score descending
week13_tbl %>% 
  select(office_type, employee_id, test_score) %>% 
  arrange(office_type) %>% 
  arrange(desc(test_score)) %>% 
  View()