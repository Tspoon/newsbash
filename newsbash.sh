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

# Variables set by command-line arguments
headlinesOnly=false

# Parse arguments
while [[ $# -gt 0 ]]
do
	arg="$1"
	case $arg in
		-s|--short)
			headlinesOnly=true
			;;
	esac
	shift
done

# Fetch the RSS feed.
RSS=$(curl -L --silent http://www.theweek.co.uk/feeds/all)

# Parse the latest 'Ten Things' article from the RSS feed.
HTML=$(echo $RSS | xmllint --xpath "string(//item[contains(title, 'Ten Things You Need to Know Today')]/description)" -)

# Count the number of items in the 'Ten Things' article. This isn't strictly necessary, but good to check.
numItems=$(echo $HTML | xmllint --xpath "count(//div[contains(@class, 'story-headline')]/div/div)" -) 

for ((i=1; i<=$numItems; i++))
do
	# Parse the title and body from the Ten Things article
	title=$(echo $HTML | xmllint --xpath "normalize-space(string((//div[contains(@class, 'story-headline')])[$i]))" -)
	body=$(echo $HTML | xmllint --xpath "normalize-space(string((//div[contains(@class, 'story-body')])[$i]//p))" -)

	# Get the terminal width and define the output string.
	termWidth=$(tput cols)

	if [[ $headlinesOnly = true ]]
	then 
		output="$title"
	else
		output="\e[1m$title\n\e[0m$body"

		if [[ $i -lt $numItems ]]
		then
			output="${output}\n\n"
		fi
	fi

	# Print the headline and body at the appropriate width.
	if [[ $termWidth -lt $maxOutputWidth ]]
	then
		echo -e "$output"| fold -w $termWidth -s
	else
		echo -e "$output" | fold -w $maxOutputWidth -s
	fi

done

