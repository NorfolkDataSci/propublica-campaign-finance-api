# propublica-campaign-finance-api
Analysis of Campaign Finance Activity

## Overview
Using the Campaign Finance API, you can retrieve data from United States Federal Election Commission filings and other sources. The API, which originated at The New York Times in 2008, covers summary information for candidates and committees, as well as certain types of itemized data. 

## Goals
Use the Campaign Finance API to examine for interesting patterns in campaign finance, the success of the campaign, etc.

## Project Roadmap
None at this point

## Data Source
Data obtained through Propublica [Campaign Finance API](https://propublica.github.io/campaign-finance-api-docs/)
NOTE: You must get the API Key to use this API. Contact NorfolkDataSci@gmail.com for the key and instructions to use.

## Getting Started with R
This project has been created and initialized with Packrat (a package management system for enhanced reprodicibility
in R). This means that if you need additional libraries, just run `install.packages()` and the resulting 
packages will be installed in the packrat library so that other users will have exactly the same configuration
as you! Plus, this won't mess with your existing set of installed packages on your personal computer. Here is a 
simple workflow with Packrat:

```
> install.packages('xml2')
> packrat::snapshot(prompt = FALSE)
Adding these packages to packrat:
         _      
    xml2   1.0.0
```