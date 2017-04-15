#!/bin/bash

# Fetches and displays news

#-------------------------------------------------------------------------------
# Configuration variables

# The maximum width of the text output, change to improve readability
maxOutputWidth=80

#-------------------------------------------------------------------------------
# Script

set -o errexit
set -o nounset
set -o pipefail

# Fetch the RSS feed.
RSS=$(curl -L --silent http://www.theweek.co.uk/feeds/all)

# Parse the latest 'Ten Things' article from the RSS feed.
HTML=$(echo $RSS | xmllint --xpath "string((//item[contains(title, 'Ten Things You Need to Know Today')])[1]/description/text())" -)

# Count the number of items in the 'Ten Things' article. This isn't strictly necessary, but good to check.
numItems=$(echo $HTML | xmllint --xpath "count(//div[contains(@class, 'story-headline')]/div/div)" -) 

for ((i=1; i<=$numItems; i++))
do
	# Parse the title from the RSS XML, then use perl to unescape HTML chars.
	escapedTitle=$(echo $HTML | xmllint --xpath "(//div[contains(@class, 'story-headline')])[$i]/div/div/text()" -)
	title=$(echo $escapedTitle | perl -C -MHTML::Entities -pe 'decode_entities($_);' )

	# Same as above, but for body this time.
	escapedBody=$(echo $HTML | xmllint --xpath "(//div[contains(@class, 'story-body')])[$i]//p/text()" -)
	body=$(echo $escapedBody | perl -C -MHTML::Entities -pe 'decode_entities($_);')

	# Get the terminal width and define the output string.
	termWidth=$(tput cols)
	output="\e[1m$title\n\e[0m$body"

	# Print the headline and body at the appropriate width.
	if [ $termWidth -lt $maxOutputWidth ]
	then
		echo -e "$output"| fold -w $termWidth -s
	else
		echo -e "$output" | fold -w $maxOutputWidth -s
	fi

	# Add spacing between news items.
	if [ "$i" -lt "$numItems" ]
	then
		echo -e "\n"
	fi
done

