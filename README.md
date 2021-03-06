# Multicraft Fast Install for Ubuntu forked from se7enack.

## DO NOT USE SSH TO DO THIS SCRIPT IT WILL FAIL

## Compatible with Ubuntu 16.04, 18.04 and 19.10

#### Open Terminal:


```sudo su```

```nano /etc/apt/sources.list```

```deb http://debian.opennms.org/ stable main```

```apt-get update```

```wget -O - http://debian.opennms.org/OPENNMS-GPG-KEY | sudo apt-key add -```

```apt-get update```

```apt-get install oracle-java8-installer -y```

#### (Dont ever run OpenJDK with minecraft clients or servers, it works but the GC is different and is generally frowned upon and some plugins dont get along with it.)

```apt install curl -y```

### !WARNING! Set your FQDN to "localhost" during next step!

```curl https://raw.githubusercontent.com/JySzE/multicraft-install-script/master/multicraftserver.sh > multicraftserver.sh&&bash ./multicraftserver.sh```


### After the script is over leave it open where it shows the passwords for the panel and daemon and open a new terminal

```sudo nano /etc/apache2/apache2.conf```

press f6

Search for "Directory /var/www"

Change "Options Indexes FollowSymLinks" to "Options FollowSymLinks"

Also change "AllowOverride None" to "AllowOverride All"


Example of what it should look like:

```
<Directory /var/www/>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
</Directory>
```
```sudo service apache2 restart```

To get php-mcrypt:

```sudo apt-get -y install gcc make autoconf libc-dev pkg-config```

```sudo apt-get -y install php7.2-dev```

```sudo apt-get -y install libmcrypt-dev```

Once the dependencies have been installed, you can install mcrypt with this command:

```sudo pecl install mcrypt-1.0.1```

Then you need to add extension=mcrypt.so to your php.ini file:

```sudo nano /etc/php/7.2/apache2/php.ini```

press f6

search for "Dynamic Extensions"

Delete one of the examples and add:

extension=mcrypt.so

Example of what it should look like:

```
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
```

Ctrl + X Enter to save

```sudo service apache2 restart```

### Open your browser of choice and go to 127.0.0.1/multicraft/install.php

Video example:

https://youtu.be/ohv8QXDd8Do?t=270

### After you finish multicraft will inform you to delete the install.php file:

```sudo rm -r /var/www/html/multicraft/install.php```

### After that it is smart to change this password:

```sudo nano /home/minecraft/multicraft/multicraft.conf``` 

#### EXAMPLE:

```
##The connection password for deamon communication
## !! Change this when you set Multicraft to listen on a public IP !!
## The same password will have to be used on the panel side in the file: 
## protected/config/config.php
password= YOURPASSWORD
```

### Change it on the panel config file also:

```sudo nano /var/www/html/multicraft/protected/config/config.php```

```
'daemon_password' => 'YOUR PASSWORD',
```

Done.
