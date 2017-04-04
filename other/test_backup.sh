#!/bin/bash  
#
# Create a backup in `www-backups` for each website 

# Directory with active websites
glob_www_dir="/vagrant/www/"

# Directory to temporarily store backups
glob_tmp_backup_dir="${glob_www_dir}tmp-backups/"

# Script directory
glob_script_dir="/vagrant/config/homebin/"

# Load function library
source "${glob_script_dir}function_library.sh"

# Create temporary backup directory
create_tmp_backup_dir() {

	# Create temporary backup directory if it does not exist
	if [[ ! -d "$glob_tmp_backup_dir" ]]; then
		echo " * Creating Temporary Backup Directory..."
		mkdir "$glob_tmp_backup_dir"
	fi
}

# Generate backup for wordpress website
generate_wordpress_website_backup() {
	local website_dir="$1" 									# website directory
	local website=$(basename "$website_dir") 				# Extract website-slug
	
	local tmp_backup_file="$glob_tmp_backup_dir$website.tar" 	# Generate name for temporary backup-file

	# Plugin & theme list name
	plugin_list="plugin-list.csv"
	theme_list="theme-list.csv"

	# Plugin & theme dir
	website_plugin_dir="${website_dir}wp-content/plugins/"  # Plugin dir 
	website_plugin_list="$website_plugin_dir$plugin_list" 	# Temporay Plugin list
	website_theme_dir="${website_dir}wp-content/themes/"  # theme dir 
	website_theme_list="$website_theme_dir$theme_list" 	# Temporay Plugin list

	# echo " * Creating \"$tmp_backup_file\"..."
	# tar cfv "$tmp_backup_file" --files-from /dev/null

	# echo " * Backing up wp-config and version.php..."
	# tar rfv "$tmp_backup_file" -C "$glob_www_dir$website/" "wp-config.php"
	# tar rfv "$tmp_backup_file" -C "$glob_www_dir$website/wp-includes/" "version.php"

	source "${glob_script_dir}test_plugin.sh"
	# Create Plugin list
	# "${glob_script_dir}www_backup_helpers/generate_plugin_list.sh" "$website_dir"
	
	# echo " * Backing up plugin list..."	
	# tar rfv "$tmp_backup_file" -C "$glob_www_dir$website/wp-content/plugins/" "$plugin_list"
	# rm "$glob_www_dir$website/wp-content/plugins/$plugin_list"
	# echo " * Removed plugin list..."
}

# START!
echo
echo "[START] Backup Process...";

# Create Temporary Backup dir
create_tmp_backup_dir

# Generate Website backups
generate_wordpress_website_backup "/srv/www/countrysidedating/"

echo "[COMPLETED] Backup Process"; echo