# Loading Libraries
library(tidyverse)
library(janitor)
library(readxl)
library(rlang)
library(igraph)
library(openssl)
library(data.table)

# ------------------------- Data Prep and Cleaning -----------------------------

# Creating a dataframe grouped by `stayid`, where each stay
df_paths <- df_clean %>%
  left_join(code_lookup, by = "detention_facility_code") %>%
  mutate(state = ifelse(is.na(state), "unknown", state)) %>%
  group_by(stayid) %>%
  arrange(book_in_date_time) %>%
  summarise(
    journey = list(state), 
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
         to = move_location) %>%
  left_join(code_lookup, by = c("from" = "detention_facility_code")) %>%
  rename(from_state = state) %>%
  left_join(code_lookup, by = c("to" = "detention_facility_code")) %>%
  rename(to_state = state) %>%
  mutate(
    from_state = ifelse(is.na(from_state), "unknown", from_state),
    to_state = ifelse(is.na(to_state), "unknown", to_state)
  )

# Creating a filtered dataframe of transfers + moves
df_transfer <- df_clean %>%
  filter(!is.na(move_location) & detention_release_reason == "Transferred") %>%
  select(stayid, 
         detention_count, 
         detention_release_reason, 
         from = detention_facility_code, 
         to = move_location) %>%
  left_join(code_lookup, by = c("from" = "detention_facility_code")) %>%
  rename(from_state = state) %>%
  left_join(code_lookup, by = c("to" = "detention_facility_code")) %>%
  rename(to_state = state) %>%
  mutate(
    from_state = ifelse(is.na(from_state), "unknown", from_state),
    to_state = ifelse(is.na(to_state), "unknown", to_state)
  )

# Move graph
g_move <- graph_from_data_frame(df_move %>% select(from_state, to_state), directed = TRUE)
adj_move <- g_move %>%
  as_adjacency_matrix(.) %>%
  as.matrix(.) %>%
  as.data.frame()

# Transfer graph
g_transfer <- graph_from_data_frame(df_transfer %>% select(from_state, to_state), directed = TRUE)
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
  left_join(code_lookup, by = "detention_facility_code") %>%
  mutate(state = ifelse(is.na(state), "unknown", state)) %>%
  group_by(state) %>%
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
  left_join(code_lookup, by = "detention_facility_code") %>%
  mutate(state = ifelse(is.na(state), "unknown", state)) %>%
  distinct(stayid, state) %>%  # unique combinations of stay and facility
  group_by(state) %>%
  summarise(
    stays_with_facility = n(),
    percent_of_stays = (stays_with_facility / df_clean %>% 
                          distinct(stayid) %>% 
                          nrow()
    ) * 100
  ) %>%
  arrange(desc(percent_of_stays))

# ----------------------------- Graph Analysis ---------------------------------
## --------------------------------- Move --------------------------------------

data.frame(
  facility = rownames(as.matrix(g_move)),
  in_degree = degree(g_move, mode = "in", loops = FALSE),
  out_degree = degree(g_move, mode = "out", loops = FALSE),
  total_degree = degree(g_move, mode = "total", loops = FALSE)
) %>%
  arrange(-total_degree)

## ------------------------------- Transfers -----------------------------------


data.frame(
  facility = rownames(as.matrix(g_transfer)),
  transfer_in_degree = degree(g_transfer, mode = "in", loops = FALSE),
  transfer_out_degree = degree(g_transfer, mode = "out", loops = FALSE),
  transfer_total_degree = degree(g_transfer, mode = "total", loops = FALSE)
) %>%
  arrange(-transfer_total_degree)

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
