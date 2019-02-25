#!/bin/bash
set -e

clear
export DEBIAN_FRONTEND=noninteractive
#
PANELDB="multicraft_panel"
DAEMONDB="multicraft_daemon"
#
gatherEmail () {
	echo "Enter the SYSADMIN email address, followed by [ENTER]:";echo -n ">"
	read EMAIL
	regex="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"
	if [ -z "$EMAIL" ]; then
		gatherEmail
	elif ! [[ $EMAIL =~ $regex ]] ; then
    	gatherEmail
	fi
}
gatherDomain () {
	echo "Enter the FQDN of the server (i.e. localhost, thewebsite.com), followed by [ENTER]:";echo -n ">"
	read DOMAIN
	if [ -z "$DOMAIN" ]; then
		gatherDomain
	fi
}
gatherDaemon () {
		echo "Enter the daemon number for this instance (if this is the only instance running here type '1'), followed by [ENTER]:";echo -n ">"
	read DAEMONNUM
	if [ -z "$DAEMONNUM" ]; then
		gatherDaemon
	fi
}
gatherKey () {
	echo "Enter the Minecraft Key if you have one (else type 'no'), followed by [ENTER]:";echo -n ">"
	read KEY
	if [ -z "$KEY" ]; then
		gatherKey
	fi
}
gatherPw () {
	echo -n "Enter a complex 8 character password, followed by [ENTER]:";echo -n ">"

	IFS= read -r PW
	LEN=${#PW}
	if [ "$LEN" -lt 8 ]; then
		printf "%s is smaller than 8 characters\n" "$PW"
		gatherPw
	fi
	if [ -z "$(printf %s "$PW" | tr -d "[:alnum:]")" ]; then
		printf "%s only contains ASCII letters and digits\n" "$PW"
		gatherPw
	fi
	PPASSWDDB="${PW}panel"
	DPASSWDDB="${PW}daemon"
}

gatherDaemon;gatherDomain;gatherEmail;gatherKey;gatherPw
#
echo "This is the info you entered:"
echo;echo "SYSADMIN email: ${EMAIL}"
echo "Your domain name: ${DOMAIN}"
echo "Daemon number: ${DAEMONNUM}"
echo "Minecraft key: ${KEY}"
echo;read -n 1 -s -r -p "Hit [ENTER] to continue or CTRL=c to cancel"

apt-get update -y&&apt-get install -y vim software-properties-common apache2 phpmyadmin mysql-server php libapache2-mod-php php-mysql zip -y&&service mysql restart

apt-get install -y dialog expect

SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Press y|Y for Yes, any other key for No:\"
send \"y\r\"
expect \"Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG\"
send \"1\r\"
expect \"New password:\"
send \"$PW\r\"
expect \"Re-enter new password:\"
send \"$PW\r\"
expect \"Do you wish to continue with the password provided?(Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect \"Remove test database and access to it? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect \"Reload privilege tables now? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect eof
")
echo "$SECURE_MYSQL"

sed -i 's/.*irectoryIndex.*/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/' /etc/apache2/mods-enabled/dir.conf

service apache2 restart

service mysql start

mysql -uroot -p${PW} -e "CREATE DATABASE ${PANELDB} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
mysql -uroot -p${PW} -e "CREATE USER ${PANELDB}@localhost IDENTIFIED BY '${PPASSWDDB}';"
mysql -uroot -p${PW} -e "GRANT ALL PRIVILEGES ON ${PANELDB}.* TO '${PANELDB}'@'localhost';"
mysql -uroot -p${PW} -e "FLUSH PRIVILEGES;"

mysql -uroot -p${PW} -e "CREATE DATABASE ${DAEMONDB} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
mysql -uroot -p${PW} -e "CREATE USER ${DAEMONDB}@localhost IDENTIFIED BY '${DPASSWDDB}';"
mysql -uroot -p${PW} -e "GRANT ALL PRIVILEGES ON ${DAEMONDB}.* TO '${DAEMONDB}'@'localhost';"
mysql -uroot -p${PW} -e "FLUSH PRIVILEGES;"

cd ~&&mkdir MulticraftInstllation;cd MulticraftInstllation

wget https://www.multicraft.org/download/linux64 -O multicraft.tar.gz&&tar xvzf multicraft.tar.gz

cd multicraft

sed -i -e "/daemon_db/ s/sqlite:.*/mysql:host=127.0.0.1;dbname=multicraft_daemon'\,/ ; /panel_db/ s/sqlite:.*/mysql:host=127.0.0.1;dbname=multicraft_panel'\,/" /root/MulticraftInstllation/multicraft/panel/protected/config/config.php.dist 
sed -i -e '/panel_db_user/ s/root/multicraft_panel/ ; /daemon_db_user/ s/root/multicraft_daemon/' /root/MulticraftInstllation/multicraft/panel/protected/config/config.php.dist 

MULTI=$(expect -c "
set timeout 10
spawn ./setup.sh
expect \"Run each Minecraft server under its own user? (Multicraft will create system users):\"
send \"y\r\"
expect \"Run Multicraft under this user:\"
send \"minecraft\r\"
expect \"User not found. Create user \'minecraft\' on start of installation?\"
send \"y\r\"
expect \"Install Multicraft in:\"
send \"\r\"
expect \"If you have a license key you can enter it now:\"
send \"$KEY\r\"
expect \"If you control multiple machines from one web panel you need to assign each daemon a unique number (requires a Dynamic or custom license). Daemon number?\"
send \"$DAEMONNUM\r\"
expect \"Will the web panel run on this machine?\"
send \"y\r\"
expect \"User of the webserver:\"
send \"\r\"
expect \"Location of the web panel files:\"
send \"\r\"
expect \"Please enter a new daemon password (use the same password in the last step of the panel installer)\"
send \"$PW\r\"
expect \"Enable builtin FTP server?\"
send \"\r\"
expect \"IP the FTP server will listen on (0.0.0.0 for all IPs):\"
send \"0.0.0.0\r\"
expect \"IP to use to connect to the FTP server (external IP):\"
send \"\r\"
expect \"FTP server port:\"
send \"\r\"
expect \"Block FTP upload of .jar files and other executables (potentially dangerous plugins)?\"
send \"\r\"
expect \"What kind of database do you want to use?\"
send \"mysql\r\"
expect \"Database host:\"
send \"\r\"
expect \"Database name:\"
send \"\r\"
expect \"Database user:\"
send \"\r\"
expect \"Database password:\"
send \"$PW\r\"
expect \"Path to java program:\"
send \"\r\"
expect \"Path to zip program:\"
send \"\r\" 
expect \"Press [Enter] to continue.\"
send \"\r\" 
expect \"Save entered settings?\"
send \"\r\" 
expect eof
")
echo "$MULTI"

sed -i 's/dbUser.*/dbUser = multicraft_daemon/' /home/minecraft/multicraft/multicraft.conf
sed -i '/^password/ d' /home/minecraft/multicraft/multicraft.conf
sed -i "s/dbPassword.*/dbPassword = $DPASSWDDB/" /home/minecraft/multicraft/multicraft.conf
clear

echo;echo
echo "Go to the web panel: http://your.address/multicraft/install.php"
echo "STOP! Copy and don't lose the following passwords:"
echo "$PANELDB: $PANELDB / $PPASSWDDB"
echo "$DAEMONDB: $DAEMONDB / $DPASSWDDB"
echo
