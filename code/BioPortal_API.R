# title: 
# author: Sam Csik
# date created: "2020-10-12"
# date edited: "2020-10-12"
# R version: 3.6.3
# input: 
# output: 
# resources: 
  # http://data.bioontology.org/documentation
  # https://cran.r-project.org/web/packages/httr/vignettes/api-packages.html
  # https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html 
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

### Example Code ###
my_practice_path <- paste(baseURL, searchQuery, api_key, sep = "")
r <- GET(my_practice_path)
status_code(r)
headers(r)
str(content(r))
str(content(r, "parsed"))

##############################
# load packages
##############################

library(httr)
library(jsonlite)

##############################
# HTTP request components
##############################

domainURL <- "http://data.bioontology.org"
endpoint <- "/annotator?"
# param_1 <- "text=snow"
term = "snow"
param_1 <- paste("text=", term, sep = "")
param_2 <- "ontologies=ENVO,ECSO,IAO,NCBITAXON"
param_3 <- "apikey=59dbd375-f216-42ad-b85f-5b8d4ccc33c6"

query_string <- paste(param_1, param_2, param_3, sep="&")
request_url <- paste(domainURL, endpoint, query_string, sep="")

##############################
# send request and parse response
##############################

response <- GET(request_url)
parsed <- jsonlite::fromJSON(content(response, "text"), simplifyVector = FALSE)


































##############################
# building bioontology helper function
##############################
my_path <- paste(annotatorQuery, api_key, sep = "")

my_api <- function(path) {
  
  # send request
  url <- modify_url("http://data.bioontology.org", path = path)
  
  # check that response is the expected type
  resp <- GET(url)
  if (http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }
  
  # parse the response
  parsed <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)
  
  # turn API error into R error
  if (http_error(resp)) {
    stop(
      sprintf(
        "BioOntology API request failed [%s]\n%s\n<%s>", 
        status_code(resp),
        parsed$message,
        parsed$documentation_url
      ),
      call. = FALSE
    )
  }
  
  # 
  structure(
    list(
      content = parsed,
      path = my_path,
      response = resp
    ),
    class = "my_api"
  )
}

print.my_api <- function(x, ...) {
  cat("<BioPortal ", x$my_path, ">\n", sep = "")
  str(x$content)
  invisible(x)

}

my_api(my_path)

