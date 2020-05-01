#/bin/sh -eu

### CHECK OS ###
OS=$(hostnamectl | grep "Operating System" | awk '{print $3}')
if [ $OS = "Debian" ]
then
	#If OS is Debian add sources and install certbot for later use
	apt install wget lsb-release apt-transport-https ca-certificates certbot python-certbot-apache -y
	wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
	echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
elif [ $OS = "Ubuntu" ]
then
	#If OS is Ubuntu add ppa
	apt install software-properties-common certbot python3-certbot-apache -y
	add-apt-repository ppa:ondrej/php -y
else
	echo "It seems like you are running a not supportet OS. Not going to install anything."
	exit 1
fi

### Ask a few questions ###

read -p 'Please enter your e-mail address: ' SERVER_ADMIN
read -p 'Please enter your servers FQDN (e.g. nexcloud.mydomain.net): ' SERVER_NAME

# UPDATE OS ###

apt update -y && apt upgrade -y > /dev/null


### Installing needed Packages ###

apt install unzip passwdqc curl wget apache2 mariadb-server mariadb-client php7.3 libapache2-mod-php7.3 php7.3-common php7.3-gmp php7.3-curl php7.3-intl php7.3-mbstring php7.3-xmlrpc php7.3-mysql php7.3-gd php7.3-xml php7.3-cli php7.3-zip php7.3-imagick > /dev/null


### GENERATE PASSWORDS https://www.openwall.com/passwdqc/ ###

DB_ROOT=$(pwqgen)
DB_NEXTCLOUND=$(pwqgen)


### MYSQL COMMANDS ###

myql --user=root <<_EOF_
UPDATE mysql.user SET Password=PASSWORD('${DB_ROOT}') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
CREATE DATABASE nextcloud;
CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY '${DB_NEXTCLOUD}';
GRANT ALL ON nextcloud.* TO 'nextcloud'@'localhost' IDENTIFIED BY 'password_here' WITH GRANT OPTION;
FLUSH PRIVILEGES;
_EOF_

systemctl restart mariadb.service

### PHP SETTINGS ###

sed -i "s/memory_limit = 128M/memory_limit = 1024M/g" /etc/php/7.3/apache2/php.ini
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 16G/g" /etc/php/7.3/apache2/php.ini
sed -i "s/post_max_filesize = 8M/post_max_filesize = 16G/g" /etc/php/7.3/apache2/php.ini


### NEXTCLOUD INSTALLATION - LATEST VERSION ###

# Get latest zip, unzip and move to /var/www/
wget https://download.nextcloud.com/server/releases/latest.zip -P /tmp/
unzip /tmp/latest.zip
mv /tmp/nextcloud /var/www/

# Change permissions of nexcloud so that apache can use it
chown -R www-data:www-data /var/www/nextcloud/
chmod -R 755 /var/www/nextcloud/

# Make sure data dir is available and readable by apache
if [[ -d /data ]]
then
	chown -R www-data:www-data /data
else
	mkdir /data
	chown -R www-data:www-data /home/data/
fi


### APACHE CONFIGURATION ####

# Move template nextcloud conf to apache dir
mv templates/nextcloud.conf /etc/apache2/sites-available/nextcloud.conf

# Change a few options and edit nexctloud.conf to fit for user
sed -i "s/Options Indexes FollowSymLinks/Options FollowSymLinks/" /etc/apache2/apache2.conf
sed -i "s/admin_template/${SERVER_ADMIN}/g" /etc/php/7.3/apache2/php.ini
sed -i "s/name_template/${SERVER_NAME}/g" /etc/php/7.3/apache2/php.ini
sed -i "s/alias_template/www.${SERVER_NAME} ${SERVER_ALIAS}/g" /etc/php/7.3/apache2/php.ini

# Enable Nexcloud Conf and Modules
a2ensite nextcloud.conf
a2enmod rewrite
a2enmod headers
a2enmod env
a2enmod dir
a2enmod mime

# Reload apache
systemctl restart apache2.service


### LETSENCRYPT CERTIFICATE ###

certbot --apache --non-interactive --agree-tos --redirect -m ${SERVER_ADMIN} -d ${SERVER_NAME} -d ${SERVER_ALIAS} -d www.${SERVER_NAME} -d www.${SERVER_ALIAS}





