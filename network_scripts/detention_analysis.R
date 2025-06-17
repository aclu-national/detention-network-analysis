# Loading Libraries
library(tidyverse)
library(janitor)
library(readxl)
library(rlang)
library(igraph)
library(openssl)
library(data.table)

# ------------------------- Data Prep and Cleaning -----------------------------

# Loading in data
df <- read_excel("data/ICE Detentions_2025-ICLI-00019_2024-ICFO-39357_LESA-STU_FINAL_raw.xlsx", 
                 skip = 6) %>% 
  clean_names()

# Removing all stay book-in date and time/unique identifier pairs that repeat
df_clean <- df %>%
  
  # Removing cases where there is no unique identifier
  filter(!is.na(unique_identifier)) %>%
  
  # Creating a stayid variable so that each person's unique stay in the main group
  mutate(
    stayid = md5(paste0(stay_book_in_date_time, unique_identifier))
  ) %>%
  
  # Removing all stay + book in date time/unique identifier repeats
  group_by(stay_book_in_date_time,
           book_in_date_time, 
           unique_identifier) %>%
  mutate(count = n()) %>%
  filter(count == 1) %>%
  select(-count) %>%
  ungroup() %>%
  
  # Creating a count for when people entered each detention facility
  # I.e. the first facility would have count 1, then 2, etc.
  group_by(stayid) %>% 
  arrange(book_in_date_time) %>%
  mutate(
    detention_count = rleid(book_in_date_time),
    n_detentions = max(detention_count)
  ) %>% 
  ungroup() %>%
  
  # Making the dataframe smaller
  select(stayid, 
         stay_book_in_date_time, 
         n_detentions, 
         unique_identifier, 
         book_in_date_time, 
         detention_book_out_date_time, 
         detention_facility_code, 
         detention_facility, 
         detention_release_reason, 
         detention_count) %>%
  arrange(stayid, book_in_date_time) %>%
  mutate(
    
    # Creating a `moved` variable to say if the detention count is greater than the previous
    # there was a move. If there is no detention book out date or time, then the case is active. 
    # Finally if the detention count is less than or equal to the detention count after, there was not a move.
    moved = case_when(
      lead(detention_count) > detention_count & 
      lead(stayid) == stayid ~ "Yes",
      is.na(detention_book_out_date_time) ~ "Active",
      lead(detention_count) <= detention_count ~ "No"
    ),
    
    # Defining what type of move occurred.
    move_type = case_when(
      detention_release_reason == "Transferred" & moved == "Yes" ~ "Transferred",
      detention_release_reason == "Transferred" & moved != "Yes" ~ "Transferred but not moved",
      detention_release_reason != "Transferred" & moved == "Yes" ~ "Moved for another reason",
      detention_release_reason != "Transferred" & moved != "Yes" ~ "Not moved",
      moved == "Active" ~ "Active"
    ),
    
    # Adding the location where the person was moved to
    move_location = ifelse(
      move_type %in% c("Transferred", "Moved for another reason"),
      lead(detention_facility_code),
      NA
    )
  ) %>%
  
  # Removing NA move types
  filter(!is.na(move_type))

# Creating a dataframe grouped by `stayid`, where each stay
df_paths <- df_clean %>%
  group_by(stayid) %>%
  arrange(book_in_date_time) %>%
  summarise(
    journey = list(detention_facility_code), 
    .groups = 'drop') %>%
  mutate(
    edges = map(journey, ~ {
      nodes <- .x  
      data.frame(from = nodes[-length(nodes)], to = nodes[-1])  
    }),
    graph = map(edges, ~ graph_from_data_frame(.x, directed = TRUE))
  )

# Creating a filtered dataframe of moves
df_move <- df_clean %>%
  filter(!is.na(move_location)) %>%
  select(stayid, 
         detention_count, 
         detention_release_reason, 
         from = detention_facility_code, 
         to = move_location)

# Creating a filtered dataframe of transfers + moves
df_transfer <- df_clean %>%
  filter(!is.na(move_location) & detention_release_reason == "Transferred") %>%
  select(stayid, 
         detention_count, 
         detention_release_reason, 
         from = detention_facility_code, 
         to = move_location)

# Move graph
g_move <- graph_from_data_frame(df_move %>% select(to, from), directed = TRUE)
adj_move <- g_move %>%
  as_adjacency_matrix(.) %>%
  as.matrix(.) %>%
  as.data.frame()

# Transfer graph
g_transfer <- graph_from_data_frame(df_transfer %>% select(to, from), directed = TRUE)
adj_transfer <- g_transfer %>%
  as_adjacency_matrix(.) %>%
  as.matrix(.) %>%
  as.data.frame()

