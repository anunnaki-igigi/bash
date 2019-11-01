#!/bin/bash
#TEST
#test script backup databases
#set -x
user="root"
pass="bladiebla"
host="localhost"
#days="15"
backup_path="/home/backupmysql"
date=$(date +"%d-%m-%Y")
gzip="$(which gzip)"

umask 177

file=$backup_path/alldatabases-$date.sql.gz

mysqldump --add-drop-table --quote-names --skip-lock-tables --allow-keywords --user=$user --password=$pass --host=$host --all-databases | $gzip -9  > $file

find $backup_path -mtime +15 -and -not -exec fuser -s {} ';' -and -exec rm {} ';'
