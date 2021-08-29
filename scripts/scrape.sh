#! sh
export PATH=/usr/local/bin/:$PATH
Rscript 01_scrape.R
osascript -e 'display notification "Ran covid dashboard scrape"'
