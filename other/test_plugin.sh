#!/bin/bash  
#
# Generate plugin-list

# Create tmp_plugin_list file
create_empty_plugin_list() {
	# rm "$website_plugin_list"
	echo "plugin_id;plugin_host;plugin_repo;plugin_branch;plugin_version;" > "$website_plugin_list"
}

process_plugins() {
	local main_file=""
	local plugin_id=""

	# Loop through plugin-directory
	for plugin in "$website_plugin_dir"*; do

		main_file=""
		plugin_id=$(basename "$plugin")
		echo " * Checking out $plugin_id"

		# If plugin-file
		if [[ -f "$plugin" ]]; then

			if is_main_file "$plugin"; then
				main_file="$plugin"
				plugin_id="${plugin_id%*.php}" # Extract part before .php in case of plugin-file
			fi

		# If plugin-directory
		elif [[ -d "$plugin" ]]; then

			# Loop through plugin
			for plugin_file in ${plugin}/*.php; do

				if [[ -f "$plugin_file" ]]; then

					if is_main_file "$plugin_file"; then
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

fill_plugin_list() {
	local main_file="$1"
	local plugin_id="$2"

	# Make sure main_file exists and is not empty 
	if [[ -s "$main_file" ]]; then
		local plugin_host=$(get_host "$main_file" "plugin")		
		local plugin_repo=$(get_repo "$main_file" "plugin")
		local plugin_branch=$(get_branch "$main_file")
		local plugin_version=$(get_meta_value "Version" "$main_file")

		echo "$plugin_id;$plugin_host;$plugin_repo;$plugin_branch;$plugin_version;" >> "$website_plugin_list"
	fi
}

create_empty_plugin_list

process_plugins
