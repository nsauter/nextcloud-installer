#/bin/sh

#add php source and as this installer is for debian and ubuntu we need to check which os we are running
OS=$(hostnamectl | grep "Operating System" | awk '{print $3}')
if [ $OS = "Debian" ]
then
	#If OS is Debian add sources
	apt install wget lsb-release apt-transport-https ca-certificates -y
	wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
	echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
elif [ $OS = "Ubuntu" ]
then
	#If OS is Ubuntu add ppa
	apt install software-properties-common -y
	add-apt-repository ppa:ondrej/php
else
	echo "It seems like you are running a not supportet OS. Not going to install anything."
	exit 1
fi

#making sure this os is up-to-date
apt update -y && apt upgrade -y > /dev/null

#install needed packages
apt install passwdqc curl wget apache2 mariadb-server mariadb-client php7.3 libapache2-mod-php7.3 php7.3-common php7.3-gmp php7.3-curl php7.3-intl php7.3-mbstring php7.3-xmlrpc php7.3-mysql php7.3-gd php7.3-xml php7.3-cli php7.3-zip php7.3-imagick > /dev/null

### GENERATE PASSWORDS https://www.openwall.com/passwdqc/ ###

DB_ROOT=$(pwqgen)
DB_NEXTCLOUND=$(pwqgen)

### MYSQL COMMANDS ###

#mysql_secure_installation non interavtive & creation of needed dbstructure
myql --user=root <<_EOF_
UPDATE mysql.user SET Password=PASSWORD('${DB_ROOT}') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
CREATE DATABASE nextcloud;
CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY '${DB_NEXTCLOUD}';
GRANT ALL ON nextcloud.* TO 'nextclouduser'@'localhost' IDENTIFIED BY 'password_here' WITH GRANT OPTION;
FLUSH PRIVILEGES;
_EOF_


### PHP SETTINGS ###







### APACHE COMMANDS ####

#disable apache directory listing
sed -i "s/Options Indexes FollowSymLinks/Options FollowSymLinks/" /etc/apache2/apache2.conf
