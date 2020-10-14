# title: learning how to use an API
# author: Sam Csik
# date created: "2020-10-12"
# date edited: "2020-10-12"
# R version: 3.6.3
# input: 
# output: 
# resources: https://cran.r-project.org/web/packages/httr/vignettes/api-packages.html, https://github.com/r-lib/httr, https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html 

##############################
# random notes
##############################

# GET retrieves a file
# POST adds a file
# DELETE removes a file

##############################
# load packages
##############################

library(httr)

##############################
# send a simple request using an API endpoint that doesn't require authentication
##############################

# write function to get the URL???
github_api_V1 <- function(path){
  url <- modify_url("https://api.github.com", path = path)
  GET(url)
}

# send request
resp <- github_api_V1("/repos/hadley/httr")
resp

##############################
# parse the response (i.e. turn the response returned by the API into a useful object)
  # any API will return an HTTP resonnse consisting of headers and a body
  # two of the most common structured formats are XML and JSON (most APIs will return one of the other, but some allow you to choose with a url parameter)
##############################

# xml vs. json
GET("http://www.colourlovers.com/api/color/6B4106?format=xml")
GET("http://www.colourlovers.com/api/color/6B4106?format=json")

##############################
# http_type() tells you which type of information is returned
  # recommended that you add this check to your helper function to ensure that you get a clear error message if the API changes 
##############################

http_type(resp)

# update helper function
github_api_V2 <- function(path){
  url <- modify_url("https://api.github.com", path = path)
  GET(url)
  
  resp <- GET(url)
  if (http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }
  
  resp
  
}

github_api_V2("/users/hadley")

##############################
# parse the output into an R object
  # 1. to parse json, use `jsonlite` package
  # 2. to parse xml, use `xml2` package
##############################

# update helper function
github_api_V3 <- function(path){
  url <- modify_url("https://api.github.com", path = path)
  GET(url)
  
  resp <- GET(url)
  if (http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }
  
  jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)
  
}

github_api_V3("/users/hadley")

##############################
# it's good practice to make a simple S3 object, that way you can return the response and the parsed object, and provide a nice print method (also makes debugging later much more pleasant...)
##############################

# update helper function
github_api_V4 <- function(path) {
  url <- modify_url("https://api.github.com", path = path)
  
  resp <- GET(url)
  if (http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }
  
  parsed <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)
  
  structure(
    list(
      content = parsed,
      path = path,
      response = resp
    ),
    class = "github_api"
  )
}

print.github_api <- function(x, ...) {
  cat("<GitHub ", x$path, ">\n", sep = "")
  str(x$content)
  invisible(x)
}

github_api_V4("/users/hadley")

##############################
# turn API errors into R errors
  # next you need to make sure tha tyour API wrapper throws an error if the request failed
##############################

github_api_V5 <- function(path) {
  url <- modify_url("https://api.github.com", path = path)
  
  resp <- GET(url)
  if (http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }
  
  parsed <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)
  
  if (http_error(resp)) {
    stop(
      sprintf(
        "GitHub API request failed [%s]\n%s\n<%s>", 
        status_code(resp),
        parsed$message,
        parsed$documentation_url
      ),
      call. = FALSE
    )
  }
  
  structure(
    list(
      content = parsed,
      path = path,
      response = resp
    ),
    class = "github_api"
  )
}

github_api_V5("/user/hadley")


##############################
# it's useful to set a user agent (a good default is to make it the URL to your GitHub Repo)
##############################

ua <- user_agent("http://github.com/hadley/httr")
ua

github_api_V6 <- function(path) {
  url <- modify_url("https://api.github.com", path = path)
  
  resp <- GET(url, ua)
  if (http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }
  
  parsed <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)
  
  if (status_code(resp) != 200) {
    stop(
      sprintf(
        "GitHub API request failed [%s]\n%s\n<%s>", 
        status_code(resp),
        parsed$message,
        parsed$documentation_url
      ),
      call. = FALSE
    )
  }
  
  structure(
    list(
      content = parsed,
      path = path,
      response = resp
    ),
    class = "github_api"
  )
}

github_api_V6("/user/hadley")

##############################
# parsing parameters
  # most APIs work by executing an HTTP method on a specified URL with some additonal parameters
##############################

# modify_url
POST(modify_url("https://httpbin.org", path = "/post"))

# query arguments
POST("http://httpbin.org/post", query = list(foo = "bar"))

# headers
POST("http://httpbin.org/post", add_headers(foo = "bar"))

# body
## as form
POST("http://httpbin.org/post", body = list(foo = "bar"), encode = "form")
## as json
POST("http://httpbin.org/post", body = list(foo = "bar"), encode = "json")
