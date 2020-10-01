#/bin/bash!

# This script updates the timestamp on the bottom of the index page to the current time
# This allows wget to pickup that the file has been modified and is a semi-useful
#  indicator of WHEN the last update happened


# update the timestamp
head -n -1 /var/www/html/index.html > /var/www/html/tmp ; mv /var/www/html/tmp /var/www/html/index.html 
echo "Last Modified: "$(date +%s) >> /var/www/html/index.html
