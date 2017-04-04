#!/bin/bash  
#
# Bash library of useful functions

# Super trim functions for whitespaces
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

# Check if a given file is the main plugin-file
# Parameter 1: Meta name
# Parameter 2: Full file path
has_meta_name() {
	local meta_name="$1"
	local main_file="$2"
	local meta_delimiter=":"

	# Check if main_plugin_file_identifier occurs in file
	if grep -iq "$meta_name$meta_delimiter" "$main_file"; then
		true
	else
		false
	fi
}

# Abstract function to get content after meta-name. 
# Follows this pattern [meta-name]:[meta-value]
# Parameter 1: Meta name
# Parameter 2: Full file path
get_meta_value() {
	local meta_name="$1"
	local main_file="$2"
	local meta_delimiter=":"

	# Get line which contains an identifier (only the first occurence)
	local meta_line=$(grep -i "$meta_name$meta_delimiter" "$main_file" | head -1)

	local meta_value="${meta_line##*$meta_delimiter}"  # Extract meta value
	local meta_value=$(trim "$meta_value") 		       # Remove unwanted spaces

	echo "$meta_value"
}

# Check if a given file is the main file (plugin or theme)
# Parameter 1: Main File
# Parameter 2: File type (theme or plugin)
is_main_file() {
	local main_file="$1"
	local file_type="$2"
	local meta_name="$file_type Name"

	# Check if meta_name occurs in file
	if has_meta_name "$meta_name" "$main_file"; then
		true
	else
		false
	fi
}

# Get host of codebase (plugin/theme)
# Parameter 1: Main File
# Parameter 2: File type (theme or plugin)
get_host() {
	local main_file="$1"
	local main_file_type="$2"
	local github_meta_name=""
	local bitbucket_meta_name=""

	if [[ "$main_file_type" == "plugin" ]]; then
		local github_meta_name="GitHub Plugin URI"
		local bitbucket_meta_name="Bitbucket Plugin URI"
	elif [[ "$main_file_type" == "theme" ]]; then
		local github_meta_name="GitHub Theme URI"
		local bitbucket_meta_name="Bitbucket Theme URI"
	else
		# What type is the file? Asuming Plugin"
		local github_meta_name="GitHub Plugin URI"
		local bitbucket_meta_name="Bitbucket Plugin URI"
	fi

	# Check if meta_name occurs in file
	if has_meta_name "$github_meta_name" "$main_file"; then
		echo "github"
	elif has_meta_name "$bitbucket_meta_name" "$main_file"; then
		echo "bitbucket"
	else
		local current_dir=$(dirname "$main_file")
		dir_name=${current_dir##*/}
		if [[ "$dir_name" == "gravityforms" ]]; then
			echo "$dir_name"
		else
			echo "wordpress"
		fi
	fi
}

# Get Repo
# Parameter 1: Main File
# Parameter 2: File type (theme or plugin)
get_repo() {
	local main_file="$1"
	local main_file_type="$2"
	local github_meta_name=""
	local bitbucket_meta_name=""
	local repo=""

	if [[ "$main_file_type" == "plugin" ]]; then
		local github_meta_name="GitHub Plugin URI"
		local bitbucket_meta_name="Bitbucket Plugin URI"
	elif [[ "$main_file_type" == "theme" ]]; then
		local github_meta_name="GitHub Theme URI"
		local bitbucket_meta_name="Bitbucket Theme URI"
	else
		# What type is the file? Asuming Plugin"
		local github_meta_name="GitHub Plugin URI"
		local bitbucket_meta_name="Bitbucket Plugin URI"
	fi

	# Check if meta_name occurs in file
	if has_meta_name "$github_meta_name" "$main_file"; then
		get_meta_value "$github_meta_name" "$main_file"
	elif has_meta_name "$bitbucket_meta_name" "$main_file"; then
		get_meta_value "$bitbucket_meta_name" "$main_file"
	else
		echo
	fi
}

# Get Branch
# Parameter 1: Main File
get_branch() {
	local main_file="$1"
	local github_meta_name="GitHub Branch"
	local bitbucket_meta_name="Bitbucket Branch"
	local repo=""

	# Check if meta_name occurs in file
	if has_meta_name "$github_meta_name" "$main_file"; then
		get_meta_value "$github_meta_name" "$main_file"
	elif has_meta_name "$bitbucket_meta_name" "$main_file"; then
		get_meta_value "$bitbucket_meta_name" "$main_file"
	else
		echo
	fi
}