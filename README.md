# Automate backups and imports for websites on VVV
Create standardized backups (snapshots) for all active websites on `vagrant_halt`. Import the websites with the `import-websites` command. Snapshots are very portable and easily synced.

## Why?
I would like to be able to sync my local development with my cloud. This way I could easily pick up development if my computer crashes or I need to send a colleague. 

But syncing all active website is not effective, because they could contain thousands and thousands of files. That's why I would like to create snapshots with which I could easily sync. 

## Snapshots
To be able to build a website based on a snapshot, a snapshot should contain:
- Database
- config.json
  - WP-core data like version
  - Plugins data like name, version, branch
  - Themes data like name, version, branch
- upload folder

## Future
Status: inactive. The win is not that big, in contrary to the time investment needed to make this happen