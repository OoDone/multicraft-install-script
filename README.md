# Multicraft Fast Install for Ubuntu forked from se7enack.

Open Terminal:

sudo su

curl https://raw.githubusercontent.com/JySzE/multicraft/master/multicraftserver.sh > multicraftserver.sh&&bash ./multicraftserver.sh

Set your FQDN to "localhost"

After the script is over leave it open where it shows the passwords for the panel and daemon and open a new terminal

sudo nano /etc/apache2/apache2.conf

press f6

Search for "Directory /var/www"

Change "AllowOverride deny" to "AllowOverride All"

Example of what it should look like:

#<Directory /var/www/>
#       Options Indexes FollowSymLinks
#       AllowOverride All
#       Require all granted
#</Directory>


To get php-mcrypt:

sudo apt-get -y install gcc make autoconf libc-dev pkg-config
sudo apt-get -y install php7.2-dev
sudo apt-get -y install libmcrypt-dev

Once the dependencies have been installed, you can install mcrypt with this command:

sudo pecl install mcrypt-1.0.1

Then you need to add extension=mcrypt.so to your php.ini file:

sudo nano /etc/php/7.2/apache2/php.ini

press f6

search for "Dynamic Extensions"

Delete one of the examples and add:

extension=mcrypt.so

Example of what it should look like:

;;;;;;;;;;;;;;;;;;;;;;
; Dynamic Extensions ;
;;;;;;;;;;;;;;;;;;;;;;

; If you wish to have an extension loaded automatically, use the following
; syntax:
;
extension=mcrypt.so
;
; For example:
;

Then you need to 
