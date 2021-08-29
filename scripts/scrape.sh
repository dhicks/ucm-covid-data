#! sh
export PATH=/usr/local/bin/:$PATH
Rscript 01_scrape.R

if [[ `git status --porcelain` ]]; then
    # Changes
    git add ../data/*
    git commit -m "add new data"
    echo "Changes"
    osascript -e 'display notification "Scraped new data from UCM Covid dashboard"' 
else
    # No changes
    echo "No changes"
    osascript -e 'display notification "No new data on UCM Covid dashboard"'
fi

