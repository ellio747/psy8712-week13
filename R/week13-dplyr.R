#Script Settings and Resources 
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) 
library(DBI)
library(RPostgres)
library(tidyverse)

#Data Import and Cleaning 
con <- DBI::dbConnect( # Following instructions for connecting to SQL database in lesson slides
  RPostgres::Postgres(),
  user = Sys.getenv("NEON_USER"), # maintained a User name and password in the system files on my local harddrive
  password = Sys.getenv("NEON_PW"), # maintained a User name and password in the system files on my local harddrive
  host = "ep-billowing-union-am14lcnh-pooler.c-5.us-east-1.aws.neon.tech", #host location from instructions
  port = 5432, #port
  dbname = "neondb", #databse name
  sslmode = "require" #SSL requirement
)

# Download and save employees #dbListTables() was used to find four tables: "datascience_employees"  "datascience_offices"    "datascience_testscores" "participant_scores"   
employees_tbl <- dbGetQuery(con, "SELECT * FROM datascience_employees") %>% 
  write_csv("../data/employees.csv") # write to csv in data as per instructions

# Download and save testscores
testscores_tbl <- dbGetQuery(con, "SELECT * FROM datascience_testscores") %>% 
  write_csv("../data/testscores.csv") # write to csv in data as per instructions

# Download and save offices
offices_tbl <- dbGetQuery(con, "SELECT * FROM datascience_offices") %>% 
  write_csv("../data/offices.csv") # write to csv in data as per instructions

# Combine data such that employees without test scores are removed
week13_tbl <- testscores_tbl %>% # this retains an individual with a test score = 0, but not NULL, so retained
  left_join( #left join starts with those that have test scores, but adds those managers without
    employees_tbl, # employee data
    by = "employee_id" # linking key of employee_id in both tables
  ) %>% 
  left_join( # adds on office type by the city location of the management office
    offices_tbl,
    by = join_by("city" == "office")
  ) %>% 
  write_csv("../out/week13.csv") # writes to the out folder a csv of the week13_tbl

#Analysis
# Display the total number of managers
week13_tbl %>% 
  count() %>% # this counts all managers
  View()# n = 549 managers

# Display the total number of unique managers
week13_tbl %>% 
  distinct(employee_id) %>% #this counts the number of unique managers based on employee_id
  count()%>% # adds counting function
  View()# n = 549 managers

# Display summary of the number of managers split by location (only not original manager hires)
week13_tbl %>% 
  group_by(city) %>% # groups by location
  filter(manager_hire == "N") %>% # not originally hired as a manager
  count()%>% # adds counting function
  View() # Chicago = 61, Houston = 20, New York = 183, Orlando = 20, San Francisco = 48, Toronto = 189

# Display mean, SD of years of employment, split by performance level
week13_tbl %>% 
  group_by(performance_group) %>% # groups by performance level
  summarise(
    m = mean(yrs_employed), # summarize means
    sd = sd(yrs_employed) # summarize sds
  )%>% 
  View() # Bottom = 4.74 (.537), Middle = 4.58 (.509), Top = 4.33 (.604)

# Display location classification, ID number, test score, in alphabetical order by location type, test score descending
week13_tbl %>% 
  select(office_type, employee_id, test_score) %>% # retains location classification, ID number, and test score
  arrange(office_type, desc(test_score)) %>% # arranges in alphabetic by location classification, then in descending by test score
  View()
