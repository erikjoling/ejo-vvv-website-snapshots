#!/bin/bash  
#
# Generate theme-list

if [[ -z "$1" ]]; then
	echo "Missing arguments"
	exit 1
fi

# Global Variables
glob_website_dir="$1" 											# Website dir
glob_website_theme_dir="${glob_website_dir}wp-content/themes/"  # Theme dir 
glob_tmp_theme_list="${glob_website_theme_dir}theme-list.csv" 	# Temporay Theme list

# Super trim functions for whitespaces
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

# Create tmp_theme_list file
create_tmp_theme_list() {
	echo "theme_name;theme_repo;theme_source;theme_branch;theme_version;" > "$glob_tmp_theme_list"
}

# Check if a theme is remotely hosted
# If not, we assume it's on wordpress.org
is_remote_hosted() {
	local main_file="$1"
	local github_identifier="GitHub Theme URI:"
	local bitbucket_identifier="Bitbucket Theme URI:"

	# Check if an identifier for remote hosting is found
	if grep -Eiq "$github_identifier|$bitbucket_identifier" "$main_file"; then
		true
	else
		false
	fi
}

# Abstract function to get meta ie. Plugin Name:
get_meta() {
	local meta_identifier="$1: "

	# Get the line which contains an identifier
	local meta_line=$(grep -i "$meta_identifier" "$2")

	local meta_data="${meta_line##*:[[:space:]]}" # Extract Remote URI
	local meta_data=$(trim "$meta_data") 		  # Remove unwanted spaces

	echo "$meta_data"
}

# Get Repo
get_repo() {
	local main_file="$1"

	if is_remote_hosted "$main_file"; then
		echo "remote"
	else
		echo "wordpress.org"
	fi
}

# Get Remote Git URL
get_remote_uri() {	
	local main_file="$1"

	local github_identifier="GitHub Theme URI:"
	local bitbucket_identifier="Bitbucket Theme URI:"

	# Get the line which contains an identifier
	local remote_git_line=$(grep -iE "$github_identifier|$bitbucket_identifier" "$main_file")

	local remote_uri="${remote_git_line##*:[[:space:]]}" # Extract Remote URI
	local remote_uri=$(trim "$remote_uri") 				 # Remove unwanted spaces

	echo "$remote_uri"
}

# Get Source
get_source() {
	local main_file="$1"
	local theme_id="$2"

	if is_remote_hosted "$main_file"; then
		get_remote_uri "$main_file"
	else
		# theme_id is the id for wordpress.org
		echo "$theme_id"
	fi
}

get_branch() {
	local main_file="$1"

	local github_identifier="GitHub Branch:"
	local bitbucket_identifier="Bitbucket Branch:"

	# Get the line which contains an identifier
	local branch_line=$(grep -iE "$github_identifier|$bitbucket_identifier" "$main_file")

	local branch="${branch_line##*:[[:space:]]}" # Extract branch
	local branch=$(trim "$branch") # Remove unwanted spaces

	echo "$branch"
}

fill_theme_list() {
	local main_file="$1"
	local theme_id="$2"

	local theme_name=""
	local theme_repo=""
	local theme_source=""
	local theme_branch=""
	local theme_version=""

	if [[ ! -z "$main_file" && -f "$main_file" ]]; then
		theme_name=$(get_meta "Theme Name" "$main_file")
		theme_repo=$(get_repo "$main_file")
		theme_source=$(get_source "$main_file" "$theme_id")		
		theme_branch=$(get_branch "$main_file")		
		theme_version=$(get_meta "Version" "$main_file")

		echo "$theme_name;$theme_repo;$theme_source;$theme_branch;$theme_version;" >> "$glob_tmp_theme_list"
	fi
}

process_themes() {
	local main_file=""
	local theme_id=""

	# Loop through theme-directory
	for theme in "$glob_website_theme_dir"*/; do

		# If themedirectory
		if [[ -d "$theme" ]]; then

			main_file="$theme"/style.css
			theme_id=$(basename "$theme")

			fill_theme_list "$main_file" "$theme_id"
		fi		

	done
}

echo " * Creating Theme List for $glob_website_dir"

create_tmp_theme_list
process_themes
