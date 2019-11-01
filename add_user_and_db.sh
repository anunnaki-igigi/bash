#!/bin/bash
/usr/bin/clear
#TEST

read -p "Aanmaken gebruiker (Geen leestekens!): " username
useradd -g www-data -d /srv/wordpress-sites/$username -m -s /bin/ftpuser $username
chown $username:www-data -R /srv/wordpress-sites/$username
chmod 2775 -R /srv/wordpress-sites/$username
echo "Nieuwe gebruiker $username is aangemaakt."
echo "Homedirectory:  /srv/wordpress-sites/$username"
echo
userpass=`pwgen -s`
echo "$username:$userpass"| `chpasswd`
{
echo "Noteer onderstaande gegevens!"
echo "************************************************************************************"
echo "User:                             $username"
echo "Password:                         $userpass"
echo
echo "Website:                          https://$username"
echo
echo "FTP adres:                        $username"
echo "FTP Username:                     $username"
echo "FTP Password:                     $userpass"
echo "************************************************************************************"
} > /tmp/gebruiker.tmp
mysqlroot="bladiebla"

mysql -uroot -p$mysqlroot <<MYSQL_SCRIPT
CREATE DATABASE $username;
CREATE USER '$username'@'localhost' IDENTIFIED BY '$userpass';
GRANT ALL PRIVILEGES ON $username.* TO '$username'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
#/usr/bin/clear
{
echo "Database en Database user aangemaakt!"
echo "Noteer onderstaande Database gegevens!"
echo "MySQL User:                       $username"
echo "MySQL Database:                   $username"
echo "MySQL Password:                   $userpass"
echo "************************************************************************************"
} >> /tmp/gebruiker.tmp
{
echo "************************************************************************************"
echo "Vervolg stappen"
echo "DNS CNAME record aanmaken voor https://$username"
echo "Nginx:"
echo "cp /etc/nginx/sites-available/hku.template /etc/nginx/sites-available/$username"
echo "vi /etc/nginx/sites-available/$username"
echo "ln -s /etc/nginx/sites-available/$username /etc/nginx/sites-enabled/"
echo "nginx -t"
echo "nginx -s reload"
echo "Klaar!"
echo "************************************************************************************"
} > /tmp/text.tmp
echo "Klaar!"
read -p "Druk op enter om door te gaan"

/usr/bin/clear

cat /tmp/gebruiker.tmp

while true;
do
	read -r -p "Wil je de gegevens ook mailen? (J/n) " antwoord

    if [[ $antwoord =~ ^([jJ][eE][sS]|[jJ])$ ]]
    then
        read -p "Wat is het email adres? " mailadres
	read -r -p "Mail wordt verstuurd naar $mailadres (J/n) " klopt
	  if [[ $klopt == "j" || $klopt == "J" || $klopt == "ja" || $klopt == "Ja" ]]
            then
	       cat /tmp/gebruiker.tmp | mail -s "Gegevens gebruiker $username" -a "From: root@bladieblo"  $mailadres
	       rm /tmp/gebruiker.tmp
	       cat /tmp/text.tmp
	       rm /tmp/text.tmp
	 exit 0
	    else
            echo "Niet gemaild!"
	    cat /tmp/text.tmp
	    rm /tmp/text.tmp
            rm /tmp/gebruiker.tmp
	exit 0
     fi

    else
	echo "Noteer bovenstaande gegevens!"
	cat /tmp/text.tmp
	rm /tmp/text.tmp
	rm /tmp/gebruiker.tmp
        exit 0
    fi
done
cat /tmp/text.tmp
rm /tmp/text.tmp
exit 0
