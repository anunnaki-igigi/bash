#!/bin/bash
/usr/bin/clear
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
#echo "Noteer onderstaande gegevens!"
echo "************************************************************************************"
echo "User:                             $username"
echo "Password:                         $userpass"
echo
echo "Website:                          https://$username.hku.nl"  
echo
echo "FTP adres:                        $username.hku.nl"
echo "FTP Username:                     $username"
echo "FTP Password:                     $userpass"
echo "************************************************************************************"
} > /tmp/gebruiker.tmp
mysqlroot="tHuYumubre9u"
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
echo "Automatisch uitgevoerd voor nginx"
echo "cp /etc/nginx/sites-available/hku.template /etc/nginx/sites-available/$username"
echo "ln -s /etc/nginx/sites-available/$username /etc/nginx/sites-enabled/"
echo "nginx -s reload"
echo "************************************************************************************"
} > /tmp/text.tmp

echo "Gereed!"

/usr/bin/clear

cat /tmp/gebruiker.tmp

cat >> /etc/nginx/sites-available/$username << EOF
server {
  listen 80;
  server_name $username.hku.nl;
  server_tokens off;
  root /nowhere; ## root doesn't have to be a valid path since we are redirecting
  return 301 https://\$server_name\$request_uri;
}
server {
        listen 443 ssl;
        server_tokens off;
        ssl_certificate     /etc/nginx/cert/star_hku.crt;
        ssl_certificate_key /etc/nginx/cert/hkuwildcard_key.pem;
        ssl_dhparam /etc/nginx/cert/dhparam.pem;
        ssl on;
        ssl_verify_client off;
        ssl_ciphers ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
        ssl_protocols  TLSv1.2;
        ssl_session_cache  builtin:1000  shared:SSL:10m;
        ssl_prefer_server_ciphers   on;
        add_header Strict-Transport-Security max-age=31536000;
        add_header X-Content-Type-Options nosniff;
        root /srv/wordpress-sites/$username;
        index index.php index.html index.htm;
        server_name $username.hku.nl;
        access_log /var/log/nginx/$username.access.log;
        error_log /var/log/nginx/$username.error.log;
        location / {
                try_files \$uri \$uri/ =404;
        }
        location ~ \.php$ {
               include snippets/fastcgi-php.conf;
               fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        }
        location ~ /\.ht {
               deny all;
        }
}
EOF
echo "Nginx bestand aangemaakt in /etc/sites-available/$username"
echo
read -p "Nu gaan we de site activeren, druk Enter om door te gaan"

ln -s /etc/nginx/sites-available/$username /etc/nginx/sites-enabled/
#nginx -t
nginx -s reload

#sleep 5
/usr/bin/clear

cat /tmp/text.tmp
echo "Alles gereed..Maak nu in ipam.hku.nl een DNS CNAME record aan voor https://$username.hku.nl"
echo "$username CNAME studentpress"

while true;
do
	read -r -p "Wil je de gegevens ook mailen? (J/n) " antwoord
	
    if [[ $antwoord =~ ^([jJ][eE][sS]|[jJ])$ ]]
    #if $antwoord == "j" || $antwoord == "J" || $antwoord == "ja" || $antwoord == "Ja"
    then
        read -p "Wat is het email adres? " mailadres
	read -r -p "Mail wordt verstuurd naar $mailadres (J/n) " klopt
	  #if [[ $klopt == "j" || $klopt == "J" || $klopt == "ja" || $klopt == "Ja" ]]
	  if [[ $klopt =~ ^([jJ][eE][sS]|[jJ])$ ]]
            then
	       cat /tmp/gebruiker.tmp | mail -s "Gegevens gebruiker $username" -a "From: root@studentpress.hku.nl"  $mailadres
	       /usr/bin/clear
	       echo "Mail verstuurd"
	       cat /tmp/gebruiker.tmp
	       #cat /tmp/text.tmp
	       rm /tmp/gebruiker.tmp
	       rm /tmp/text.tmp
	 exit 0
	    else
	    /usr/bin/clear
            echo "Niet gemaild!"
	    cat /tmp/gebruiker.tmp
	    #cat /tmp/text.tmp
	    rm /tmp/text.tmp
            rm /tmp/gebruiker.tmp
	exit 0
     fi

    else
        /usr/bin/clear
	echo "Niet gemaild!"
	#echo "Noteer onderstaande gegevens!"
	cat /tmp/gebruiker.tmp
	rm /tmp/text.tmp
	rm /tmp/gebruiker.tmp
        exit 0
    fi
done
cat /tmp/gebruiker.tmp
echo "mail verstuurd"
#cat /tmp/text.tmp
rm /tmp/gebruiker.tmp
rm /tmp/text.tmp

exit 0
