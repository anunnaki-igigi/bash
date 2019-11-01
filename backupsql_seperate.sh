#!/bin/sh
#TEST
### System Setup ###
BACKUP=/home/backupmysql/seperate


### MySQL Setup ###
MUSER="root"
MPASS="bladiebla"
MHOST="localhost"

### Keep number of days
NO_OF_DAYS="15"

### FTP server Setup ###
FTPD="YOUR_FTP_BACKUP_DIR"
FTPU="YOUR_FTP_USER"
FTPP="YOUR_FTP_USER_PASSWORD"
FTPS="YOUR_FTP_SERVER_ADDRESS"

######DO NOT MAKE MODIFICATION BELOW#####
#########################################

### Binaries ###
TAR="$(which tar)"
GZIP="$(which gzip)"
FTP="$(which ftp)"
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"

### Today + hour in 24h format ###
NOW=$(date +"%d%H")

### Create hourly dir ###

mkdir $BACKUP/$NOW

### Get all databases name ###
DBS="$($MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases')"
for db in $DBS
do
    FILE=$BACKUP/$NOW/$db.sql.gz
    echo $db; $MYSQLDUMP --add-drop-table --allow-keywords -q -c -u $MUSER -h $MHOST -p$MPASS $db | $GZIP -9 > $FILE
done
### Compress all tables in one nice file to upload ###

ARCHIVE=$BACKUP/$NOW.tar.gz
ARCHIVED=$BACKUP/$NOW

$TAR -cvf $ARCHIVE $ARCHIVED

### Delete the backup dir and keep archive ###

rm -rf $ARCHIVED


#### Delete older dan
find $BACKUP -ctime +$NO_OF_DAYS -exec rm {} \;
