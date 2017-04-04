#!/bin/bash  
#
# Generate plugin-list

if [[ -z "$1" ]]; then
	echo "Missing arguments"
	exit 1
fi

# Global Variables
glob_website_dir="$1" 												# Website dir
glob_website_plugin_dir="${glob_website_dir}wp-content/plugins/"  	# Plugin dir 
glob_tmp_plugin_list="${glob_website_plugin_dir}plugin-list.csv" 	# Temporay Plugin list

# Super trim functions for whitespaces
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

# Create tmp_plugin_list file
create_tmp_plugin_list() {
	echo "plugin_name;plugin_repo;plugin_source;plugin_branch;plugin_version;" > "$glob_tmp_plugin_list"
}

# Check if a given file is the main plugin-file
is_main_plugin_file() {
	local plugin_file="$1"
	local main_plugin_file_identifier="Plugin Name:"

	# Check if main_plugin_file_identifier occurs in file
	if grep -iq "$main_plugin_file_identifier" "$plugin_file"; then
		true
	else
		false
	fi
}

# Check if a plugin is remotely hosted
# If not, we assume it's on wordpress.org
is_remote_hosted() {
	local main_file="$1"
	local github_identifier="GitHub Plugin URI:"
	local bitbucket_identifier="Bitbucket Plugin URI:"

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

	local github_identifier="GitHub Plugin URI:"
	local bitbucket_identifier="Bitbucket Plugin URI:"

	# Get the line which contains an identifier
	local remote_git_line=$(grep -iE "$github_identifier|$bitbucket_identifier" "$main_file")

	local remote_uri="${remote_git_line##*:[[:space:]]}" # Extract Remote URI
	local remote_uri=$(trim "$remote_uri") 				 # Remove unwanted spaces

	echo "$remote_uri"
}

# Get Source
get_source() {
	local main_file="$1"
	local plugin_id="$2"

	if is_remote_hosted "$main_file"; then
		get_remote_uri "$main_file"
	else
		echo "$plugin_id" 				# plugin_id is the id for wordpress.org
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

fill_plugin_list() {
	local main_file="$1"
	local plugin_id="$2"

	# Reset plugin data
	local plugin_name=""
	local plugin_repo=""
	local plugin_source=""
	local plugin_branch=""
	local plugin_version=""

	if [[ ! -z "$main_file" && -f "$main_file" ]]; then
		plugin_name=$(get_meta "Plugin Name" "$main_file")
		plugin_repo=$(get_repo "$main_file")
		plugin_source=$(get_source "$main_file" "$plugin_id")		
		plugin_branch=$(get_branch "$main_file")		
		plugin_version=$(get_meta "Version" "$main_file")

		echo "$plugin_name;$plugin_repo;$plugin_source;$plugin_branch;$plugin_version;" >> "$glob_tmp_plugin_list"
	fi
}

process_plugins() {
	local main_file=""
	local plugin_id=""

	# Loop through plugin-directory
	for plugin in "$glob_website_plugin_dir"*; do

		main_file=""
		plugin_id=$(basename "$plugin")

		# If plugin-file
		if [[ -f "$plugin" ]]; then
			
			if is_main_plugin_file "$plugin"; then
				main_file="$plugin"
				plugin_id="${plugin_id%*.php}" # Extract part before .php in case of plugin-file
			fi

		# If plugin-directory
		elif [[ -d "$plugin" ]]; then

			# Loop through plugin
			for plugin_file in ${plugin}/*.php; do

				if [[ -f "$plugin_file" ]]; then

					if is_main_plugin_file "$plugin_file"; then
						main_file="$plugin_file"
						break
					fi				
				fi

			done
		fi

		# Fill plugin list
		fill_plugin_list "$main_file" "$plugin_id"

	done
}

echo " * Creating Plugin List for $glob_website_dir"

create_tmp_plugin_list
process_plugins
