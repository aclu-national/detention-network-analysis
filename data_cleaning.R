# Loading Libraries
library(tidyverse)
library(janitor)
library(readxl)

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