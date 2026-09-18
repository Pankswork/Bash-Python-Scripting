#!/bin/bash

#Author:Pankaj kumar
echo $(date)

#Backup system logs 

log_file=/var/log/auth.log
max_size=100000
file_size=$(du -k "$log_file" | cut -f1)
if [ "$file_size" -gt "$max_size" ]; then
	timestamp=$(date +%Y%m%d_%H%M%S)
        backup_file="/var/log/auth_$timestamp.log" 
	sudo cp "$log_file" "$backup_file"
	sudo gzip "$backup_file"
	echo "Backup and compressed authentication logs as $backup_file.gz"
fi

