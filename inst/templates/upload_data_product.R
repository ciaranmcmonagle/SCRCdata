#' scottish deaths-involving-coronavirus-covid-19
#'
#' This dataset presents the weekly, and year to date, provisional number of
#' deaths associated with coronavirus (COVID-19) alongside the total number
#' of deaths registered in Scotland, broken down by age, sex. (From: https://statistics.gov.scot/data/deaths-involving-coronavirus-covid-19)
#'

library(SCRCdataAPI)
library(SCRCdata)

key <- read.table("token.txt")


# initialise parameters ---------------------------------------------------

product_name <- paste("human", "infection", "SARS-CoV-2", "scotland",
                      "mortality", sep = "/")

todays_date <- as.POSIXct("2020-07-16 11:30:00",
                          format = "%Y-%m-%d %H:%M:%S")
version <- 0
doi_or_unique_name <- "scottish scottish deaths-involving-coronavirus-covid-19"

# where was the source data download from? (original source)
source_name <- "Scottish Government Open Data Repository"
original_root <- "https://statistics.gov.scot/sparql.csv?query="
original_path <- "PREFIX qb: <http://purl.org/linked-data/cube#>
PREFIX data: <http://statistics.gov.scot/data/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dim: <http://purl.org/linked-data/sdmx/2009/dimension#>
PREFIX sdim: <http://statistics.gov.scot/def/dimension/>
PREFIX stat: <http://statistics.data.gov.uk/def/statistical-entity#>
PREFIX mp: <http://statistics.gov.scot/def/measure-properties/>
SELECT ?featurecode ?featurename ?areatypename ?date ?cause ?location ?gender ?age ?type ?count
WHERE {
  ?indicator qb:dataSet data:deaths-involving-coronavirus-covid-19;
              mp:count ?count;
              qb:measureType ?measType;
              sdim:age ?value;
              sdim:causeofdeath ?causeDeath;
              sdim:locationofdeath ?locDeath;
              sdim:sex ?sex;
              dim:refArea ?featurecode;
              dim:refPeriod ?period.

              ?measType rdfs:label ?type.
              ?value rdfs:label ?age.
              ?causeDeath rdfs:label ?cause.
              ?locDeath rdfs:label ?location.
              ?sex rdfs:label ?gender.
              ?featurecode stat:code ?areatype;
                rdfs:label ?featurename.
              ?areatype rdfs:label ?areatypename.
              ?period rdfs:label ?date.
}"

# where is the processing script stored?
repo_storageRoot <- "github"
script_gitRepo <- "ScottishCovidResponse/SCRCdata"
repo_version <- "0.1.0"



# Additional parameters ---------------------------------------------------
# These parameters are automatically generated and assume the following:
# (1) you intend to download your source data now
# (2) your source data will be automatically downloaded to data-raw/[product_name]
# (3) your source data filename will be [version_number].csv
# (4) you intend to process this data and generate a data product now
# (5) your data product will be automatically saved to data-raw/[product_name]
# (6) your data product filename will be [version_number].csv
# (7)

namespace <- "SCRC"

# when was the source data downloaded?
source_downloadDate <- todays_date

# when was the data product generated?
script_processingDate <- todays_date

# create version number (this is used to generate the *.csv and *.h5 filenames)
tmp <- as.Date(todays_date, format = "%Y-%m-%d")
version_number <- paste(gsub("-", "", tmp), version , sep = ".")

# where is the source data downloaded to? (locally, before being stored)
local_path <- file.path("data-raw", product_name)
source_filename <- paste0(version_number, ".csv")

# where is the data product saved? (locally, before being stored)
processed_path <- file.path("data-raw", product_name)
product_filename <- paste0(version_number, ".h5")



# where is the source data stored?
source_storageRoot <- "boydorr"
source_path <- file.path(product_name, source_filename)

# where is the submission script stored?
script_storageRoot <- "text_file"
submission_text <- "R -f inst/scripts/scotgov_deaths.R"

# where is the data product stored?
product_storageRoot <- "boydorr"
product_path <- file.path(product_name, product_filename)



# download source data ----------------------------------------------------

download_from_database(source_root = original_root,
                       source_path = original_path,
                       filename = source_filename,
                       path = local_path)



# generate data product ---------------------------------------------------

process_scotgov_deaths(
  sourcefile = file.path(local_path, source_filename),
  filename = file.path(local_path, product_filename))



# default data that should be in database ---------------------------------

# data product storage root
product_storageRootId <- new_storage_root(name = product_storageRoot,
                                          root = "ftp://boydorr.gla.ac.uk/scrc/",
                                          key = key)

# namespace
namespaceId <- new_namespace(name = namespace,
                             key = key)




# upload data product metadata to the registry ----------------------------

dataProductURIs <- upload_data_product(
  storage_root_id = product_storageRootId,
  name = product_name,
  processed_path = file.path(processed_path, product_filename),
  product_path = paste(product_path, product_filename, sep = "/"),
  version = version_number,
  namespace_id = namespaceId,
  key = key)