# Calculating the function of the detention facility
df_function <- df_clean %>%
  filter(n_detentions > 1) %>%
  mutate(
    position = case_when(
      detention_count == 1 ~ "First",
      detention_count > 1 &  detention_count < n_detentions ~ "Middle",
      detention_count == n_detentions ~ "Last"
    )
  ) %>%
  group_by(detention_facility) %>%
  summarize(
    percent_first = paste0(100*round(sum(position == "First")/n(),4),"%"),
    percent_middle = paste0(100*round(sum(position == "Middle")/n(),4),"%"),
    percent_last = paste0(100*round(sum(position == "Last")/n(),4),"%"),
    n = n_distinct(stayid)
  ) %>%
  arrange(-n) %>%
  head(10) %>%
  arrange(percent_first) %>%
  select(-n)


# Calculate percentage of stays that include each detention facility
facility_percentages <- df_clean %>%
  distinct(stayid, detention_facility) %>%  # unique combinations of stay and facility
  group_by(detention_facility) %>%
  summarise(
    stays_with_facility = n(),
    percent_of_stays = (stays_with_facility / df_clean %>% 
                          distinct(stayid) %>% 
                          nrow()
                        ) * 100
  ) %>%
  arrange(desc(percent_of_stays))


# ------------------------------ Normal Analysis -------------------------------

# N people in data set
df_clean %>%
  pull(unique_identifier) %>%
  n_distinct()

# N stayid in the data set
df_clean %>%
  pull(stayid) %>%
  n_distinct()

# Mean number of detentions per stayid
df_clean %>%
  distinct(stayid, n_detentions) %>%
  pull(n_detentions) %>%
  mean()

# Transfer reasons
df_clean %>%
  tabyl(detention_release_reason) %>%
  arrange(-n)

# Reasons why people are move
df_clean %>%
  filter(moved == "Yes") %>%
  tabyl(detention_release_reason) %>%
  arrange(-n)

# People with transfers but not moving 
df_clean %>%
  filter(detention_release_reason == "Transferred") %>%
  tabyl(moved) %>%
  arrange(-n)

# ----------------------------- Graph Analysis ---------------------------------
## --------------------------------- Move --------------------------------------

data.frame(
  facility = rownames(as.matrix(g_move)),
  in_degree = degree(g_move, mode = "in", loops = FALSE),
  out_degree = degree(g_move, mode = "out", loops = FALSE),
  total_degree = degree(g_move, mode = "total", loops = FALSE)
)


## ------------------------------- Transfers -----------------------------------


data.frame(
  facility = rownames(as.matrix(g_transfer)),
  transfer_in_degree = degree(g_transfer, mode = "in", loops = FALSE),
  transfer_out_degree = degree(g_transfer, mode = "out", loops = FALSE),
  transfer_total_degree = degree(g_transfer, mode = "total", loops = FALSE)
)

## -------------------------------- Paths --------------------------------------

# Creating a function to extract sub-paths of length n
subpaths_len_n <- function(n) {
  
  # Defining `extract_subpaths`
  extract_subpaths <- function(nodes, n) {
    if (length(nodes) < n) return(character(0))
    starts <- seq_len(length(nodes) - n + 1)
    subpaths <- sapply(starts, function(i) paste(nodes[i:(i + n - 1)], collapse = "->"))
    return(subpaths)
  }
  
  df_paths %>%
    mutate(subpaths = map(journey, ~ extract_subpaths(.x, n))) %>%
    select(subpaths) %>%
    unnest(subpaths) %>%
    count(subpaths, sort = TRUE)
}

# Most common sub-paths
subpaths_2 <- subpaths_len_n(2)
subpaths_3 <- subpaths_len_n(3)
subpaths_4 <- subpaths_len_n(4)
subpaths_5 <- subpaths_len_n(5)
subpaths_6 <- subpaths_len_n(6)

# ------------------------ Extra / Unfinished --------------------------------

# Facility List 2017 data
detention_lookup_1 <- read_excel("data/ICE_Facility_List_11-06-2017-web_raw.xlsx", sheet = "Facility List - Main", skip = 8) %>%
  clean_names() %>%
  select(detention_facility_code = detloc, name, address, city, county, state, zip)

# Facility List Vera
detention_lookup_2 <- read_csv("data/facilities.csv")

# Facility list (don't remember)
detention_lookup_3 <- read_csv("data/locations.csv") %>%
  clean_names() %>%
  select(detention_facility_code = detloc, name, address, city, county, state, zip)

df %>%
  select(detention_facility_code, detention_facility) %>%
  distinct(detention_facility_code, detention_facility) %>%
  left_join(detention_lookup_1, by = "detention_facility_code") %>%
  pull(name) %>%
  n_distinct()

df %>%
  select(detention_facility_code, detention_facility) %>%
  distinct(detention_facility_code, detention_facility) %>%
  left_join(detention_lookup_2, by = "detention_facility_code") %>%
  pull(detention_facility_name) %>%
  n_distinct()

df %>%
  select(detention_facility_code, detention_facility) %>%
  distinct(detention_facility_code, detention_facility) %>%
  left_join(detention_lookup_3, by = "detention_facility_code") %>%
  pull(name) %>%
  n_distinct()
