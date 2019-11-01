#!/bin/bash
/usr/bin/clear
#TEST
echo "This will delete user and homedir in /srv/wordpress-sites"

read -p "Enter username to delete: " username

echo "This will delete user $username..!"

function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}

if [[ "no" == $(ask_yes_or_no "Are you sure?") || \
      "no" == $(ask_yes_or_no "Are you *REALLY* sure?") ]]
then
    echo "Skipped."
    exit 0
fi

userdel $username
rm -rf /srv/wordpress-sites/$username

echo "Done!"

read -p "Press enter to continue to destroy database"

/usr/bin/clear

echo "This will delete database $username and database user $username"

#read -p "Enter Database name: " dbname
#read -p "Enter Database user: " dbuser
#read -p "Enter Database password : " dbpass

#echo "Ok... This will delete the database: $dbname with database user: $dbuser.."

function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}

if [[ "no" == $(ask_yes_or_no "Are you sure?") || \
      "no" == $(ask_yes_or_no "Are you *REALLY* sure?") ]]
then
    echo "Skipped."
    exit 0
fi


#PASS=`pwgen -s`
mysqlroot="bladiebla"

mysql -uroot -p$mysqlroot <<MYSQL_SCRIPT
DROP DATABASE $username;
DROP USER '$username'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

#/usr/bin/clear
echo "Destroyed Database $username en database user $username!"
exit 0
