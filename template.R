# Using this script: 
# this script is meant to demonstrate how to pull data from the Propublica Campaign Finance API
# which provides detail on the activities of campaign funding

# turn off stringsAsFactors because they make analysis hard

options(stringsAsFactors = FALSE)

# load packages

suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(plyr))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(dplyr))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(ggplot2))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(ggthemes))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(scales))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(lubridate))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(xml2))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(rjson))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(httr))))

# get list of candidates  --------------------------------------------------------------------------------------
# https://propublica.github.io/campaign-finance-api-docs/#search-for-candidates
# GET https://api.propublica.org/campaign-finance/v1/{cycle}/candidates/search
# Parameter	  Description
# query	      The first or last name of the candidate

result <- GET("https://api.propublica.org/campaign-finance/v1/2016/candidates/search.json?query=Trump", 
         add_headers(`X-API-Key` = Sys.getenv("CAMPAIGN_FINANCE_API_KEY")))
parsed_result <- content(result, 'parsed')

# you still need to convert this list into a data.frame
# loop through each member, convert to 1 row data.frame, bind all rows together
candidates <- ldply(parsed_result$results, 
                 .fun=function(x){
                    as.data.frame(x[!sapply(x, is.null)])
                   }
                 )
# Trump candidate id appears to be P80001571

# GET https://api.propublica.org/campaign-finance/v1/{cycle}/filings/{year}/{month}/{day}.json
# This will pull data for individual electronic filings

result <- GET("https://api.propublica.org/campaign-finance/v1/2016/filings/2016/08/01.json", 
              add_headers(`X-API-Key` = Sys.getenv("CAMPAIGN_FINANCE_API_KEY")))
parsed_result <- content(result, 'parsed')

filings <- ldply(parsed_result$results, 
                 .fun=function(x){
                   as.data.frame(x[!sapply(x, is.null)])
                 }
                )


# pulling all expenditures for the month of july
total_independent_expenditures <- NULL
for (i in 1:31){
  # GET https://api.propublica.org/campaign-finance/v1/{cycle}/filings/{year}/{month}/{day}.json
  # This will pull data for individual electronic filings
  result <- GET(sprintf("https://api.propublica.org/campaign-finance/v1/2016/independent_expenditures/2016/07/%s.json", as.character(i)), 
                add_headers(`X-API-Key` = Sys.getenv("CAMPAIGN_FINANCE_API_KEY")))
  parsed_result <- content(result, 'parsed')
  
  independent_expenditures <- ldply(parsed_result$results, 
                                   .fun=function(x){
                                     as.data.frame(x[!sapply(x, is.null)])
                                   }
                                  )
  
  total_independent_expenditures <- bind_rows(total_independent_expenditures, independent_expenditures)
  
}

total_independent_expenditures %>%
  filter(grepl('DONALD', candidate_name, ignore.case=T), 
         grepl('TRUMP', candidate_name, ignore.case=T), 
         grepl('television|radio', purpose, ignore.case=T), 
         support_or_oppose == 'S') %>%
  group_by(date, purpose, support_or_oppose) %>%
  summarize(total=sum(amount))

# independent expenditures for salaries ---------------------------------------------------
total_independent_expenditures %>%
  filter(grepl('salary', purpose, ignore.case=T)) %>%
  group_by(payee) %>%
  summarize(total=sum(amount)) %>%
  arrange(desc(total))

# independent expenditures by candidate ---------------------------------------------------
total_independent_expenditures %>%
  group_by(tolower(candidate_name)) %>%
  summarize(total=sum(amount)) %>%
  arrange(desc(total))

# independent expenditures by state ---------------------------------------------------
total_independent_expenditures %>%
  group_by(state) %>%
  summarize(total=sum(amount)) %>%
  arrange(desc(total))
