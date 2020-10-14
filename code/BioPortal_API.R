# title: 
# author: Sam Csik
# date created: "2020-10-12"
# date edited: "2020-10-12"
# R version: 3.6.3
# input: 
# output: 
# resources: 
  # BioOntology API Documentation: http://data.bioontology.org/documentation
  # Best Practices for API Packages: https://cran.r-project.org/web/packages/httr/vignettes/api-packages.html
  # httr Quickstart Guide: https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html 
  # Annotator Tab Help: http://bioportal.bioontology.org/help?pop=true#Annotator_Tab

##############################
# notes
##############################

### Ontologies ###
# The Environment Ontology: http://data.bioontology.org/ontologies/ENVO
# The Ecosystem Ontology: http://data.bioontology.org/ontologies/ECSO
# Information Artifact Ontology: http://data.bioontology.org/ontologies/IAO
# National Center for Biotechnology Information (NCBI) Organismal Classification: http://data.bioontology.org/ontologies/NCBITAXON

### HTTP Request Components ###
# 1) HTTP verb (GET, POST, DELETE, etc.)
# 2) The base URL for the API
# 3) The URL path or endpoint
# 4) URL query arguments (e.g., ?foo=bar)
# 5) Optional headers
# 6) An optional request body

##############################
# load packages
##############################

library(tidyverse)
library(httr)
library(jsonlite)

##############################
# load data
##############################

vitalSigns_targetVars <- read_csv(here::here("data", "ARC_vitalSigns_targetVars.csv")) 

##############################
# wrangle data
##############################

# add "+" in spaces between terms for API search
vitalSigns_targetVars <- vitalSigns_targetVars %>% 
  mutate(APItext = str_replace_all(ARC_term, " ", "+"))

# # add cols to df
# vitalSigns_targetVars$num_annotation_matches <- "NA"
# vitalSigns_targetVars$propertyURI <- "NA"

# ##############################
# # HTTP request components
# ##############################
# 
# domainURL <- "http://data.bioontology.org"
# endpoint <- "/annotator?"
# term = "Sea+Surface+Temperature" 
# param_1 <- paste("text=", term, sep = "")
# param_2 <- "ontologies=ENVO,ECSO,IAO,NCBITAXON"
# param_3 <- "apikey=59dbd375-f216-42ad-b85f-5b8d4ccc33c6"
# 
# query_string <- paste(param_1, param_2, param_3, sep="&")
# request_url <- paste(domainURL, endpoint, query_string, sep="")
# 
# ##############################
# # send request and parse response
# ##############################
# 
# response <- GET(request_url)
# parsed <- jsonlite::fromJSON(content(response, "text"), simplifyVector = FALSE)
# 
# number_of_annotations <- length(parsed)
# 
# ontology1 <- parsed[[1]]$annotatedClass$links$ontology
# id1 <- parsed[[1]]$annotatedClass$`@id`
# 
# ontology2 <- parsed[[2]]$annotatedClass$links$ontology
# id2 <- parsed[[2]]$annotatedClass$`@id`

###################################################

# data: dataframe with terms to be matched (required col = APIterm, where each row is a separate term to match with "+" separating words)
# term_number: row index for a particular term

# function
bioontologyAPI_annotation_match <- function(data, term_index){
  
  # HTTP request components
  domainURL <- "http://data.bioontology.org"
  endpoint <- "/annotator?"
  term = data$APItext[term_number]
  param_1 <- paste("text=", term, sep = "")
  param_2 <- "ontologies=ENVO,ECSO,IAO,NCBITAXON"
  param_3 <- "apikey=59dbd375-f216-42ad-b85f-5b8d4ccc33c6"
  
  # build request URL
  query_string <- paste(param_1, param_2, param_3, sep="&")
  request_url <- paste(domainURL, endpoint, query_string, sep="")
  
  # send request and parse response
  response <- GET(request_url)
  status <- http_status(response)$message
  parsed <- jsonlite::fromJSON(content(response, "text"), simplifyVector = FALSE)
  number_of_annotations <- length(parsed)
  
  # print messages
  message(paste("The ARC term you searched for is:", term))
  message(paste("The request status is:", status))
  message(paste("The number of matching annotations is:", number_of_annotations))
}


# test
bioontologyAPI_annotation_match(data = vitalSigns_targetVars, term_index = 4)



























##############################
# building bioontology helper function
##############################
# my_path <- paste(annotatorQuery, api_key, sep = "")
# 
# my_api <- function(path) {
#   
#   # send request
#   url <- modify_url("http://data.bioontology.org", path = path)
#   
#   # check that response is the expected type
#   resp <- GET(url)
#   if (http_type(resp) != "application/json") {
#     stop("API did not return json", call. = FALSE)
#   }
#   
#   # parse the response
#   parsed <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)
#   
#   # turn API error into R error
#   if (http_error(resp)) {
#     stop(
#       sprintf(
#         "BioOntology API request failed [%s]\n%s\n<%s>", 
#         status_code(resp),
#         parsed$message,
#         parsed$documentation_url
#       ),
#       call. = FALSE
#     )
#   }
#   
#   # 
#   structure(
#     list(
#       content = parsed,
#       path = my_path,
#       response = resp
#     ),
#     class = "my_api"
#   )
# }
# 
# print.my_api <- function(x, ...) {
#   cat("<BioPortal ", x$my_path, ">\n", sep = "")
#   str(x$content)
#   invisible(x)
# 
# }
# 
# my_api(my_path)

