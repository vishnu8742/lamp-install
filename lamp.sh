#!/bin/sh

#######################################
# Bash script to install an AMP stack For ubuntu based systems.
# Written by @vishnu8742

# In case of any errors (e.g. MySQL) just re-run the script. Nothing will be re-installed except for the packages with errors.
#######################################

#COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

# Update packages and Upgrade system
echo -e "$Cyan \n Updating System.. $Color_Off"
sudo apt update -y && sudo apt upgrade -y

## Install AMP
echo -e "$Cyan \n Installing Apache2 $Color_Off"
sudo apt install apache2 -y

echo -e "$Cyan \n Installing PHP & Requirements $Color_Off"
sudo apt install php libapache2-mod-php php-mysql php-dom php-curl -y

echo -e "$Cyan \n Installing MySQL $Color_Off"
sudo apt install mysql-server -y

# echo -e "$Cyan \n Installing phpMyAdmin $Color_Off"
# sudo apt-get install phpmyadmin -y

# echo -e "$Cyan \n Verifying installs$Color_Off"
# sudo apt-get install apache2 libapache2-mod-php5 php5 mysql-server php-pear php5-mysql mysql-client mysql-server php5-mysql php5-gd -y

## TWEAKS and Settings
# Permissions
echo -e "$Cyan \n Permissions for /var/www $Color_Off"
sudo chown -R www-data:www-data /var/www
echo -e "$Green \n Permissions have been set $Color_Off"

# Enabling Mod Rewrite, required for WordPress permalinks and .htaccess files
echo -e "$Cyan \n Enabling Modules $Color_Off"
sudo a2enmod rewrite
sudo phpenmod mcrypt

# Restart Apache
echo -e "$Cyan \n Restarting Apache $Color_Off"
sudo systemctl reload apache2
