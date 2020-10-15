# title: 
# author: Sam Csik
# date created: "2020-10-12"
# date edited: "2020-10-14"
# R version: 3.6.3
# input: "data/ARC_vitalSigns_targetVars.csv"
# output: "data/ARC_annotation_matches.csv"
# resources: 
  # BioPortal API Documentation: http://data.bioontology.org/documentation
  # Best Practices for API Packages: https://cran.r-project.org/web/packages/httr/vignettes/api-packages.html
  # httr Quickstart Guide: https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html 
  # Annotator Tab Help: http://bioportal.bioontology.org/help?pop=true#Annotator_Tab

##########################################################################################
# Summary
##########################################################################################

#....

##########################################################################################
# General setup
##########################################################################################

##############################
# load packages
##############################

source(here::here("code", "00_libraries.R"))
source(here::here("code", "00_functions.R"))

##############################
# load data
##############################

vitalSigns_targetVars <- read_csv(here::here("data", "ARC_vitalSigns_targetVars.csv")) 

##########################################################################################
# 1) Wrangle data
##########################################################################################

# add "+" in spaces between terms for API search
vitalSigns_targetVars <- vitalSigns_targetVars %>% 
  mutate(APItext = str_replace_all(ARC_term, " ", "+")) 

# add cols to df
vitalSigns_targetVars$num_annotation_matches <- "NA"
vitalSigns_targetVars$valueURI <- "NA"

##########################################################################################
# 2) Query BioOntology for annotation matches for each of the ARC's Vital Signs and Target Variables
##########################################################################################

for(row in 1:nrow(vitalSigns_targetVars)){
  
  # ------------------------------------------------------------------
  # define necessary objects
  data <- vitalSigns_targetVars
  term_index <- row 
  search_term <- vitalSigns_targetVars$APItext[term_index] 
  
  print(term_index)
  
  # ------------------------------------------------------------------
  # make API request and get parsed data
  parsed <- make_bioontologyAPI_request(data, term_index)
  
  # ------------------------------------------------------------------
  # append parsed data to original df; if no matches, return `NA`
  tryCatch({

    # first try
    append_annotation_matches(num_matches, valueURI_matches)
  },

  # if error, print NA
  error = function(e){
    message(paste("There was an error for search term:", search_term))
    message(paste("The error was:", e))
    return(NA)
  }
  )
  
  print(paste("Done appending term number:", term_index))
  print("--------------------")
  
  # ------------------------------------------------------------------
  Sys.sleep(2)

}

##########################################################################################
# 2) Last bit of tidying/wrangling and print
##########################################################################################

# replace "NA" in num_annotation_matches col with "0"
vitalSigns_targetVars_original <- vitalSigns_targetVars %>% 
  mutate(num_annotation_matches = ifelse(num_annotation_matches == "NA", 0, num_annotation_matches))

# save as .csv
# write_csv(vitalSigns_targetVars_original, here::here("data", "ARC_annotation_matches_original.csv"))

# separate URIs into separate columns
vitalSigns_targetVars_wide <- vitalSigns_targetVars %>% 
  mutate(num_annotation_matches = ifelse(num_annotation_matches == "NA", 0, num_annotation_matches)) %>% 
  separate(valueURI, c("valueURI_1", "valueURI_2", "valueURI_3",
                       "valueURI_4", "valueURI_5", "valueURI_6",
                       "valueURI_7", "valueURI_8", "valueURI_9"), sep = " ")

# save as .csv
# write_csv(vitalSigns_targetVars_wide, here::here("data", "ARC_annotation_matches_wide.csv"))

vitalSigns_targetVars_long <- vitalSigns_targetVars_wide %>% 
  pivot_longer(cols = c("valueURI_1", "valueURI_2", "valueURI_3",
                        "valueURI_4", "valueURI_5", "valueURI_6",
                        "valueURI_7", "valueURI_8", "valueURI_9"),
               names_to = "num_URIs",
               values_to = "URIs") %>% 
  select(-num_URIs) %>% 
  drop_na(URIs)

# save as .csv
# write_csv(vitalSigns_targetVars_long, here::here("data", "ARC_annotation_matches_long.csv"))
