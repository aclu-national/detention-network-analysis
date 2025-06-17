# Loading Libraries
library(readxl)
library(dplyr)
library(janitor)
library(readr)
library(stringr)
library(tidyr)

# ------------------------------ Functions ------------------------------------

# Reading detention facility sheet
read_facility_data <- function(path, sheet, skip_rows = 6) {
  read_xlsx(path, 
            skip = skip_rows, 
            sheet = sheet) %>%
    select(Name, State)
}

# Converting states to abbreviations
convert_state <- function(state_vec) {
  state_abbrev <- setNames(state.abb, state.name)
  out <- ifelse(state_vec %in% names(state_abbrev), state_abbrev[state_vec], state_vec)
  recode(out,
         "Guam" = "GU",
         "Puerto Rico" = "PR",
         "District of Columbia" = "DC",
         "Virgin Islands" = "VI",
         "Northern Mariana Isl" = "MP",
         "Unknown" = NA_character_,
         TRUE ~ state
  )
}

# ---------------------------- Loading ICE Data --------------------------------

# Reading annual data
annual_facility_paths <- list(
  fy_2019 = list(path = "data/locations/FY19-detentionstats.xlsx", sheet = "Facilities FY19", skip = 6),
  fy_2020 = list(path = "data/locations/FY20-detentionstats.xlsx", sheet = "Facilities EOYFY20 ", skip = 6),
  fy_2021 = list(path = "data/locations/FY21-detentionstats.xlsx", sheet = "Facilities FY21 YTD", skip = 6),
  fy_2022 = list(path = "data/locations/FY22-detentionstats.xlsx", sheet = "Facilities FY22", skip = 6),
  fy_2023 = list(path = "data/locations/FY23_detentionStats.xlsx", sheet = "Facilities EOFY23", skip = 5),
  fy_2024 = list(path = "data/locations/FY24_detentionStats.xlsx", sheet = "Facilities EOFY24", skip = 6)
)

annual_facility_data <- lapply(annual_facility_paths, function(info) {
  read_facility_data(info$path, info$sheet, info$skip)
})


# Getting monthly files
monthly_files <- list.files("data/locations/monthly/", full.names = TRUE)

# Reading the monthly files
monthly_facility_data <- lapply(monthly_files, function(file) {
  read_facility_data(file, "Facilities FY25")
})

names(monthly_facility_data) <- basename(monthly_files)


# ----------------------- Creating Name Lookup table ---------------------------


name_lookup <- bind_rows(
  c(annual_facility_data, monthly_facility_data)
) %>%
  distinct(detention_facility = Name, state = State) %>%
  group_by(detention_facility) %>%
  mutate(state_count = n_distinct(state)) %>%
  ungroup() %>%
  filter(state_count == 1)

# --------------------- Reading Datasets with facility Codes -------------------

# Downloaded from: https://deportationdata.org/data/reports.html#detention-facility-list
df_2017 <- read_excel("data/locations/ICE_Facility_List_11-06-2017-web_raw.xlsx",
                      sheet = "Facility List - Main", skip = 8) %>%
  clean_names() %>%
  select(detention_facility_code = detloc, name, state)

# Downloaded from: https://github.com/vera-institute/ice-detention-trends/blob/main/metadata/facilities.csv
df_vera <- read_csv("data/locations/facilities.csv") %>%
  select(detention_facility_code, name = detention_facility_name, state)

# Downloaded from: https://github.com/themarshallproject/dhs_immigration_detention/blob/master/locations.csv
df_marshall <- read_csv("data/locations/locations.csv") %>%
  clean_names() %>%
  select(detention_facility_code = detloc, name, state)

# Downloaded from: https://tracreports.org/immigration/reports/370/include/table3.html
df_tracs <- read_csv("data/locations/tracs.csv") %>%
  clean_names() %>%
  separate(facility, into = c("detention_facility_code", "name"), sep = " - ", extra = "merge") %>%
  select(detention_facility_code, name, state)


# Downloaded from: https://www.ice.gov/doclib/detention/taltonFacilities.pdf
df_talton <- read_csv("data/locations/extra.csv") %>%
  clean_names() %>%
  select(detention_facility_code = detloc, name, state)


# ---------------------------- Creating Code Lookup Table ----------------------

code_lookup <- bind_rows(df_2017, df_vera, df_marshall, df_tracs, df_talton) %>%
  mutate(
    state = convert_state(state),
    name = str_to_upper(name)
  ) %>%
  filter(!is.na(state)) %>%
  distinct(detention_facility_code, state, name) %>%
  group_by(detention_facility_code) %>%
  mutate(state_count = n_distinct(state)) %>%
  ungroup() %>%
  filter(state_count == 1) %>%
  distinct(detention_facility_code, state)

# ---------------------------- Checking % Hits ---------------------------------


# By name
df %>%
  distinct(detention_facility_code, detention_facility) %>%
  left_join(name_lookup, by = "detention_facility") %>%
  filter(is.na(state)) %>%
  nrow()

df %>%
  left_join(name_lookup, by = "detention_facility") %>%
  filter(is.na(state)) %>%
  nrow() / nrow(df)

# By code
df %>%
  distinct(detention_facility_code, detention_facility) %>%
  left_join(code_lookup, by = "detention_facility_code") %>%
  filter(is.na(state)) %>%
  nrow()

df %>%
  left_join(code_lookup, by = "detention_facility_code") %>%
  filter(is.na(state)) %>%
  nrow() / nrow(df)

write_csv(code_lookup, "code_lookup.csv")

# -------------------- Comparing Code Lookup to Originals ----------------------

df %>%
  left_join(df_marshall, by = "detention_facility_code") %>%
  filter(is.na(state)) %>%
  nrow() / nrow(df)

df %>%
  left_join(df_vera, by = "detention_facility_code") %>%
  filter(is.na(state)) %>%
  nrow() / nrow(df)

df %>%
  left_join(df_talton, by = "detention_facility_code") %>%
  filter(is.na(state)) %>%
  nrow() / nrow(df)

df %>%
  left_join(df_2017, by = "detention_facility_code") %>%
  filter(is.na(state)) %>%
  nrow() / nrow(df)

# ----------------------- Still Missing from Code Lookup ----------------------

df %>%
  distinct(detention_facility_code, detention_facility) %>%
  left_join(code_lookup, by = "detention_facility_code") %>%
  filter(is.na(state)) %>%
  write_csv("code_missing.csv")
