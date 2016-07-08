library(jsonlite)
library(curl)
library(dplyr)
library(stringr)
library(tidyr)
library(httr)
library(readr)

# CRAN meta
cran_meta <- read_csv("metadata/cran.csv")

cran_meta_new <- fromJSON(
  "https://api.github.com/search/code?q=org:cran+filename:template.yaml"
  )[[3]] %>%
  flatten() %>% 
  mutate(
    pkg_name = repository.name,
    template_name = str_match(
      path, "inst/rmarkdown/templates/(.*)/template.yaml")[, 2],
    path = str_match(path, "(.*)/template.yaml")[, 2]
  ) %>%
  select(pkg_name, template_name, path)

cran_meta <- full_join(cran_meta, cran_meta_new, 
                       by = names(cran_meta)) %>%
  arrange(pkg_name, template_name)

write_csv(cran_meta, "metadata/cran.csv")

# Github meta


closeAllConnections()
