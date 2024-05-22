#!/bin/sh

#######################################
# Bash script to install an AMP stack For ubuntu based systems.
# Written by @vishnu8742

# In case of any errors (e.g. MySQL) just re-run the script. Nothing will be re-installed except for the packages with errors.
#######################################

#!/bin/bash

echo "LAMP Server Installation Script"

# Update system
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# Install Apache
echo "Installing Apache..."
sudo apt install apache2 -y

# Enable Apache to run on startup
echo "Enabling Apache to start on boot..."
sudo systemctl enable apache2

# Start Apache
echo "Starting Apache..."
sudo systemctl start apache2

# Install MySQL
echo "Installing MySQL..."
sudo apt install mysql-server -y

# Secure MySQL installation
echo "Securing MySQL installation..."
sudo mysql_secure_installation

# Get MySQL root password
read -sp "Enter MySQL root password: " mysql_root_password
echo

# Install PHP
echo "Installing PHP..."
sudo apt install php libapache2-mod-php php-mysql -y

# Restart Apache to recognize PHP
echo "Restarting Apache to load PHP..."
sudo systemctl restart apache2

# Setup Virtual Host
read -p "Enter your domain name (e.g., example.com): " domain_name
sudo mkdir -p /var/www/$domain_name/

# Set permissions
sudo chown -R $USER:$USER /var/www/$domain_name/
sudo chmod -R 755 /var/www

# Create Virtual Host File
sudo bash -c "cat > /etc/apache2/sites-available/$domain_name.conf <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@$domain_name
    ServerName $domain_name
    ServerAlias www.$domain_name
    DocumentRoot /var/www/$domain_name/
    <Directory /var/www/$domain_name/>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/$domain_name-error.log
    CustomLog \${APACHE_LOG_DIR}/$domain_name-access.log combined
    RewriteEngine on
    RewriteCond %{SERVER_NAME} =$domain_name [OR]
    RewriteCond %{SERVER_NAME} =www.$domain_name
    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>
EOF"

# Enable the new virtual host
sudo a2ensite $domain_name.conf

# Disable the default virtual host
sudo a2dissite 000-default.conf

# Enable Apache rewrite module
sudo a2enmod rewrite

# Reload Apache
echo "Reloading Apache to apply changes..."
sudo systemctl reload apache2

# Setup MySQL Database
read -p "Enter name for the new MySQL database: " db_name
read -p "Enter MySQL database user: " db_user
read -sp "Enter password for MySQL user $db_user: " db_user_password
echo

# Create MySQL Database and User
echo "Creating MySQL database and user..."
sudo mysql -u root -p$mysql_root_password <<MYSQL_SCRIPT
CREATE DATABASE $db_name;
CREATE USER '$db_user'@'%' IDENTIFIED BY '$db_user_password';
GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'%';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "LAMP server setup is complete!"
echo "Domain: $domain_name"
echo "MySQL Root Password: $mysql_root_password"
echo "Database Name: $db_name"
echo "Database User: $db_user"
echo "Database User Password: $db_user_password"


# Enabling Mod Rewrite, required for WordPress permalinks and .htaccess files
echo -e "$Cyan \n Enabling Modules $Color_Off"
sudo a2enmod rewrite
sudo phpenmod mcrypt

# Restart Apache
echo -e "$Cyan \n Restarting Apache $Color_Off"
sudo systemctl reload apache2
