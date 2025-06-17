# Loading libraries
library(httr)
library(rvest)
library(tidyverse)

# Defining a function to scrape detention centers and their locations 
# from https://www.ice.gov/detention-facilities
scrape_ice_detention <- function(url) {
  
  results <- GET(url)
  page <- read_html(content(results, as = "text"))
  
  # Get content for a each individual facility
  facilities <- page %>% html_elements(".grid__content")
  
  # Creating empty vectors
  titles <- c()
  addresses <- c()
  localities <- c()
  states <- c()
  postal_codes <- c()
  
  # Attaching values from the facilities
  for (facility in facilities) {
    titles <- c(titles, facility %>% html_element(".views-field-title") %>% html_text(trim = TRUE))
    addresses <- c(addresses, facility %>% html_element(".address-line1") %>% html_text(trim = TRUE))
    localities <- c(localities, facility %>% html_element(".locality") %>% html_text(trim = TRUE))
    states <- c(states, facility %>% html_element(".administrative-area") %>% html_text(trim = TRUE))
    postal_codes <- c(postal_codes, facility %>% html_element(".postal-code") %>% html_text(trim = TRUE))
  }
  
  # Turning the vectors into a dataframe
  facility_df <- data.frame(
    title = titles,
    address = addresses,
    locality = localities,
    state = states,
    postal_code = postal_codes,
    stringsAsFactors = FALSE
  )
  
  return(facility_df)
}

# Creating a facility location dataframe
facility_locations <- rbind(
  scrape_ice_detention("https://www.ice.gov/detention-facilities?page=0"),
  scrape_ice_detention("https://www.ice.gov/detention-facilities?page=1"),
  scrape_ice_detention("https://www.ice.gov/detention-facilities?page=2"),
  scrape_ice_detention("https://www.ice.gov/detention-facilities?page=3"),
  scrape_ice_detention("https://www.ice.gov/detention-facilities?page=4"),
  scrape_ice_detention("https://www.ice.gov/detention-facilities?page=5")
)

write_csv(facility_locations, "facility_locations.csv")
