library(tidyverse)
library(rvest)
library(xml2)
library(lubridate)
library(assertthat)

dashboard_url = 'https://doyourpart.ucmerced.edu/covid-19-statistics'

data_dir = file.path('..', 'data')

## GET page ----
message(dashboard_url)
page = read_html(dashboard_url)

## Extract Testing and Positivity table ----
header = '//h4/strong[contains(text(), "Testing and Postivity")]/following::'

last_updated = page %>% 
    xml_find_first('//h4/strong[contains(text(), "Testing and Positivity")]/following::p[contains(text(), "Updated")]') %>% 
    xml_text() %>% 
    mdy()

assert_that(all(!is.na(last_updated)), msg = 'Last update not found')
message(str_c('Last update ', last_updated))

## <https://github.com/tidyverse/rvest/issues/116>
fix.names <- function(x, ...) {
    colnames(x) <- make.names(colnames(x), ...)
    x
}

table = page %>% 
    xml_find_first('//h4/strong[contains(text(), "Testing and Positivity")]/following::table') %>% 
    html_table(header = TRUE) %>% 
    fix.names() %>% 
    rename(category = X) %>% 
    mutate(date = last_updated) %>% 
    select(date, everything())

assert_that(all(!is.na(table)), msg = 'Testing and Positivity table not found')

## Write to disk ----
file = file.path(data_dir, str_c(last_updated, '.csv'))
if (file.exists(file)) {
    message('Data file already exists; not writing output')
} else {
    write_csv(table, file)
    message(str_c('Wrote data file ', file))
}
