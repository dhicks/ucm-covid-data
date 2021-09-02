library(tidyverse)
library(glue)
library(assertthat)

data_in = file.path('..', 'data_raw')
data_out = file.path('..', 'data')

in_files = list.files(path = data_in, pattern = 'csv') %>% 
    file.path(data_in, .)


#' Turn 2.8% into .0028
clean_perc = function(perc) {
    perc %>% 
        str_remove('%') %>% 
        as.numeric() %>% 
        {./100}
}

clean_raw = function(infile) {
    base_name = basename(infile)
    outfile = file.path(data_out, base_name)
    
    if (!file.exists(outfile)) {
        message('Cleaning {base_name}')
        col_spec = cols(date = 'D',
                    category = 'c',	
                    Total.Unique.Individuals.Tested	= 'n',
                    Total.Tests	= 'n',
                    Total.Symptomatic.Positive.Tests = 'n',
                    Total.Asymptomatic.Positive.Tests = 'n',
                    Total......Positivity.Rate = 'c',
                    Weekly.Tests = 'n',
                    Weekly.Positivity.Rate = 'c',
                    Active.Cases = 'n')
        
        cleaned = infile %>% 
            read_csv(col_types = col_spec) %>% 
            rename(tests = Weekly.Tests, 
                   pos_rate = Weekly.Positivity.Rate, 
                   cases_active = Active.Cases, 
                   tested_total = Total.Unique.Individuals.Tested, 
                   tests_total = Total.Tests, 
                   pos_symp_total = Total.Symptomatic.Positive.Tests, 
                   pos_asymp_total = Total.Asymptomatic.Positive.Tests, 
                   pos_rate_total = Total......Positivity.Rate) %>% 
            mutate(across(c(pos_rate, pos_rate_total), clean_perc)) %>% 
            mutate(pos = round(pos_rate * tests, digits = 0)) %>% 
            mutate(category = tolower(category)) %>% 
            select(date, category, tests, pos, pos_rate, cases_active, 
                   matches('total'))
        
        cleaned %>% 
            is.na() %>% 
            any() %>% 
            magrittr::not() %>% 
            assert_that(msg = glue('Missing values in {base_name}'))
        
        write_csv(cleaned, outfile)
    } else {
        message(glue('{base_name} already cleaned'))
        cleaned = read_csv(outfile, show_col_types = FALSE)
    }
    return(cleaned)
}

combined = map_dfr(in_files, clean_raw)
write_csv(combined, file.path(data_out, 'combined.csv'))
write_rds(combined, file.path(data_out, 'combined.Rds'))
