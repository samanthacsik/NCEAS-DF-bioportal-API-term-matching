# title: Custom Functions for Data Wrangling & Plotting
# author: "Sam Csik"
# date created: "2020-10-14"
# date edited: "2020-10-14"
# R version: 3.6.3
# input: NA
# output: NA

source(here::here("code", "00_libraries.R"))

#-----------------------------
# used in script "01_ARC_BioPortal_annotation_matches.R"
# function makes request to the BioOntology API and parses the response
  # takes arguments:
    # data: df with search terms to be matched with BioOntology annotations (required col = APIterm, where each row is a separate term with "+" separating words (i.e. API-friendly))
    # term_index: row index of a particular search term 
#-----------------------------

make_bioontologyAPI_request <- function(data, term_index){
  
  # HTTP request components - FOR ANNOTATOR TAB ENDPOINT
  domainURL <- "http://data.bioontology.org"
  endpoint <- "/annotator?"
  search_term = data$APItext[term_index]
  param_1 <- paste("text=", search_term, sep = "")
  param_2 <- "ontologies=ENVO,ECSO,IAO,NCBITAXON"
  param_3 <- "apikey=59dbd375-f216-42ad-b85f-5b8d4ccc33c6"
  
  # # HTTP request components - FOR SEARCH TAB ENDPOINT - NOT WORKING YET
  # domainURL <- "http://data.bioontology.org"
  # endpoint <- "/search?" 
  # search_term = data$APItext[term_index] 
  # param_1 <- paste("Greenland+ice+sheet")
  # param_2 <- "ontologies=ENVO,ECSO,IAO,NCBITAXON" 
  # param_3 <- "apikey=59dbd375-f216-42ad-b85f-5b8d4ccc33c6" 
  # param_4 <- "include=prefLabel,synonym,definition,notation,cui,semanticType"
  
  # build ANNOTATOR request URL
  query_string <- paste(param_1, param_2, param_3, sep="&")
  request_url <- paste(domainURL, endpoint, query_string, sep="")
  
  # # OR build SEARCH request URL - NOT WORKING YET
  # query_string <- paste(param_1, param_2, param_3, param_4, sep = "&")
  # request_url <- paste(domainURL, endpoint, query_string, sep = "")
  
  # send request and parse response
  response <- GET(request_url)
  status <- http_status(response)$message
  parsed <- jsonlite::fromJSON(content(response, "text"), simplifyVector = FALSE)
  
  # print messages
  message(paste("The ARC term you searched for is:", search_term)) 
  message(paste("The request status is:", status))
  
  return(parsed)
}

#-----------------------------
# used in script "01_ARC_BioPortal_annotation_matches.R"
# function returns the number of annotation matches from ENVO, ECSO, IAO, NCBITAXON using the BioOntology API
  # takes arguments:
   # parsed: a list; parsed JSON from BioPortal
#-----------------------------

get_number_annotation_matches <- function(parsed){
  
  # get number of annotation matches
  num_annotation_matches <- length(parsed)
  
  # print messages
  message(paste("The number of matching annotations is:", num_annotation_matches))
  
  # return number of matches
  return(num_annotation_matches)

}

#-----------------------------
# used in script "01_ARC_BioPortal_annotation_matches.R"
# function returns the valueURIs for annotations that match your specified search_term; returns `NA` if there are no matches
  # takes arguments: 
    # parsed: a list; parsed JSON from BioPortal
#-----------------------------

get_valueURI_matches <- function(parsed){
  
  # initialize empty vector
  all_valueURIs <- c()
  
  # extract a valueURI
  for(i in 1:length(parsed)){
    all_valueURIs <- c(all_valueURIs, parsed[[i]]$annotatedClass$`@id`) # need to package all URIs together into a single character string here..
  }
  
  # combine vector elements into a single character string  
  all_valueURIs <- paste(all_valueURIs, collapse = " ", sep = " ")
  
  # all of the extracted valueURIs 
  return(all_valueURIs)
}

#-----------------------------
# used in script "01_ARC_BioPortal_annotation_matches.R"
# function appends the number of annotation matches and the correponding valueURIs to a pre-initialized columns of the input df
  # takes arguments:
    # num_matches: the number of annotation matches for a given search term, as a numeric value
    # valueURI_matches: all valueURIs that match a given search term, as a character string
#-----------------------------

append_annotation_matches <- function(num_matches, valueURI_matches){
  
  # get number of annotation matches and valueURI matches
  num_matches <- get_number_annotation_matches(parsed = parsed)
  valueURI_matches <- get_valueURI_matches(parsed = parsed)
  
  # append matches to original df
  data[term_index,4] = as.character(num_matches)
  data[term_index,5] = as.character(valueURI_matches)
  assign("vitalSigns_targetVars", data, envir = .GlobalEnv)
  
}